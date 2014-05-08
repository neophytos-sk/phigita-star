# 
# Server parameters 
# 
ns_section ns/server/${server_dns} 
ns_param EnableTclPages     Off
ns_param MaxBusyThreads     100
ns_param MaxWait            20
ns_param globalstats        false ;# nkd: Enable built-in statistics 
ns_param urlstats           false ;# nkd: Enable URL statistics 
ns_param maxurlstats        0     ;# nkd: Max number of URL's to do stats on


ns_param maxconnections    100 ;# GN:number of connections to be served by a connection thread before it restarts, the "maxconnections" setting can be tricky, since making it too large can cause your system to thrash. 
ns_param maxthreads        15
ns_param minthreads        3
ns_param connsperthread    1000
ns_param lowwatermark      10
ns_param highwatermark     100
#ns_param maxdropped        0
ns_param threadtimeout     120       ;# Idle threads die at this rate (used to be set to 1800)


# 
# Tcl Configuration 
# 
ns_section ns/server/${server_dns}/tcl
ns_param library            ${serverroot}/vhost-dns/tcl
ns_param autoclose 	      on 
ns_param debug 		      false
ns_param nsvbuckets           31 ;# TODO: make it 11
ns_param lazyloader           false ;# true for lazy loader
ns_param memoizecache         100000 ;# default is 10MB


#
# nsdns
#
ns_section  "ns/server/${server_dns}/module/nsdns"
ns_param        port            53 ;# 2525
ns_param        address         0.0.0.0 ;# localhost
ns_param        ttl             86400
ns_param        negativettl     3600
ns_param        readtimeout     30
ns_param        writetimeout    30
ns_param        proxytimeout    3
ns_param        proxyretries    2
ns_param        proxyhost       195.14.130.220 ;#localhost
ns_param        proxyport       53
ns_param        defaulthost     ""
ns_param        debug           0




#---------------------------------------------------------------------
# 
# Access log -- nslog 
# 
#---------------------------------------------------------------------
ns_section ns/server/${server_dns}/module/nslog 
#
# General parameters
#
ns_param   file         ${webroot}/log/access.${server_dns}.log

#ns_param   maxbuffer       100 ;# 0, number of logfile entries to keep in memory before flushing to disk
#
# Control what to log
#
#ns_param   suppressquery   true    ;# false, suppress query portion in log entry
#ns_param   logreqtime      true    ;# false, include time to service the request
ns_param    logpartialtimes true    ;# false, include high-res start time and partial request durations (accept, queue, filter, run)
#ns_param   formattedtime   true    ;# true, timestamps formatted or in secs (unix time)
#ns_param   logcombined     true    ;# true, Log in NSCA Combined Log Format (referer, user-agent)
ns_param   extendedheaders "COOKIE Host Referer X-Forwarded-For"  ;# space delimited list of HTTP heads to log per entry
ns_param   checkforproxy   true    ;# false, check for proxy header (X-Forwarded-For)
#
#
# Control log file rolling
#
#ns_param   maxbackup       100 ;# 10, max number of backup log files
#ns_param   rolllog     true    ;# true, should server log files automatically
#ns_param   rollhour        0   ;# 0, specify at which hour to roll
#ns_param   rollonsignal    true    ;# false, perform roll on a sighup
ns_param   rollfmt      %Y-%m-%d-%H:%M  ;# format appendend to log file name

# rolls the server log on the same basis as the access log 
# {server}/tcl/logroll.tcl depends on rollday, rollhour, rollfmt being set
ns_param rollday            *
ns_param rollhour           0


ns_section ns/server/${server_dns}/modules 
ns_param nslog          ${bindir}/nslog.so 
ns_param nsdns         ${bindir}/nsdns.so
