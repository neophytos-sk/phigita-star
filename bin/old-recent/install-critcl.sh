#!/bin/bash


###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################


mkdir -p ${WORKDIR}



### TclCurl
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/tcl-modules/critcl-latest.tar.bz2
echo "copying to /opt/naviserver/lib/"
cp -R critcl-* /opt/naviserver/lib/critcl.vfs/

