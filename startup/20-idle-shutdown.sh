cat << 'SCRIPT' > /usr/local/bin/mc-idle-shutdown.sh
RCON_PASS="${rcon_password}"
TIMEOUT_FILE="/tmp/mc_last_seen_player"
IDLE_LIMIT_MIN=5

PLAYERS=$(mcrcon -H 127.0.0.1 -P 25575 -p "$RCON_PASS" "list" | grep -oP '\d+(?= of)' | head -n1)
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
  /usr/local/bin/mc-backup.sh
  shutdown -h now
fi
SCRIPT

chmod +x /usr/local/bin/mc-idle-shutdown.sh
