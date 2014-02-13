#!/bin/bash


###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################

cd /opt/
rm -rf closure-${CLOSURE_COMPILER}
mkdir closure-${CLOSURE_COMPILER}
cd closure-${CLOSURE_COMPILER}
unzip ${FILEDIR}/closure/${CLOSURE_COMPILER}.zip -d .
cd /opt/
rm -f closure
ln -sf closure-${CLOSURE_COMPILER} closure
chown -R nsadmin:web /opt/closure
chmod -R 775 /opt/closure