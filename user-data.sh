#!/bin/bash

yum update -y
yum install -y cronie

systemctl enable crond
systemctl start crond

touch /var/log/sysinfo

cat > /root/sysinfo.sh << 'EOF' 
#!/bin/bash
LOGFILE="/var/log/sysinfo"
{
  echo "=============================="
  echo "DATE: $(date)"
  echo "--- UPTIME / USERS / LOAD ---"
  w
  echo "--- MEMORY USAGE ---"
  free -m
  echo "--- DISK USAGE ---"
  df -h
  echo "--- OPEN TCP PORTS ---"
  ss -tulpn
  echo "--- PING ukr.net ---"
  ping -c1 -w1 ukr.net
  echo "--- SUID PROGRAMS ---"
  find / -perm -4000 -type f 2>/dev/null
  echo
} >> "$LOGFILE"
EOF

chmod +x /root/sysinfo.sh

echo "* * * * 1-5 root /root/sysinfo.sh" > /etc/crontab

systemctl enable crond
systemctl start crond
