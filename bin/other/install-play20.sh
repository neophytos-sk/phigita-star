#!/bin/bash

###################################################################

WEBHOME=/web
source ${WEBHOME}/bin/install-env.sh

###################################################################

mkdir -p ${WORKDIR}

cd /opt/
${UNPACK} ${FILEDIR}/dev-java/playframework/${PLAYFRAMEWORK}.zip
rm -f play20
ln -sf ${PLAYFRAMEWORK} play20
chmod a+x play20/play
chown -R nkd:web /opt/play20/

rm -rf /opt/sbt
mkdir /opt/sbt
cp ${FILEDIR}/dev-java/sbt/sbt-launch.jar ${WEBHOME}/bin/
cp ${FILEDIR}/dev-java/sbt/sbt.sh ${WEBHOME}/bin/sbt
cp ${FILEDIR}/dev-java/sbt/sbt-launch.jar /opt/bin/
cp ${FILEDIR}/dev-java/sbt/sbt.sh /opt/bin/sbt
chmod u+x ${WEBHOME}/bin/sbt
