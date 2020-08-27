#!/bin/bash

#install packages for domain join
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y sssd  krb5-user samba  realmd adcli

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



cat > /etc/nsswitch.conf <<'EOF'
# /etc/nsswitch.conf
#
# Example configuration of GNU Name Service Switch functionality.
# If you have the `glibc-doc-reference' and `info' packages installed, try:
# `info libc "Name Service Switch"' for information about this file.

passwd:         files sss
group:          files sss
shadow:         compat

hosts:          files dns
networks:       files

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files

netgroup:       nis
EOF


cat > /etc/krb5.conf <<'EOF'
[libdefaults]
	default_realm = DIR.SLB.COM
	dns_lookup_realm = false

[realms]
	DIR.SLB.COM  = {
		kdc = DIR.SLB.COM
		kdc = DIR.SLB.COM
	}
EOF

cat >> /etc/pam.d/common-session << 'EOF'
session required pam_mkhomedir.so silent skel=/etc/skel umask=0077
EOF


#Join  Domain
# realm join --computer-ou "OU=EAR-AA-4173,OU=Applications,OU=Servers,DC=DIR,DC=slb,DC=com" -U Bgc_domain_join  --verbose --client-software=sssd --server-software=active-directory --membership-software=adcli DIR.SLB.COM 

 
passwd="Rjs8mb7w9EKR-e3R"
echo $passwd |adcli join --user=Bgc_domain_join -D DIR.SLB.COM --domain-ou="OU=EAR-AA-4173,OU=Applications,OU=Servers,DC=DIR,DC=slb,DC=com" --show-details --stdin-password 

service sssd restart
systemctl enable sssd.service

systemctl restart systemd-logind.service

