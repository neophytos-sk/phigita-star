#!/bin/bash


###################################################################

WEBHOME=/web
source ${WEBHOME}/bin/install-env.sh

###################################################################

mkdir -p ${WORKDIR}
cd ${WORKDIR}
mkdir odf-converter
cd odf-converter
tar -xvf ${FILEDIR}/odf-converter-1.0.0-5.i586.tar
mkdir -p /opt/OdfConverter/bin/
cp usr/lib/ooo-2.0/program/OdfConverter /opt/OdfConverter/bin/

#cp usr/lib/ooo-2.0/program/OdfConverter /usr/lib/openoffice/program/
#cp usr/lib/ooo-2.0/share/registry/modules/org/openoffice/TypeDetection/Filter/MOOXFilter_cpp.xcu /usr/lib/openoffice/share/registry/modules/org/openoffice/TypeDetection/Filter/
#cp usr/lib/ooo-2.0/share/registry/modules/org/openoffice/TypeDetection/Types/MOOXTypeDetection.xcu /usr/lib/openoffice/share/registry/modules/org/openoffice/TypeDetection/Types/
