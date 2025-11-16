data "template_file" "startup_script" {
template = <<-EOF

    apt update
    apt install -y openjdk-21-jre-headless screen git gcc make zip

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
        RCON_PASS="${var.rcon_password}"
        TIMEOUT_FILE="/tmp/mc_last_seen_player"
        IDLE_LIMIT_MIN=5


        PLAYERS=$(mcrcon -H 127.0.0.1 -P 25575 -p "$RCON_PASS" "list" | grep -oP '\d+(?= of)')
        echo "$(date '+%F %T') - Players online detected: $PLAYERS" >> /tmp/mc-idle-debug.log

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
            shutdown -h now
        fi
    SCRIPT


    chmod +x /usr/local/bin/mc-idle-shutdown.sh

    cat << 'BACKUP_SCRIPT' > /usr/local/bin/mc-backup.sh

    set -euo pipefail

    LOGFILE="/var/log/mc_backup.log"
    exec > >(tee -a "$LOGFILE") 2>&1

    WORLD_DIR="/opt/mc/world"
    BUCKET_NAME="minecraft-backups-myloooooof"
    BACKUP_FILE="world.zip"

    echo "=== Minecraft Backup Script Starting ==="

    if ! command -v zip >/dev/null 2>&1; then
        echo "zip not found, installing..."
        apt-get update && apt-get install -y zip
    fi

    if ! command -v gsutil >/dev/null 2>&1; then
        echo "gsutil missing — cannot continue!"
        exit 1
    fi

    if [ ! -d "$WORLD_DIR" ]; then
        echo "ERROR: World directory $WORLD_DIR does not exist!"
        exit 1
    fi

    echo "Creating ZIP backup..."
    cd "$WORLD_DIR/.."
    zip -r /tmp/$BACKUP_FILE world

    echo "Uploading to bucket gs://$BUCKET_NAME/$BACKUP_FILE ..."
    gsutil cp /tmp/$BACKUP_FILE gs://$BUCKET_NAME/$BACKUP_FILE

    echo "Cleaning up temporary file..."
    rm /tmp/$BACKUP_FILE

    echo "Backup complete."
    echo "========================================"
    BACKUP_SCRIPT

    chmod +x /usr/local/bin/mc-backup.sh


    WORLD_DIR="/opt/mc/world"
    WORLD_BUCKET="${google_storage_bucket.mc_backup.name}"
    WORLD_FILE="world.zip"


    LOGFILE=/var/log/mc_setup.log
    exec > >(tee -a "$LOGFILE") 2>&1

    gsutil -q stat gs://minecraft-backups-myloooooof/world.zip

    status=$?
    if [ $status -eq 0 ]; then
        echo "World exists"
        mkdir -p /opt/mc/world
        gsutil cp gs://minecraft-backups-myloooooof/world.zip /tmp/world.zip
        echo "download complete now unzipping!"
        unzip -o /tmp/world.zip -d /opt/mc/world
        echo "unzip complete now deleting file."
        subdir=$(find /opt/mc/world -mindepth 1 -maxdepth 1 -type d | head -n 1)
        if [ -n "$subdir" ]; then
            mv "$subdir"/* /opt/mc/world/
            rmdir "$subdir"
            echo "Flattened world folder"
        fi

        rm /tmp/world.zip
        echo "delete complete"
    else
        echo "World missing"
    fi


    cd /opt/mc

    sudo screen -dmS mcserver java -Xmx4G -Xms1G -jar server.jar nogui

    (crontab -l 2>/dev/null; echo "10,40 * * * * /usr/local/bin/mc-backup.sh") | crontab -

    (crontab -l 2>/dev/null; echo "* * * * * /usr/local/bin/mc-idle-shutdown.sh") | crontab -
EOF

}