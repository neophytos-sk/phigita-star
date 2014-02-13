#!/bin/bash


###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################


mkdir -p ${WORKDIR}


### Takeaki Uno
cd ${WORKDIR}
mkdir Takeaki_Uno
cd ${WORKDIR}/Takeaki_Uno

mkdir lcm51
cd lcm51
unzip ${FILEDIR}/Takeaki_Uno/lcm52.zip -d .
make
cp lcm ${NSHOME}/bin/

cd ${WORKDIR}/Takeaki_Uno
mkdir lcm_rule
cd lcm_rule
unzip ${FILEDIR}/Takeaki_Uno/lcm_rule.zip -d .
make
cp fim_closed ${NSHOME}/bin/lcm_rule
