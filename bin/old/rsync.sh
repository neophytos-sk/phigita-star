#!/bin/bash


WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh


rsync -az --delete --filter 'protect supervise/' rsync://megistias/servers ${WEBHOME}/servers

rsync -az --delete --filter 'protect supervise/' rsync://megistias/servers-data ${WEBHOME}/servers-data

rsync -az --delete --filter 'protect supervise/' rsync://megistias/files ${WEBHOME}/files
