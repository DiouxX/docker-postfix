#!/bin/bash

#Variables

#saslauthd

#SASLAUTHD
#File /etc/imapd.conf
sed -i -e '/admins: cyrus/s/^#//g' /etc/imapd.conf
sed -i -e '/sieve_admins: cyrus/s/^#//g' /etc/imapd.conf
sed -i -e "s/autocreate_quota: 0/autocreate_quota: -1/g" /etc/imapd.conf
sed -i -e '/sasl_mech_list: PLAIN/s/^#//g' /etc/imapd.conf
sed -i -e "s/sasl_pwcheck_method: auxprop/sasl_pwcheck_method: saslauthd/g" /etc/imapd.conf

#File /etc/default/saslautd
sed -i -e "s/\START=no/\START=yes/g" /etc/default/saslauthd

#Restart service
service saslauthd stop
#Foreground
/usr/sbin/saslauthd -a ldap -O /etc/saslauthd.conf -d
