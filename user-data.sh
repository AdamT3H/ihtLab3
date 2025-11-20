#!/bin/bash

apt update -y
apt install -y cron

systemctl enable cron
systemctl start cron
systemctl status cron

touch /var/log/sysinfo
chmod 666 /var/log/sysinfo

cat << 'EOF' > /root/sysinfo.sh
#!/bin/bash
LOGFILE="/var/log/sysinfo"

{
  echo "==================== $(date '+%Y-%m-%d %H:%M:%S') ===================="
  echo "---- System uptime, logged users, and CPU load ----"
  w
  echo ""
  echo "---- Memory and Disk usage ----"
  free -m
  echo ""
  df -h
  echo ""
  echo "---- Open TCP ports ----"
  ss -tulpn
  echo ""
  echo "---- Check connection to ukr.net ----"
  ping -c1 -w1 ukr.net
  echo ""
  echo "---- SUID programs ----"
  find / -perm -4000 -type f 2>/dev/null
  echo ""
} >> "$LOGFILE"
EOF

chmod +x /root/sysinfo.sh

echo "* * * * 1-5 root /root/sysinfo.sh" >> /etc/crontab

systemctl restart cron
systemctl status cron
