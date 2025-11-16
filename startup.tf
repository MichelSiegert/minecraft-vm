data "template_file" "startup_script" {
template = <<-EOF

apt update
apt install -y openjdk-17-jre-headless screen git gcc make

mkdir -p /opt/mc
cd /opt/mc

if [ ! -f server.jar ]; then
wget -O server.jar https://piston-data.mojang.com/v1/objects/95495a7f485eedd84ce928cef5e223b757d2f764/server.jar
echo "eula=true" > eula.txt
fi


cat > /opt/mc/server.properties <<EOL
enable-rcon=true
rcon.port=25575
rcon.password=${var.rcon_password}
max-players=10
level-name=world
EOL

git clone https://github.com/Tiiffi/mcrcon.git /tmp/mcrcon
cd /tmp/mcrcon && make && cp mcrcon /usr/local/bin/


cat << 'SCRIPT' > /usr/local/bin/mc-idle-shutdown.sh
#!/bin/bash
RCON_PASS="${var.rcon_password}"
TIMEOUT_FILE="/tmp/mc_last_seen_player"
IDLE_LIMIT_MIN=5


PLAYERS=$(mcrcon -H 127.0.0.1 -P 25575 -p "$RCON_PASS" "list" | grep -oP '\\d+(?= players online)')

if [ "$PLAYERS" -gt 0 ]; then
date +%s > "$TIMEOUT_FILE"
exit 0
fi


if [ ! -f "$TIMEOUT_FILE" ]; then
date +%s > "$TIMEOUT_FILE"
exit 0
fi


LAST=$(cat "$TIMEOUT_FILE")
NOW=$(date +%s)
DIFF=$(( (NOW - LAST) / 60 ))


if [ "$DIFF" -ge "$IDLE_LIMIT_MIN" ]; then
    WORLD_DIR="/opt/mc/world"
    BUCKET_NAME="minecraft-backups"
    BACKUP_FILE="world.zip"

    cd "$WORLD_DIR/.."
    zip -r /tmp/$BACKUP_FILE world

    gsutil cp /tmp/$BACKUP_FILE gs://$BUCKET_NAME/$BACKUP_FILE 
    rm /tmp/$BACKUP_FILE

    shutdown -h now
fi
SCRIPT


chmod +x /usr/local/bin/mc-idle-shutdown.sh


(crontab -l 2>/dev/null; echo "* * * * * /usr/local/bin/mc-idle-shutdown.sh") | crontab -

cd /opt/mc
screen -dmS mcserver java -Xmx4G -Xms1G -jar server.jar nogui
EOF

}