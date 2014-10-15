#!/bin/bash

###################################################################

WEBHOME=/web
source ${WEBHOME}/bin/install-env.sh

###################################################################

mkdir -p ${SSLDIR}

if [ ! -z ${SSLDIR}/myssl.key ]; then

# Step 2: Create your server private key
openssl genrsa -des3 -out ${SSLDIR}/myssl.key 1024

# Step 3: Create the Certificate Signing Request
openssl req -new -key ${SSLDIR}/myssl.key -out ${SSLDIR}/myssl.csr

# Step 4: Remove the passphrase
cp ${SSLDIR}/myssl.key ${SSLDIR}/myssl.key.orig
openssl rsa -in ${SSLDIR}/myssl.key.orig -out ${SSLDIR}/myssl.key

fi
