#!/bin/bash

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################


SERVICE_NAME=$1
SERVICE_DIR=/web/$SERVICE_NAME
OPENACS=openacs-5.6.0

echo "Creating OpenACS service: $SERVICE_NAME"
mkdir $SERVICE_DIR
useradd -g web -d $SERVICE_DIR $SERVICE_NAME
su - postgres -c "/opt/postgresql/bin/createuser $SERVICE_NAME"
su - postgres -c "/opt/postgresql/bin/createdb $SERVICE_NAME"
su - postgres -c "/opt/postgresql/bin/createlang plpgsql $SERVICE_NAME"
#tar -C $SERVICE_DIR -xzvf ${FILEDIR}/openacs/${OPENACS}.tgz 
#mv $SERVICE_DIR/$OPENACS/* $SERVICE_DIR
chown -R ${SERVICE_NAME}:web $SERVICE_DIR

/opt/postgresql/bin/psql -U $SERVICE_NAME -f /opt/postgresql/share/contrib/hstore.sql
/opt/postgresql/bin/psql -U $SERVICE_NAME -f /opt/postgresql/share/contrib/_int.sql