#!/bin/bash


yum install -y epel-release
yum makecache fast
yum install yum-cron -y

rm -rf /etc/yum/yum-cron-hourly.conf


sed -i 's/update_cmd = default/update_cmd = security-severity:Critical/g'   /etc/yum/yum-cron.conf

sed -i 's/apply_updates = no/apply_updates = yes/g'   /etc/yum/yum-cron.conf
sed -i 's/random_sleep = 360/random_sleep = 0/g'   /etc/yum/yum-cron.conf

sed -i 's/email_to = root/email_to = yli153@slb.com/g'  /etc/yum/yum-cron.conf

cat >> /etc/yum/yum-cron.conf << 'EOF'  
exclude = kernel*
EOF


mv /etc/cron.daily/0yum-daily.cron   /etc/cron.weekly/0yum-daily.cron


cat >> /etc/cron.d/yum-update << 'EOF'
# Auto Update for centos 7 once a week on Sunday at 7pm by default
40 18 * * Sun root  run-parts /etc/cron.weekly/  > /dev/null 2>&1 
EOF



systemctl restart crond
systemctl enable crond

systemctl restart yum-cron
systemctl enable yum-cron
exit
