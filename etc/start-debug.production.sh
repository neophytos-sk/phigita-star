STATUS=`/etc/init.d/postgresql status`
if [ $(expr match "$STATUS" ".*status:\s*started.*") -eq 0 ]; then
    echo "Please start PostgreSQL:"
    echo "/etc/init.d/postgresql start"
else
    export PATH=$PATH:/opt/postgresql/bin
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/postgresql/lib:/opt/naviserver/lib:/opt/clucene/lib
    gdb -x /web/servers/service-phigita/etc/gdb.production.run /opt/naviserver/bin/nsd
fi

