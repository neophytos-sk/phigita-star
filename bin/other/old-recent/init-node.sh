#!/bin/bash


###################################################################

WEBHOME=/web
source ${WEBHOME}/bin/install-env.sh

###################################################################

emerge --noreplace rsync
echo "make sure that rsyncd is started on epimetheus. press enter when ready"
#read 
/web/bin/rsync.sh
# sync current node
rm -rf /web/bin/ ;# should not be soft link - it's a copy of the bin directory
ln -sf /web/files/bin/ /web/bin

if [ "$1" != "SKIP" ]; then 
    ${WEBHOME}/bin/install-gentoo.sh SERVER BOOTSTRAP
fi

cd ${WEBHOME}
ln -s /web/files/code /web/code
ln -s /web/local-data/ /web/data
ln -s /web/servers/service-phgt-0 /web/service-phgt-0
mkdir /web/db
mkdir /web/log
mkdir /web/local-data
echo "make sure you sync /web/local-data with the backup"
chown -R nsadmin:web /web
chown -R nsadmin:web /web/db
chown -R nsadmin:web /web/log
chown -R nsadmin:web /web/local-data

mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
ln -sf /web/service-phgt-0/etc/nginx/phigita.nginx.conf /etc/nginx/nginx.conf

mv /etc/sysctl.conf /etc/sysctl.conf.orig
cp /web/service-phgt-0/etc/sysctl.conf /etc/
sysctl -p

mv /etc/security/limits.conf /etc/security/limits.conf.orig
cp /web/service-phgt-0/etc/security/limits.conf /etc/security


rc-update add postgresql default
rc-update add svscan default
rc-update add nginx default
