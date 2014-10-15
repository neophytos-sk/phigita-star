#!/bin/bash


###################################################################

WEBHOME=/web
source ${WEBHOME}/bin/install-env.sh

###################################################################

cd /opt/
rm -rf ${YUICOMPRESSOR}
unzip ${FILEDIR}/${YUICOMPRESSOR}.zip -d .
ln -sf ${YUICOMPRESSOR} yuicompressor