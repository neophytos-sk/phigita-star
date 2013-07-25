STATUS=`/etc/init.d/postgresql status`
if [ $(expr match "$STATUS" ".*status:\s*started.*") -eq 0 ]; then
    echo "Please start PostgreSQL:"
    echo "/etc/init.d/postgresql start"
else
    /opt/naviserver/bin/nsd-postgres -i -t /web/servers/service-phgt-0/etc/nsd/config-phigita-8090-dev.tcl -u nsadmin -g web
fi

