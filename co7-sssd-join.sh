#!/bin/bash

#install packages needed for joining domain

yum install -y epel-release
yum makecache fast

yum -y install  sssd sssd-ldap sssd-tools oddjob oddjob-mkhomedir openldap-clients samba-common-tools realmd adcli ntpdate chrony krb5-workstation-1.15.1-37.el7_7.2.x86_64

#config kerberos
cat > /etc/krb5.conf <<'EOF'
includedir /var/lib/sss/pubconf/krb5.include.d/
[logging]
default = FILE:/var/log/krb5libs.log
kdc = FILE:/var/log/krb5kdc.log
admin_server = FILE:/var/log/kadmind.log

[libdefaults]
default_realm = DIR.SLB.COM
dns_lookup_realm = false
dns_lookup_kdc = false
ticket_lifetime = 24h
renew_lifetime = 7d
forwardable = true
rdns=false

[realms]

DIR.SLB.COM = {
  kdc = dir.slb.com
  admin_server = dir.slb.com
}

SLB.COM = {
  kdc = slb.com
  admin_server = slb.com
}


[domain_realm]
.dir.slb.com = DIR.SLB.COM
dir.slb.com = DIR.SLB.COM
.slb.com = DIR.SLB.COM
slb.com = DIR.SLB.COM
EOF
 
 #config samba
 
 cat > /etc/samba/smb.conf <<'EOF'
 [global]
   # ADS setting
   security = ads
   realm = DIR.SLB.com
   workgroup = DIR
   allow trusted domains = yes
   encrypt passwords = yes
   kerberos method = system keytab

   idmap config DIR : backend = sss
   idmap config DIR : range = 1000-4000000000
   idmap config * : backend = sss
   idmap config * : range = 1000-4000000000

   template shell = /bin/bash
   template homedir = /home/%D/%U

   # Password Setting
   passdb backend = tdbsam
   obey pam restrictions = yes
   pam password change = yes
   unix password sync = yes
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .


   # Browsing
   server string = %h server (Samba, Ubuntu)
   map to guest = bad user
   dns proxy = no
   domain master = no
   access based share enum = yes

   # Logging
   log file = /var/log/samba/log.%m
   max log size = 1000
   syslog = 0
   panic action = /usr/share/samba/panic-action %d

   # Misc
   usershare allow guests = yes

   # Delete SO_RCVBUF & SO_SNDBUF, bcz these setting is not recommended
   socket options = TCP_NODELAY
EOF

#config nsswitch
cat > /etc/nsswitch.conf <<'EOF'
#
# /etc/nsswitch.conf
#
# An example Name Service Switch config file. This file should be
# sorted with the most-used services at the beginning.
#
# The entry '[NOTFOUND=return]' means that the search for an
# entry should stop if the search in the previous entry turned
# up nothing. Note that if the search failed due to some other reason
# (like no NIS server responding) then the search continues with the
# next entry.
#
# Valid entries include:
#
#	nisplus			Use NIS+ (NIS version 3)
#	nis			Use NIS (NIS version 2), also called YP
#	dns			Use DNS (Domain Name Service)
#	files			Use the local files
#	db			Use the local database (.db) files
#	compat			Use NIS on compat mode
#	hesiod			Use Hesiod for user lookups
#	[NOTFOUND=return]	Stop searching if not found so far
#

# To use db, put the "db" in front of "files" for entries you want to be
# looked up first in the databases
#
# Example:
#passwd:    db files nisplus nis
#shadow:    db files nisplus nis
#group:     db files nisplus nis

passwd:     files sss
shadow:     compat
group:      files sss
#initgroups: files

#hosts:     db files nisplus nis dns
hosts:      files dns myhostname

# Example - obey only what nisplus tells us...
#services:   nisplus [NOTFOUND=return] files
#networks:   nisplus [NOTFOUND=return] files
#protocols:  nisplus [NOTFOUND=return] files
#rpc:        nisplus [NOTFOUND=return] files
#ethers:     nisplus [NOTFOUND=return] files
#netmasks:   nisplus [NOTFOUND=return] files     

bootparams: nisplus [NOTFOUND=return] files

ethers:     files
netmasks:   files
networks:   files
protocols:  files
rpc:        files
services:   files sss

netgroup:   files sss

publickey:  nisplus

automount:  files
aliases:    files nisplus
EOF

#config sssd 
cat > /etc/sssd/sssd.conf << 'EOF'
[sssd]
#debug_level = 1 to 10 , Level 5 is great for just catching waringins and errors
debug_level = 5
config_file_version = 2
reconnection_retries = 3
sbus_timeout = 30
services = nss, pam
domains = DIR.SLB.COM

[nss]
debug_level = 5
reconnection_retries = 3

[pam]
debug_level = 5
reconnection_retries = 3


[domain/DIR.SLB.COM]
debug_level = 5
description = DIR Active Directory Domain

id_provider = ad
auth_provider = ad
ldap_schema = ad
ad_domain = dir.slb.com
ad_enabled_domains = dir.slb.com
#ad_server = us1455dom19.dir.slb.com # do not set this
ldap_id_mapping = True
use_fully_qualified_names = false
access_provider = simple
ignore_group_members = true
ldap_referrals = false
default_shell = /bin/bash
krb5_realm = DIR.SLB.COM
#fallback_homedir = /home/%u
fallback_homedir = /home/DIR/%u
dyndns_update = false
cache_credentials = false
case_sensitive = False

ad_gpo_ignore_unreadable = True
EOF

chmod 0600 /etc/sssd/sssd.conf

cp /etc/pam.d/system-auth-ac /etc/pam.d/system-auth-ac.bak
cp /etc/pam.d/password-auth-ac /etc/pam.d/password-auth-ac.bak

cat > /etc/pam.d/system-auth-ac << 'EOF'
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authconfig is run.
auth        required      pam_env.so
auth        [default=1 success=ok] pam_localuser.so
auth        [success=done ignore=ignore default=die] pam_unix.so nullok try_first_pass
auth        requisite     pam_succeed_if.so uid >= 1000 quiet_success
auth        sufficient    pam_sss.so forward_pass
auth        required      pam_deny.so

account     required      pam_unix.so
account     sufficient    pam_localuser.so
account     sufficient    pam_succeed_if.so uid < 1000 quiet
account     [default=bad success=ok user_unknown=ignore] pam_sss.so
account     required      pam_permit.so

password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
password    sufficient    pam_unix.so md5 shadow nullok try_first_pass use_authtok
password    sufficient    pam_sss.so use_authtok
password    required      pam_deny.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
-session     optional      pam_systemd.so
session     optional      pam_oddjob_mkhomedir.so umask=0077
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_unix.so
session     optional      pam_sss.so

EOF

cat > /etc/pam.d/password-auth-ac << 'EOF'
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authconfig is run.
auth        required      pam_env.so
auth        [default=1 success=ok] pam_localuser.so
auth        [success=done ignore=ignore default=die] pam_unix.so nullok try_first_pass
auth        requisite     pam_succeed_if.so uid >= 1000 quiet_success
auth        sufficient    pam_sss.so forward_pass
auth        required      pam_deny.so

account     required      pam_unix.so
account     sufficient    pam_localuser.so
account     sufficient    pam_succeed_if.so uid < 1000 quiet
account     [default=bad success=ok user_unknown=ignore] pam_sss.so
account     required      pam_permit.so

password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
password    sufficient    pam_unix.so md5 shadow nullok try_first_pass use_authtok
password    sufficient    pam_sss.so use_authtok
password    required      pam_deny.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
-session     optional      pam_systemd.so
session     optional      pam_oddjob_mkhomedir.so umask=0077
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_unix.so
session     optional      pam_sss.so

EOF
 
authconfig --enablemkhomedir --update
dbus-daemon --system
systemctl start oddjobd.service
systemctl enable oddjobd.service 

cat >> /etc/ssh/sshd_config << 'EOF'
AllowUsers  root adm-bgcit yli153
EOF

#Join  Domain
# realm join --computer-ou "OU=EAR-AA-4173,OU=Applications,OU=Servers,DC=DIR,DC=slb,DC=com" -U Bgc_domain_join  --verbose --client-software=sssd --server-software=active-directory --membership-software=adcli DIR.SLB.COM 
 
passwd="Rjs8mb7w9EKR-e3R"
echo $passwd |adcli join --user=Bgc_domain_join -D DIR.SLB.COM --domain-ou="OU=EAR-AA-4173,OU=Applications,OU=Servers,DC=DIR,DC=slb,DC=com" --show-details --stdin-password 

service sssd restart
systemctl enable sssd.service
# Reboot Server for the changes to take effect
reboot
#id zwang77 && sleep 30 && echo "domain join successfully"
