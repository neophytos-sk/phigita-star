#!/bin/bash

###################################################################

WEBHOME=/web
source ${WEBHOME}/bin/install-env.sh

###################################################################


####### DO NOT FORGET SYMBOLIC LINK ###########
ln -sf /usr/lib/libexpat.so.1.5.2 /usr/lib/libexpat.so.0

cd ${WORKDIR}
tar -xzvf /web/files/poppler-0.6.1.tar.gz
cd poppler-*/utils
patch -p0 < ${FILEDIR}/poppler-0.6.1-utils-HtmlOutputDev.patch
cd ..
./configure \
    --prefix /opt/poppler-0.6.1 \
    --disable-poppler-qt4 \
    --disable-poppler-glib \
    --disable-poppler-qt \
    --disable-gtk-test \
    --enable-opi \
    --disable-cairo-output \
    --enable-xpdf-headers \
    --enable-libjpeg \
    --enable-zlib

make
make install

ln -s /opt/poppler-0.6.1 /opt/poppler
