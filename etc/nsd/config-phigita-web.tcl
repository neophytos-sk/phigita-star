ns_log notice "nsd.tcl: starting to read config file..."


# 
# Server parameters 
# 
ns_section ns/server/${server_web} 
        ns_param   directoryfile	$directoryfile

	#
	# Scaling and Tuning Options
	#
	#ns_param   maxconnections	100	;# 100, number of allocated connection stuctures
	ns_param   maxthreads		$maxthreads	;# 10, maximal number of connection threads
	ns_param   minthreads           $minthreads	;# 1, minimal number of connection threads
	ns_param   connsperthread	$connsperthread	;# 0, number of connections (requests) handled per thread
	#ns_param   threadtimeout	120	;# 120, timeout for idle theads
	#ns_param   spread		0	;# 20, spread factor in percent for varying connsperthread and threadtimeout
        ns_param lowwatermark   10  ;# create additional threads when more than this percentage of requests are in the queue
        ns_param highwatermark 100  ;# 80; allow concurrent creates when queue is fully beyond this percentage
                                                ;# 100 is a conservative value, disabling concurrent creates
	#
	# Directory listing options
	#
	#ns_param   directoryadp	$pageroot/dirlist.adp ;# Choose one or the other
	#ns_param   directoryproc	_ns_dirlist           ;#  ...but not both!
	#ns_param   directorylisting	fancy                 ;# Can be simple or fancy

	#
	# Compress response character data: ns_return, ADP etc.
	#
        ns_param    compressenable      on	;# false, use "ns_conn compress" to override
	ns_param    compresslevel       9	;# 4, 1-9 where 9 is high compression, high overhead
	#ns_param    compressminsize     512	;# Compress responses larger than this

	#
	# Configuration of replies
	#
	#ns_param    realm     		yourrealm	;# Default realm for Basic authentication
	#ns_param    noticedetail	false	;# true, return detail information in server reply
	#ns_param    errorminsize	0	;# 514, fillup reply to at least specified bytes (for ?early? MSIE)
	#ns_param    headercase		preserve;# preserve, might be "tolower" or "toupper"
	#ns_param    checkmodifiedsince	false	;# true, check modified-since before returning files from cache. Disable for speedup

	#
	# Application Options
	#
ns_param performance_mode_p ${performance_mode_p}
        ns_param production_mode_p ${production_mode_p}
	ns_param is_crawler_p       no
	ns_param is_sms_p           no
	ns_param is_mail_p          yes
        ns_param is_mail_server_p   $is_mail_server_p  ;# process_incoming_mail
	ns_param is_ping_p          no
	ns_param is_chat_p          no
	ns_param start_request_monitor_p         1
	ns_param storage_port       $storage_port

ns_param listening_to_host {
    www.phigita.net
    my.phigita.net
    books.phigita.net
    remarks.phigita.net
    blogs.phigita.net
    video.phigita.net
    echo.phigita.net
    answers.phigita.net
}

	
	ns_param pagedir           ${pagedir}
	ns_param Webmaster          ${email}
	ns_param NoticeBgColor      {"#ffffff"}
	ns_param EnableTclPages     Off









#
# Connection Thread Pools
#
ns_section "ns/server/${server_web}/pools"
ns_param monitor "Monitor pool"

ns_section "ns/server/${server_web}/pool/monitor"
ns_param   minthreads 1
ns_param   maxthreads 1
ns_param   map "GET /admin/monitor/"
ns_param   map "GET /SYSTEM"
ns_param   map "GET /ds"
ns_param   map "POST /ds"


ns_section ns/server/${server_web}/ttrace
ns_param        enabletraces            false


# 
# MIME types. 
# 
#  Note: AOLserver already has an exhaustive list of MIME types, but in
#  case something is missing you can add it here. 
#

ns_section ns/server/${server_web}/MimeTypes
ns_param Default            text/plain
ns_param NoExtension        text/plain
ns_param .gif               image/gif
ns_param .png               image/png
ns_param .jpg               image/jpeg
ns_param .jpeg              image/jpeg
ns_param .pcd               image/x-photo-cd
ns_param .prc               application/x-pilot
ns_param .xls               application/vnd.ms-excel
ns_param .ico               image/ico

# 
# Tcl Configuration 
# 
ns_section ns/server/${server_web}/tcl
ns_param initfile ${bindir}/init.tcl
ns_param library            ${serverroot}/tcl
ns_param autoclose 	      on 
ns_param debug 		      false
ns_param nsvbuckets           31 ;# used to be 251
ns_param lazyloader           false ;# true for lazy loader
ns_param memoizecache         100000 ;# default is 10MB

############################################################ 
# 
# Server-level configuration 
# 
#  There is only one server in AOLserver, but this is helpful when multiple
#  servers share the same configuration file.  This file assumes that only
#  one server is in use so it is set at the top in the "server" Tcl variable
#  Other host-specific values are set up above as Tcl variables, too.
# 




# 
# ADP (AOLserver Dynamic Page) configuration 
# 
ns_section "ns/server/${server_web}/adp"

# ADP features
ns_param defaultparser fancy
ns_param map           "/*.adp"  ;# Extensions to parse as ADP's

# causes 404 to be returned for static html files
#ns_param map           "/*.html" ;# Any extension can be mapped
ns_param enableexpire  true      ;# Set "Expires: now" on all ADP's
ns_param enabledebug   false     ;# Turn on Tclpro debugging with "?debug"



#
# Internal redirects
#
#ns_section "ns/server/${server_web}/redirects"
#ns_param 404 "/global/notfound.adp"      ;# Not Found error page
#ns_param 403 "/global/forbidden.adp"     ;# Forbidden error page
#ns_param 500 "/global/servererror.adp"   ;# Server error page


# 
# Database drivers 
# The database driver is specified here. PostgreSQL driver being loaded.
# Make sure you have the driver compiled and put it in {aolserverdir}/bin
#
ns_section "ns/db/drivers" 
ns_param postgres        ${bindir}/nsdbpg.so


# 
# Database Pools: This is how AOLserver  ``talks'' to the RDBMS. You need three for
# OpenACS: main, log, subquery. Make sure to replace ``yourdb'' and ``yourpassword''
# with the actual values for your db name and the password for it.
# AOLserver can have different pools connecting to different databases and even different
# different database servers.
# 
ns_section ns/db/pools 
ns_param main   "main pool" 
ns_param bookdb "bookdb pool"


ns_section ns/db/pool/main
ns_param connections        ${db_pool_connections}
ns_param verbose            ${debug}
ns_param extendedtableinfo  1
ns_param logsqlerrors       ${debug}
ns_param driver             postgres
ns_param dataSource         ${datasource}
ns_param user               ${user}
ns_param password           ${password}

set datasource localhost::bookdb
ns_section ns/db/pool/bookdb
ns_param connections        ${db_pool_connections}
ns_param verbose            ${debug}
ns_param extendedtableinfo  1
ns_param logsqlerrors       ${debug}
ns_param driver             postgres
ns_param dataSource         ${datasource}
ns_param user               ${user}
ns_param password           ${password}

ns_section ns/server/${server_web}/db
ns_param pools              "main,bookdb"
ns_param defaultpool        "main"









#---------------------------------------------------------------------
# 
# Access log -- nslog 
# 
#---------------------------------------------------------------------
ns_section ns/server/${server_web}/module/nslog 
    #
    # General parameters
    #
    ns_param   file         ${webroot}/log/access.${httpport}.log

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



ns_section      ns/server/${server_web}/module/nsimap
ns_param	idle_timeout	1800
ns_param	debug		0
#ns_param	mailbox		""
#ns_param	user		""
#ns_param	password	""


ns_section      "ns/server/${server_web}/module/nsclamav"
   ns_param        dbdir          /var/lib/clamav
   ns_param        maxfiles       1000
   ns_param        maxfilesize    10485760
   ns_param        maxreclevel    5
   ns_param        maxratio       200
   ns_param        archivememlim  0


ns_section      ns/server/${server_web}/module/nsdns
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



#
# SSL
#

ns_section    "ns/server/${server_web}/module/nsssl"
       # cat host.cert host.key > server.pem
       ns_param      certificate	/web/data/ssl/phigita.net.pem ;# $serverroot/etc/next-scripting.org.pem
       ns_param      address    	$address
       ns_param      port       	$httpsport
       #ns_param      ciphers    	"ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP"
       #ns_param      ciphers    	"ECDHE-RSA-RC4-SHA:RC4+SHA1+RSA"
       ns_param      ciphers            "RC4:HIGH:!aNULL:!MD5;"
       ns_param      protocols          "!SSLv2"
       ns_param      verify     	0
       ns_param      writerthreads      5 
       ns_param      writersize         10
       ns_param	     writerbufsize	16384	;# 8192, buffer size for writer threads
       ns_param	     writerstreaming	false	;# false
       ns_param      deferaccept	true    ;# false, Performance optimization,



#
# Example: Control port configuration.
#
#  To enable:
#
#  1. Define an address and port to listen on. For security
#     reasons listening on any port other then 127.0.0.1 is
#     not recommended.
#
#  2. Decided whether or not you wish to enable features such
#     as password echoing at login time, and command logging.
#
#  3. Add a list of authorized users and passwords. The entires
#     take the following format:
#
#     <user>:<encryptedPassword>:
#
#     You can use the ns_crypt Tcl command to generate an encrypted
#     password. The ns_crypt command uses the same algorithm as the
#     Unix crypt(3) command. You could also use passwords from the
#     /etc/passwd file.
#
#     The first two characters of the password are the salt - they can be
#     anything since the salt is used to simply introduce disorder into
#     the encoding algorithm.
#
#     ns_crypt <key> <salt>
#     ns_crypt x t2
#
#     The configuration example below adds the user "nsadmin" with a
#     password of "x".
#
#  4. Make sure the nscp.so module is loaded in the modules section.
#

ns_section      "ns/server/${server_web}/module/nscp"
ns_param        address                 127.0.0.1
ns_param        port                    9999
ns_param        echopassword            true
ns_param        cpcmdlogging            false

ns_section      "ns/server/${server_web}/module/nscp/users"
ns_param        user                    "nsadmin:t2GqvvaiIUbF2:"

# 
# Modules to load 
# 
ns_section ns/server/${server_web}/modules 
ns_param nslog           ${bindir}/nslog.so 
ns_param nsdb            ${bindir}/nsdb.so
ns_param nsproxy         ${bindir}/nsproxy.so
ns_param nsaspell        ${bindir}/nsaspell.so
#ns_param nsssl           ${bindir}/nsssl.so
if { !${production_mode_p} } {
    ns_param nscp         ${bindir}/nscp.so
}

#
# Determine, if libthread is installed
#
set libthread [glob -nocomplain ${bindir}/../lib/thread*/libthread*[info sharedlibextension]]
if {[llength $libthread] == 0} {
  ns_log notice "No Tcl thread library installed in ${bindir}/../lib/"
} else {
  if {[llength $libthread] > 1} {
    ns_log notice "Multiple Tcl thread libraries installed: $libthread"
  }
    ns_param libthread [lindex $libthread end]
  ns_log notice "Use Tcl thread library [lindex $libthread end]"
}

#ns_param qcluster        qcluster.so
#ns_param smsq.so         smsq.so
#ns_param generic-gsm.so  generic-gsm.so

#ns_param nsclamav        ${bindir}/nsclamav.so
#ns_param nsimap          ${bindir}/nsimap.so
#ns_param nsdns           ${bindir}/nsdns.so
#ns_param nsperm          ${bindir}/nsperm.so 




ns_section      "ns/server/${server_web}/module/qcluster"
ns_param        address                 127.0.0.1
ns_param        port                    8787
ns_param        iam                     127.0.0.1

ns_section      "ns/server/${server_web}/module/qcluster/groups"
ns_param        group                  "incoming"
ns_param        group                  "outgoing"

ns_section      "ns/server/${server_web}/module/qcluster/cluster"
ns_param        member                 "127.0.0.1"



#
# Tcl Proxy module -- nsproxy
#
# Below is the list of all supported configuration options
# for the nsproxy module filled in with their default values.
# This list of default values is also compiled in the code
# in case you ommit the ns_param lines.
#

ns_section  "ns/server/${server_web}/module/nsproxy"

ns_param    exec            ${homedir}/bin/nsproxy ; # Proxy program to start
ns_param    evaltimeout     0       ; # Timeout (ms) when evaluating scripts
ns_param    gettimeout      0       ; # Timeout (ms) when getting proxy handles
ns_param    sendtimeout     5000    ; # Timeout (ms) to send data
ns_param    recvtimeout     5000    ; # Timeout (ms) to receive results
ns_param    waittimeout     1000    ; # Timeout (ms) to wait for slaveis to die
ns_param    idletimeout     300000  ; # Timeout (ms) for a slave to live idle
ns_param    maxslaves       8       ; # Max number of allowed slaves alive


#
# Limits support
#
# Connection limits can be bundled together into a
# named set of limits and then applied to a subset of the URL
# hierarchy. The max number of connection threads running and waiting to
# run a URL, the max upload file size, and the max time a connection
# should wait to run are all configurable.
#


ns_section "ns/server/${server_web}/limits"
ns_param default         "GET  /*" ;# Map default limit to URL.
ns_param default         "POST /*"
ns_param default         "HEAD /*"



ns_log notice "nsd.tcl: finished reading config file."
