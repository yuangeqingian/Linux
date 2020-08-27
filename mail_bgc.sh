#!/bin/bash

linux_man='yli153@slb.com'
os_release=`cat /etc/os-release|grep '^NAME'|awk -F'"' '{print $2}'`
version=`cat /etc/os-release|grep '^VERSION='|awk -F'"' '{print $2}'`

if [ "$os_release" = "Ubuntu" ];then

debconf-set-selections <<< "postfix postfix/mailname string $(hostname).slb.com"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'No configuration'"

cat >> /etc/hosts << 'EOF'
#mail relay server
192.23.68.90   gateway.mail.slb.com
EOF


apt-get install postfix -y
apt-get install mailutils -y
postconf -e "relayhost = [gateway.mail.slb.com]"
postconf -e "mydestination = $(hostname).slb.com, localhost.slb.com,localhost"
service postfix restart
echo "test"|mail -s "mail service successfully installed on $(hostname)" yli153@slb.com

exit

fi


if [ "$os_release" = "CentOS Linux" ];then

cat >> /etc/hosts << 'EOF'
#mail relay server
192.23.68.90   gateway.mail.slb.com
EOF

yum install -y postfix 
postfix -c /etc/postfix set-permissions

postconf -e "relayhost = [gateway.mail.slb.com]"
postconf -e "mydestination = $(hostname).slb.com, localhost.slb.com,localhost"
service postfix restart
echo "$(ifconfig)"|mail -s "mail service successfully installed on " yli153@slb.com

exit

fi
