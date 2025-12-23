cd /opt/mc
  screen -dmS mcserver java -Xmx6G -Xms1G -jar server.jar nogui

crontab -l 2>/dev/null | grep -q mc-idle-shutdown.sh || \
  (crontab -l 2>/dev/null; echo "* * * * * /usr/local/bin/mc-idle-shutdown.sh") | crontab -
