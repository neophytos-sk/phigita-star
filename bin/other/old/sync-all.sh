RSYNCD_STATUS=`/etc/init.d/rsyncd status`
if [ $(expr match "$RSYNCD_STATUS" ".*status:\s*started.*") -eq 0 ]; then
    echo "start rsyncd"
    /etc/init.d/rsyncd start
    for i in {1..5}; do
        echo "sleeping... $i"
        sleep 1
    done
fi
echo "/web/bin/ssh-all.sh /web/bin/rsync.sh"
/web/bin/ssh-all.sh /web/bin/rsync.sh
