WORLD_DIR="/opt/mc/world"
BUCKET_NAME="minecraft-backups-${project_id}"

gsutil -q stat gs://$BUCKET_NAME/world.zip
status=$?

if [ ! -d "$WORLD_DIR" ]; then
  if [ $status -eq 0 ]; then
    mkdir -p /opt/mc/world
    gsutil cp gs://$BUCKET_NAME/world.zip /tmp/world.zip
    unzip -o /tmp/world.zip -d /opt/mc/world
    subdir=$(find /opt/mc/world -mindepth 1 -maxdepth 1 -type d | head -n 1)
    if [ -n "$subdir" ]; then
      mv "$subdir"/* /opt/mc/world/
      rmdir "$subdir"
    fi
    rm /tmp/world.zip
  fi
fi
