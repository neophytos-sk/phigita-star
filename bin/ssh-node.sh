#!/bin/bash


###################################################################

WEBHOME=/web
source ${WEBHOME}/bin/install-env.sh

###################################################################

if [ $# = 0 ]; then
    echo "Usage: $0 hostname [command]"
    exit
fi

PORT=22

echo "Asking node $1 to execute ${2}"
ssh -p $PORT -i ${WEBHOME}/files/SSH/${NAMESPACE}-${1}/id_dsa root@${1} ${2}
