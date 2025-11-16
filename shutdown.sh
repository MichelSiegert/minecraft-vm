WORLD_DIR="/opt/mc/world"
BUCKET_NAME="minecraft-backups"
BACKUP_FILE="world-$(date +%Y%m%d-%H%M%S).zip"

cd "$WORLD_DIR/.."
zip -r /tmp/$BACKUP_FILE world

gsutil cp /tmp/$BACKUP_FILE gs://$BUCKET_NAME/$BACKUP_FILE

rm /tmp/$BACKUP_FILE