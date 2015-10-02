#!/bin/bash


###################################################################

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/install-env.sh

###################################################################

PREFIX=/opt
DIR=${PREFIX}/closure-${CLOSURE_COMPILER}

rm -rf ${DIR}
mkdir -p ${DIR}
cd ${DIR}
unzip ${FILEDIR}/closure/${CLOSURE_COMPILER}.zip -d .

rm -f /opt/closure
ln -sf ${DIR} /opt/closure

groupadd web
useradd -g web nsadmin

chown -R nsadmin:web /opt/closure
chmod -R 775 /opt/closure
