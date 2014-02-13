#!/bin/bash

USE="-gtk" emerge mp3info

# video4linux2 - you can capture video from your web cam in linux

ACCEPT_KEYWORDS="~x86" USE="v4l -X -kde -gtk -gnome truetype xvid ogg encode amr aac a52 x264 quicktime mp3 win32codecs" emerge amrwb amrnb ffmpeg ffmpeg2theora
cd /usr/local/src/squanti-*
tar -xzvf /web/files/yamdi-1.2.tar.gz
cd yamdi-1.2
gcc yamdi.c -o yamdi -O2 -Wall
mkdir /opt/yamdi-1.2/
cp yamdi /opt/yamdi-1.2/
ln -s /opt/yamdi-1.2 /opt/yamdi
