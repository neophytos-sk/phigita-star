#!/bin/bash


groupadd nginx
useradd -d /dev/null -s /bin/false nginx

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################



mkdir -p ${WORKDIR}
cd ${WORKDIR}

tar -xzvf ${FILEDIR}/nginx/${NGINX}.tar.gz
cd ${NGINX}


PN="nginx"
NGINX_CONF="--with-http_ssl_module --without-http_fastcgi_module --with-http_dav_module"
# --with-openssl=/path/to/opensslrc

mkdir -p /var/tmp/${PN}/client
mkdir -p /var/tmp/${PN}/proxy
chown -R nsadmin:web /var/tmp/${PN}

./configure \
    --prefix=/opt/${NGINX} \
    --conf-path=/etc/${PN}/${PN}.conf \
    --http-log-path=/var/log/${PN}/access_log \
    --error-log-path=/var/log/${PN}/error_log \
    --pid-path=/var/run/${PN}.pid \
    --http-client-body-temp-path=/var/tmp/${PN}/client \
    --http-proxy-temp-path=/var/tmp/${PN}/proxy \
    --with-md5-asm --with-md5=/usr/include \
    --with-sha1-asm --with-sha1=/usr/include \
    ${NGINX_CONF}

make
make install

mkdir /etc/nginx
cp ${FILEDIR}/nginx/mime.types /etc/nginx/
cat ${FILEDIR}/nginx/init.d-nginx | sed "s/\/usr\/sbin\/nginx/\/opt\/${NGINX}\/sbin\/nginx/g" > /etc/init.d/nginx
chmod 755 /etc/init.d/nginx

if [ ! -f "${ROOT}"/etc/ssl/${PN}/${PN}.key ]; then
    mkdir /etc/ssl/${PN}
    cd /etc/ssl/${PN}/
    chmod -R 0644 /etc/ssl/${PN}
    chown -R nsadmin:web /etc/ssl/${PN}
    ### install_cert /etc/ssl/nginx/nginx
fi


### Post Installation:
### /etc/init.d/nginx upgrade
### ps aux | grep nginx (make sure only the new version is running)
