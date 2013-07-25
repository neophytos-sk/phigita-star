#!/bin/sh

# the next line restarts using tclsh, the trailing slash is intentional \
exec /usr/bin/tclsh "$0" "$@"

set servicename service0
set url http://www.phigita.net/SYSTEM/status

set status [exec -- /bin/sh -c "wget -q -O - ${url} || exit 0" 2> /dev/null]

if {{ok} ne ${status}} {
    exec -- /bin/sh -c "svc -ut /service/${servicename} || exit 0" 2> /dev/null
    exec -- /bin/sh -c "killall -9 /opt/naviserver/bin/nsd || exit 0" 2> /dev/null
}

