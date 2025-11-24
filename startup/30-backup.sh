cat << 'BACKUP_SCRIPT' > /usr/local/bin/mc-backup.sh
WORLD_DIR="/opt/mc/world"
BUCKET_NAME="minecraft-backups-${project_id}"
BACKUP_FILE="world.zip"

if ! command -v zip >/dev/null 2>&1; then
  apt-get update && apt-get install -y zip
fi

if ! command -v gsutil >/dev/null 2>&1; then
  exit 1
fi

if [ ! -d "$WORLD_DIR" ]; then
  exit 1
fi

mcrcon -H 127.0.0.1 -P 25575 -p ${rcon_password} "save-off"
mcrcon -H 127.0.0.1 -P 25575 -p ${rcon_password} "save-all"

cd "$WORLD_DIR/.."
zip -FS -r /tmp/$BACKUP_FILE world

mcrcon -H 127.0.0.1 -P 25575 -p ${rcon_password} "save-on"

gsutil cp /tmp/$BACKUP_FILE gs://$BUCKET_NAME/$BACKUP_FILE
rm -f /tmp/$BACKUP_FILE
BACKUP_SCRIPT

chmod +x /usr/local/bin/mc-backup.sh
