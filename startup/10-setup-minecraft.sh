mkdir -p /opt/mc
cd /opt/mc

if [ ! -f server.jar ]; then
  wget -O server.jar https://piston-data.mojang.com/v1/objects/95495a7f485eedd84ce928cef5e223b757d2f764/server.jar
  echo "eula=true" > eula.txt
fi

cat > /opt/mc/server.properties <<EOL
enable-rcon=true
rcon.port=25575
rcon.password=${rcon_password}
max-players=10
level-name=world
EOL

git clone https://github.com/Tiiffi/mcrcon.git /tmp/mcrcon
cd /tmp/mcrcon && make && cp mcrcon /usr/local/bin/
