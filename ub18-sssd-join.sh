#!/bin/bash

#install packages for domain join
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y sssd  krb5-user samba  realmd adcli

cat > /etc/sssd/sssd.conf << 'EOF'
############################################################
# Base config
############################################################
[sssd]
config_file_version = 2
domains = dir.slb.com
services = nss, pam
override_space = _

############################################################
# NSS config
############################################################
[nss]
filter_users = root, adm-bgcit

############################################################
# PAM config
############################################################
[pam]
offline_credentials_expiration = 300
offline_failed_login_attempts = 6
offline_failed_login_delay = 10

############################################################
# Domain related config
############################################################
[domain/DIR.SLB.COM]
id_provider = ad
auth_provider = ad
access_provider = ad
#chpass_provider = ad
ad_domain = DIR.SLB.COM

override_homedir = /home/DIR/%u
default_shell = /bin/bash
use_fully_qualified_names = false
ignore_group_members = true
enumerate = false

cache_credentials = false
entry_cache_timeout = 5400
account_cache_expiration = 3000


# GPO
ad_gpo_access_control = permissive

# DDNS
dyndns_update = false

#----------------------------------------------------------
# default sssd-ad config from sssd-ldap & sssd-krb5
#----------------------------------------------------------
krb5_validate = true
krb5_use_enterprise_principal = true
ldap_schema = ad
ldap_force_upper_case_realm = true
ldap_id_mapping = true
ldap_sasl_mech = gssapi
ldap_referrals = false
ldap_account_expire_policy = ad
ldap_use_tokengroups = true

#----------------------------------------------------------
# additional sssd-ldap config
#----------------------------------------------------------
ldap_idmap_default_domain = DIR.SLB.COM
#ldap_idmap_default_domain_sid = S-1-5-21-1085031214-1284227242-725345543
#ldap_referrals = false
#ldap_group_nesting_level = 2
#ldap_groups_use_matching_rule_in_chain = true
#ldap_initgroups_use_matching_rule_in_chain = true

#----------------------------------------------------------
# additional sssd-krb5 config
#----------------------------------------------------------
krb5_realm = DIR.SLB.COM
krb5_renewable_lifetime = 10h
krb5_renew_interval = 5h
krb5_store_password_if_offline = true
#krb5_lifetime = 10h
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
# realm join --computer-ou "" -U Bgc_domain_join  --verbose --client-software=sssd --server-software=active-directory --membership-software=adcli 
 
passwd=""
echo $passwd |adcli join --user=Bgc_domain_join -D DIR.SLB.COM --domain-ou="" --show-details --stdin-password 

service sssd restart
systemctl enable sssd.service

systemctl restart systemd-logind.service

