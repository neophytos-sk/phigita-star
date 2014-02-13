#!/bin/bash

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh
PKGNAME=postgis

###################################################################

ACCEPT_KEYWORDS="~amd64" USE="-X -kde -gtk -gnome" emerge -av =sci-libs/proj-4.5.0
USE="-X -kde -gtk -gnome" emerge -av gdal geos
USE="-X -sdl truetype" emerge -av agg

echo "<900913> +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs <>" >> /usr/share/proj/epsg




mkdir -p ${WORKDIR}

### PostgreSQL
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/${PKGNAME}/${POSTGIS}.tar.gz
cd ${POSTGIS}
./configure --prefix=${PGHOME}
make
make install