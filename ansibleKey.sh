#!/bin/bash


#os_release=$(cat /etc/os-release|grep '^NAME'|awk -F'"' '{print $2}')
authfile="/users/robin/.ssh/authorized_keys"

ansible_key="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAoq2Ek/c3uT7NK9TwGkmdHsK/LabiF9prUpawZTaXIpAibD0yWwzz6rOc55SGnHj7a6ODsqXJrD7KeIcL9kORxw6ib5fU3jGZ4Lb2J/23vAEuwsE1tgOmknT3iKb8GEkNx+Tq3y9LuatDXTWj/llzFBSy3esC5hAe2VbcVpyDuYrcBqxntKTrGW6bUgS7p6NSvhaqIm4M/Cqsx2boMurq3H0L6E5LHO60353ew1ICYV6fsL2TogMTjNg72zqrahF/V2p5CMpYxwDXKY0fErcshofpLNcV1K/4KFEtGkNZqAN35DorxWKYUJrvib2TGqLE58qwp7M7dYzC8H7MzkhUuQ== robin@linux53.corp.smith.com"

#ansible_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIu/tjZFa7LOxPw4ueLc3kaoR/1d1IN2ACtMvw4Ke3EfQaL/tEvKMtsOf599u3C4Ch/Olv1DW59491AJxrklZCOo96Ha7bMK2/UbKETKWPppz5mj6Ckjg9bCtSiJReaebDEMBf3Xy4AKBvG66LosjI4ow/l1/O+klEmlZ2wl21/wUm4sJbl1TNmzzbb2uQ0oJrs8OeNVWLFkd2b3B/ZDgYVpthoKWNY0SrfGqxzvZRpvEkVLeM/VXUWZKM39AzWWFe779AvSFJZd6xchs7qKh1Q3exT+tYLPbPEhy7YryMxBIvMYWUAv3uSAHaLz3UIa7vXnanIIXHSLQ5/WTFBq09 cnbjlnx144Key"

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
#else

#	mkdir /home/adm-bgcit/.ssh
#	echo $ansible_key >> ${authfile}
 #       chmod 600 $authfile


#	if [ ${os_release} = "SLES" ]
#	then
#	chown -R seitopadm:adm-bgcit /home/adm-bgcit/.ssh
 #       else
#	chown -R adm-bgcit:adm-bgcit /home/adm-bgcit/.ssh
  #	fi
#	echo "ansibleKey deployed"

fi
