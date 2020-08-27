#!/bin/bash

#os_release=$(cat /etc/os-release|grep '^NAME'|awk -F'"' '{print $2}')
authfile="/home/adm-bgcit/.ssh/authorized_keys"


ansible_key="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAy1EzsdpUlX5fHcPQHvi4q+wu3R17qo8aY+0NRgTdqZmhtPNHgDFc0i3W4gTmihfKAP+OXDjPiS5OcdMI33trzzYVvorO1kO74ofvhPYKC2sBHoNk+fElDnHHn0ruv8iFClNlAc4B+LEqp4N11Gx2NSWbuDeyBrR4phrnKr6F0qQSS5T8m2zHBSPwmbs3/1higyGiKanF/7n931dQGX1EvDyjypMxWS5zwjKbJxm9zDWQai4UvtZXs7M4w8K384JULrBEWd8NOQ4PAwFaIcWkPNV7oaLHgem/d8JaAwcUFd0dGK5Y85UVa4vnatgHIdFk32YF4OK5IlOEVuCXAH0Qvw== root@ansible-bgc.com"

if [ -e $authfile ]

then
grep "$ansible_key" ${authfile} > /dev/null

if [ $? -ne 0 ]
then

echo -e "\n $ansible_key" >> ${authfile}
echo "ansibleKey deployed"

else
echo "ansibleKey already existed"
exit
fi
else

mkdir /home/adm-bgcit/.ssh
echo $ansible_key >> ${authfile}
chmod 600 $authfile


# if [ ${os_release} = "SLES" ]
# then
# chown -R seitopadm:adm-bgcit /home/adm-bgcit/.ssh
# else
chown -R adm-bgcit:adm-bgcit /home/adm-bgcit/.ssh
# fi
echo "ansibleKey deployed"

fi



cat >> /etc/ssh/sshd_config << 'EOF'
AllowUsers root adm-bgcit yli153
EOF

cp -f /etc/sudoers /etc/sudoers.bak
cp -f /etc/sudoers /etc/sudoers.tmp

cat >> /etc/sudoers.tmp << 'EOF'
#sudo privilege for bgc it linux admin
%adm-bgcit ALL=(ALL) NOPASSWD: ALL
yli153 ALL=(ALL) NOPASSWD: ALL
EOF

visudo -q -c -f /etc/sudoers.tmp && cp -f /etc/sudoers.tmp /etc/sudoers



if [ $? -eq 0 ] ;then

   echo "key and sudo set successfully"

fi
