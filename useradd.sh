#!/bin/bash
username='adm-bgcit'
passwd='D2000-slb'
echo "You are creating user ${username}"
useradd $username

if [[ $? -eq 0 ]]
	then
	echo "${username} is created successfully"
	echo $passwd |passwd $username --stdin &> /dev/null

	if [[ $? -eq 0 ]]
       		then
		echo  "${username} passwd set successfully"
	else
		echo  "${username} passwd set failed"
	fi


else
	echo "${username} already exists"
fi
exit 0
