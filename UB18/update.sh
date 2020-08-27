#！/bin/bash


sed -i '/Mail "root"/s/\/\///g' /etc/apt/apt.conf.d/50unattended-upgrades


sed -i 's/Update-Package-Lists "0"/Update-Package-Lists "1"/g'  /etc/apt/apt.conf.d/20auto-upgrades
sed -i  's/"root"/"yli153@slb.com"/g' /etc/apt/apt.conf.d/50unattended-upgrades

sed -i 's/Calendar=/Calendar=Sun /g'  /lib/systemd/system/apt-daily.timer
sed -i 's/6,18:00/18:00/g' /lib/systemd/system/apt-daily.timer
sed -i 's/12h/12s/g' /lib/systemd/system/apt-daily.timer


sed -i 's/Calendar=/Calendar=Sun /g'  /lib/systemd/system/apt-daily-upgrade.timer
sed -i 's/6:00/19:00/g' /lib/systemd/system/apt-daily-upgrade.timer
sed -i 's/60m/60s/g'  /lib/systemd/system/apt-daily-upgrade.timer


sed -i '/MailOnlyOnError/s/\/\///g' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's/"${distro_id}ESM:${distro_codename}"/\/\/&/' /etc/apt/apt.conf.d/50unattended-upgrades

systemctl daemon-reload
#systemctl list-timers


systemctl start apt-daily.timer
systemctl start apt-daily-upgrade.timer
#systemctl start apt-daily.service
#systemctl start apt-daily-upgrade.service

systemctl enable apt-daily.timer
systemctl enable apt-daily-upgrade.timer
#systemctl enable apt-daily.service
#systemctl enable apt-daily-upgrade.service

exit
