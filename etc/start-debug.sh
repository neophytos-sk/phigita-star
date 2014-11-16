STATUS=`/etc/init.d/postgresql-8.4 status`
if [ $(expr match "$STATUS" ".*status:\s*started.*") -eq 0 ]; then
    echo "Please start PostgreSQL:"
    echo "/etc/init.d/postgresql start"
else
    export PATH=$PATH:/opt/postgresql-8.4/bin
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/postgresql-8.4/lib:/opt/naviserver/lib:/opt/clucene/lib
    gdb -x /web/servers/service-phigita/etc/gdb.run /opt/naviserver/bin/nsd
fi

