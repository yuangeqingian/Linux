#!/bin/bash
set -x


. /etc/lsb-release

cat > /etc/apt/sources.list<<EOF
deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRIB_CODENAME} main universe multiverse restricted
deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRIB_CODENAME}-updates main universe multiverse restricted
deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRIB_CODENAME}-backports main universe multiverse restricted
deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRIB_CODENAME}-security main universe multiverse restricted
EOF




#sed -i 's/"${distro_id}:${distro_codename}-security"/\/\/&/' /etc/apt/apt.conf.d/50unattended-upgrades
#sed -i 's/"${distro_id}ESM:${distro_codename}"/\/\/&/' /etc/apt/apt.conf.d/50unattended-upgrades
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y


#Hardening start
cat >> /etc/modprobe.d/CIS.conf <<EOF
install cramfs /bin/true
install freevxfs /bin/true
install jffs2 /bin/true
install hfs /bin/true
install hfsplus /bin/true
install squashfs /bin/true
install udf /bin/true
install vfat /bin/true
install dccp /bin/true
install sctp /bin/true
install rds /bin/true
install tipc /bin/true
EOF

echo '* hard core 0' >> /etc/security/limits.d/CIS.conf
cat >> /etc/sysctl.d/CIS.conf <<EOF
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
fs.suid_dumpable = 0
EOF


rm /etc/update-motd.d/*

ACCESS_ISSUE_MSG="
********************************************************
Welcome to the BGC IT system(s):

Use is restricted to Schlumberger authorized users who
must comply with the Information Security User Standard.
Usage is monitored; unauthorized use will be prosecuted.

If you proceed you are accepting the above.
********************************************************
"
if [ -f /etc/debian_version ]; then
  echo "$ACCESS_ISSUE_MSG" >> /etc/issue
  echo "$ACCESS_ISSUE_MSG" >> /etc/issue.net
fi

if [ -f /etc/debian_version ]; then
  apt-get update
  apt-get -y install ntp
  apt-get -y install ntpstat
fi

cat > /etc/ntp.conf <<EOF
driftfile /var/lib/ntp/ntp.drift
statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable
server tick.slb.com iburst
server tock.slb.com iburst
restrict -4 default kod notrap nomodify nopeer noquery
restrict -6 default kod notrap nomodify nopeer noquery
restrict 127.0.0.1
restrict ::1
EOF


rm /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

service ntp restart
if [ -f /etc/debian_version ]; then
  apt-get -y purge telnet
  apt-get -y purge cups-server-common
  apt-get -y purge rsh-client
  apt-get -y purge rsh-redone-client
  apt-get -y purge talk
  apt-get -y purge landscape-*
fi

if [ -f /etc/debian_version ]; then
  chown root:root /boot/grub/grub.cfg
  chmod og-rwx /boot/grub/grub.cfg
fi

chown root:root /etc/crontab
chmod og-rwx /etc/crontab
chown root:root /etc/cron.daily
chmod og-rwx /etc/cron.daily
chown root:root /etc/cron.weekly
chmod og-rwx /etc/cron.weekly
chown root:root /etc/cron.monthly
chmod og-rwx /etc/cron.monthly
chown root:root /etc/cron.d
chmod og-rwx /etc/cron.d
chown root:root /etc/ssh/sshd_config
chmod og-rwx /etc/ssh/sshd_config
chmod -R g-wx,o-rwx /var/log/*
#sed -i s/'X11Forwarding yes'/'X11Forwarding no'/g /etc/ssh/sshd_config
#sed -i s/'PermitRootLogin without-password'/'PermitRootLogin no'/g /etc/ssh/sshd_config
#sed -i s/'LoginGraceTime [0-9]\+'/'LoginGraceTime 60'/g /etc/ssh/sshd_config
#sed -i s/'PermitRootLogin yes'/'PermitRootLogin no'/g /etc/ssh/sshd_config
sed -i s/'PermitEmptyPasswords yes'/'PermitEmptyPasswords no'/g /etc/ssh/sshd_config
#echo 'MaxAuthTries 4' >> /etc/ssh/sshd_config
echo 'Banner /etc/issue.net' >> /etc/ssh/sshd_config
echo 'Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr' >> /etc/ssh/sshd_config
#echo 'Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr' >> /etc/ssh/ssh_config
#echo 'MACs umac-128@openssh.com,umac-128-etm@openssh.com,umac-64@openssh.com,umac-64-etm@openssh.com,hmac-ripemd160,hmac-ripemd160-etm@openssh.com,hmac-sha1,hmac-sha1-etm@openssh.com,hmac-sha2-256,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-512-etm@openssh.com' >> /etc/ssh/sshd_config
#echo 'MACs umac-128@openssh.com,umac-128-etm@openssh.com,umac-64@openssh.com,umac-64-etm@openssh.com,hmac-ripemd160,hmac-ripemd160-etm@openssh.com,hmac-sha1,hmac-sha1-etm@openssh.com,hmac-sha2-256,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-512-etm@openssh.com' >> /etc/ssh/ssh_config
service sshd restart
exit
