#!/bin/bash


###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################


IDFILE=/web/files/SSH/XO-atlas/id_dsa
scp -i $IDFILE /web/bin/install-env.sh root@atlas:/web/bin
scp -i $IDFILE /web/files/naviserver/${NAVISERVER}.tar.bz2 root@atlas:/web/files/naviserver/
#cd /web/repos/phigita/service-phigita
#git push master phigita-atlas
