#!/bin/bash


#os_release=$(cat /etc/os-release|grep '^NAME'|awk -F'"' '{print $2}')
authfile="/users/robin/.ssh/authorized_keys"

ansible_key=""

#ansible_key=""

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
