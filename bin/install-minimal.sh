#!/bin/bash


###################################################################

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/install-env.sh

###################################################################

${WEBHOME}/bin/install-closure.sh
#${WEBHOME}/bin/install-clucene.sh
#${WEBHOME}/bin/install-imagemagick.sh

# for naviserver
${WEBHOME}/bin/install-tcl.sh ${NSHOME} naviserver-
${WEBHOME}/bin/install-naviserver.sh NEW_BRANCH
${WEBHOME}/bin/install-libthread.sh ${NSHOME} naviserver-
${WEBHOME}/bin/install-tdom.sh ${NSHOME} naviserver- --with-aolserver=${NSHOME}
#${WEBHOME}/bin/install-xotcl.sh ${NSHOME} naviserver-
${WEBHOME}/bin/install-tcllib.sh ${NSHOME} naviserver-
#${WEBHOME}/bin/install-tclcurl.sh ${NSHOME} naviserver-
#${WEBHOME}/bin/install-tclgd.sh ${NSHOME} naviserver-
#${WEBHOME}/bin/install-ttext-deps.sh ${NSHOME} naviserver-

