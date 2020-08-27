#!/bin/bash

linux_man='yli153@slb.com'
os_release=`cat /etc/os-release|grep '^NAME'|awk -F'"' '{print $2}'`
version=`cat /etc/os-release|grep '^VERSION='|awk -F'"' '{print $2}'`

if [ "$os_release" = "Ubuntu" ];then

  apt-get update 
  apt-get -y install ubuntu-desktop
  sed -i 's/console/anybody/g'  /etc/X11/Xwrapper.conf
  apt-get -y install xrdp xorgxrdp
  result=$?
  
 apt-get install -y gnome-shell-extension-dashtodock unity  gnome-tweaks gnome-tweak-tool

# to stop the pop up for xrdp 
rm  /usr/share/polkit-1/actions/org.freedesktop.color.policy


  
  
  if [ $result != 0 ];then

   
    mail -s "xrdp install  failed for `hostname`" $linux_man 
    exit
   

  fi
fi

  
if [ "$os_release" = "CentOS Linux" ];then

   yum install -y epel-release
   yum makecache fast
   yum groupinstall "X Window System" "GNOME Desktop" -y
   systemctl set-default graphical.target
   yum install -y xrdp
   dbus-daemon --system
   systemctl enable xrdp xrdp-sesman && systemctl start xrdp xrdp-sesman
   result=$?
   
   if [ $result != 0 ];then

   
    mail -s "xrdp install  failed for `hostname`" $linux_man 
    exit
   

  fi
fi
