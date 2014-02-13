#!/bin/bash

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################

### Country: CY
### State or Province Name: Paphos
### Locality (L): Paphos
### Organization (O): PHIGITA LTD
### Organizational Unit (OU): <Not part of certificate>
### Common Name (CN): www.phigita.net
### /C=CY/ST=Paphos/L=Paphos/O=PHIGITA LTD/CN=www.phigita.net


${WEBHOME}/bin/install-ssl.sh

# Step 5: Generate your own certificate 
cp ${SSLDIR}/myssl.key ${SSLDIR}/nginx.key
openssl x509 -req -days 365 -in ${SSLDIR}/myssl.csr -signkey ${SSLDIR}/nginx.key -out ${SSLDIR}/nginx.cert

####openssl req -new -x509 -days 365 -nodes -out ${SSLDIR}/nginx.cert -keyout ${SSLDIR}/nginx.key