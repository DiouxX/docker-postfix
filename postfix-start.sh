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

#File /etc/cyrus.conf
#delete tabulation
sed -i -e '/imaps          cmd="imapd -s -U 30" listen="imaps" prefork=0 maxchild=100/s/#//g' /etc/cyrus.conf
sed -i -e '/\tpop3            cmd="pop3d -U 30" listen="pop3" prefork=0 maxchild=50/s/^/#/g' /etc/cyrus.conf
sed -i -e '/\tsieve           cmd="timsieved" listen="localhost:sieve" prefork=0 maxchild=100/s/^/#/g' /etc/cyrus.conf
sed -i -e '/#\tsieve           cmd="timsieved" listen="localhost:sieve" prefork=0 maxchild=100/a sieve           cmd="timsieved" listen="sieve" prefork=1 maxchild=100' /etc/cyrus.conf

#File /etc/saslauthd.conf
echo -e "# SERVEUR LDAP\nLDAP_SERVERS: ldap://$LDAP_SERVER:$LDAP_PORT\n\n#DOMAINE\n#LDAP_DEFAULT_DOMAIN: $DOMAIN\n\nLDAP_TIMEOUT: 10\nLDAP_TIME_LIMIT: 10\nLDAP_CACHE_TTL: 30\nLDAP_CACHE_MEM: 32768\n\n#VERSION LDAP\nLDAP_VERSION: 3\n\n# SASL Pour l'accès au serveur\nLDAP_USE_SASL: no\n#LDAP_START_TLS: yes\n#LDAP_TLS_CACERT_DIR: /root/openldap01.pem\n\n# Méthode d'authentification (bind / custom / fastbind)\nLDAP_AUTH_METHOD: bind\n\n# Utilisateur utilisé pour la connexion - Si vide = Anonyme\nLDAP_BIND_DN: $LDAP_BIND\n# Et le mot de passe\nLDAP_BIND_PW: $LDAP_BIND_PW\n\n# Base de départ de la recherche\nLDAP_SEARCH_BASE: $LDAP_SEARCH_BASE\n# Et profondeur (sub / one / base )\nLDAP_SCOPE: sub\n#Filtre de recherche : uid dans notre cas\nLDAP_FILTER: uid=%u\n# Et nom du champ contenant le mot de passe\nLDAP_PASSWORD_ATTR: userPassword" > /etc/saslauthd.conf

#File /etc/default/saslautd
sed -i -e "s/\START=no/\START=yes/g" /etc/default/saslauthd
sed -i -e '/^MECHANISMS*/s/MECHANISMS="pam"/MECHANISMS="ldap"/' /etc/default/saslauthd
sed -i -e '/\MECHANISMS="ldap"/aPARAMS="-O /etc/saslauthd.conf"' /etc/default/saslauthd

#Restart service
service saslauthd stop
#Foreground
/usr/sbin/saslauthd -a ldap -O /etc/saslauthd.conf -d
