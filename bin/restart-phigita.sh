#!/bin/bash

WGET_CMD="wget -q -O - http://localhost:8001/SYSTEM/status"

# make the sure the backup service is running
echo "start phigita-8000"
svc -du /service/phigita-8000
sleep 300

# restart the main service
echo "stop phigita-8001"
svc -d /service/phigita-8001
echo "sleep for 25 seconds"
sleep 25
STATUS=`${WGET_CMD}`
while [ "$STATUS" != "ok" ]; do
    echo "restart phigita-8001"
    svc -du /service/phigita-8001
    echo "sleep for 30 seconds"
    sleep 30
    STATUS=`${WGET_CMD}`
done
echo "phigita-8001 started ok"
echo "sleep for 5 seconds before shutting down phigita-8000"
sleep 5

# once sure that the main service is running shutdown the backup
echo "stop phigita-8000"
svc -d /service/phigita-8000
