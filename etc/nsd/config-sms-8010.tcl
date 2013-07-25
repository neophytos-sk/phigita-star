ns_log notice "nsd.tcl: starting to read config file..."


set webroot               /web

set server		  service-phgt-0
set datasource		  aias::${server}
set user                  ${server}
set group                 web
set password              ${server}-662051
set servername            "Test Server" 
set email                 "webmaster@phigita.net"

set serverroot                "/web/${server}"

# 
# AOLserver's home and binary directories. Autoconfigurable. 
#
set homedir                   "/opt/naviserver/"
set bindir                    [file dirname [ns_info nsd]]
set libdir                    ${serverroot}/lib


set httpport              8010
set httpsport             8443 

# The hostname and address should be set to actual values.

if {1} {
    set hostname               sms
    set address                192.168.200.220 ;# 127.0.0.1;#0.0.0.0 ;# [ns_info address]
} else {
    set hostname               localhost;#[ns_info hostname]
    set address                127.0.0.1;#[ns_info address]
}



#
# Where are your pages going to live ?
#
set pageroot                ${serverroot}/www 
set directoryfile           index.adp,index.tcl,index.html,index.htm

# 
# Global server parameters 
#

ns_section ns/parameters 
ns_param User               ${user}
ns_param Group              ${group}
ns_param CounterLog         ${webroot}/log/counter.${httpport}.log
ns_param ServerLog          ${webroot}/log/error.${httpport}.log
ns_param   pidfile         ${webroot}/log/${server}.${httpport}.pid
ns_param Home               ${homedir} 
ns_param LogRoll            on
ns_param LogMaxBackup       64
ns_param maxkeepalive       12
ns_param keepalivetimeout   5
ns_param connsperthread     0
ns_param ReverseProxyMode 1




ns_param   progressminsize 10000 ;# deprecated, replaced by uploadsize
ns_param   uploadsize 10000

# Automatic adjustment of response content-type header to include charset
# This defaults to True.
ns_param        hackcontenttype         true

# Default output charset.  When none specified, no character encoding of
# output is performed.
ns_param        outputcharset           utf-8

# Default Charset for Url Encode/Decode. When none specified, no character
# set encoding is performed.
ns_param        urlcharset              utf-8

# This parameter supports output encoding arbitration.
ns_param  preferredcharsets             { utf-8 iso8859-1 }





# Unicode by default:
# see http://dqd.com/~mayoff/encoding-doc.html
#ns_param   HackContentType    true
#ns_param   DefaultCharset     utf-8
#ns_param   HttpOpenCharset    utf-8
#ns_param   OutputCharset      utf-8
#ns_param   URLCharset         utf-8
#ns_param SystemEncoding utf-8
# This parameter supports output        encoding arbitration.
#ns_param  PreferredCharsets { utf-8 iso8859-7 } ;



# SMTP
#ns_param mailhost           localhost
ns_param mailhost            mail.phigita.net
#ns_param smtphost           localhost
#ns_param smtpport           25
#ns_param smtptimeout        60

# DNS tuning
ns_param   dnscache        false      ;# In-memory cache of DNS lookups
ns_param   dnscachetimeout 60        ;# How long to keep hostnames in cache

ns_param debug off

# 
# Thread library (nsthread) parameters 
# 
ns_section ns/threads 
ns_param mutexmeter         false      ;# nkd: measure lock contention 
ns_param SystemScope        on
ns_param stacksize          [expr {128*1024}] ;#1024000 ;# 2048000 ;# 8192000


ns_section ns/server/${server}/ttrace
ns_param        enabletraces            false


# 
# MIME types. 
# 
#  Note: AOLserver already has an exhaustive list of MIME types, but in
#  case something is missing you can add it here. 
#

ns_section ns/server/${server}/MimeTypes
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
ns_section ns/server/${server}/tcl
ns_param initfile ${bindir}/init-4.99.1.tcl
#ns_param initfile ${bindir}/init.tcl
ns_param Library            ${serverroot}/tcl
ns_param autoclose 	      on 
ns_param debug 		      false
ns_param nsvbuckets           128
ns_param lazyloader           false ;# true for lazy loader

############################################################ 
# 
# Server-level configuration 
# 
#  There is only one server in AOLserver, but this is helpful when multiple
#  servers share the same configuration file.  This file assumes that only
#  one server is in use so it is set at the top in the "server" Tcl variable
#  Other host-specific values are set up above as Tcl variables, too.
# 
ns_section ns/servers 
ns_param $server     $servername 

# 
# Server parameters 
# 
ns_section ns/server/${server} 
ns_param is_crawler_p       no
ns_param is_sms_p           yes
ns_param is_mail_p           no
ns_param is_ping_p           no

ns_param pageroot           ${pageroot}
ns_param DirectoryFile      ${directoryfile}
ns_param Webmaster          ${email}
ns_param NoticeBgColor      {"#ffffff"}
ns_param EnableTclPages     Off
ns_param MaxBusyThreads     100
ns_param MaxWait            20
ns_param globalstats        false ;# nkd: Enable built-in statistics 
ns_param urlstats           false ;# nkd: Enable URL statistics 
ns_param maxurlstats        0     ;# nkd: Max number of URL's to do stats on
#ns_param directoryadp    $pageroot/dirlist.adp ;# Choose one or the other
#ns_param directoryproc    _ns_dirlist           ;#  ...but not both!
#ns_param directorylisting  fancy                ;# Can be simple or fancy

ns_param MaxThreads        120
ns_param MinThreads        40
ns_param MaxConnections    240
ns_param MaxDropped        0

# Miscellaneous
ns_param   checkmodifiedsince true   ;# Check url if no If-Modified-Since?

# Limits (PWS 4.0)
#ns_param maxheaders      16384     ;# Max no. of headers from client 
#ns_param maxline         8192      ;# Max line length from client
#ns_param maxpost          65536 ;# 65536     ;# Max bytes on a POST
#ns_param sendfdthreshold 2048      ;# Min size of file descriptor to send


#
# Fastpath serves HTML
#
ns_section "ns/server/${servername}/fastpath"
ns_param   cache           true      ;# Enable cache for normal URLs
ns_param   cachemaxentry   8192      ;# Largest file size allowable in cache
ns_param   cachemaxsize    [expr 8*1024*1024] ;# Size of fastpath cache
ns_param   mmap            false     ;# Use mmap() for cache


# 
# ADP (AOLserver Dynamic Page) configuration 
# 
ns_section "ns/server/${server}/adp"

# ADP features
ns_param DefaultParser fancy       ;# nkd:
ns_param map           "/*.adp"  ;# Extensions to parse as ADP's
#ns_param map           "/*.html" ;# Any extension can be mapped
ns_param enableexpire  true      ;# Set "Expires: now" on all ADP's
ns_param enabledebug   false     ;# Turn on Tclpro debugging with "?debug"


#
# Internal redirects
#
ns_section "ns/server/${server}/redirects"
ns_param 404 "/global/notfound.adp"      ;# Not Found error page
ns_param 403 "/global/forbidden.adp"     ;# Forbidden error page
ns_param 500 "/global/servererror.adp"   ;# Server error page


# 
# Database drivers 
# The database driver is specified here. PostgreSQL driver being loaded.
# Make sure you have the driver compiled and put it in {aolserverdir}/bin
#
ns_section "ns/db/drivers" 
ns_param postgres        ${bindir}/nsdbpg.so  ;# nkd: Load PostgreSQL driver


set comment {
ns_section ns/server/${server}/acs/database
ns_param database_names [list main news books]
ns_param pools_main  [list pool1 pool2 pool3]
ns_param pools_news [list pool4_newsdb]
ns_param pools_books [list pool5_bookdb]
}

# 
# Database Pools: This is how AOLserver  ``talks'' to the RDBMS. You need three for
# OpenACS: main, log, subquery. Make sure to replace ``yourdb'' and ``yourpassword''
# with the actual values for your db name and the password for it.
# AOLserver can have different pools connecting to different databases and even different
# different database servers.
# 
ns_section ns/db/pools 
ns_param main       "Main Pool" 
ns_param 00-pool2        "Log Pool" 
ns_param 00-pool3   "Subquery Pool"
#ns_param newsdb "NewsDB Pool"
#ns_param bookdb "BookDB Pool"
ns_param echodb "EchoDB Pool"

ns_section ns/db/pool/main
ns_param MaxIdle            0
ns_param MaxOpen            0
ns_param Connections        18
ns_param Verbose            Off
ns_param ExtendedTableInfo  On
ns_param LogSQLErrors       Off 
ns_param Driver             postgres 
ns_param DataSource         ${datasource}
ns_param User               ${user}
ns_param Password           ${password}


ns_section ns/db/pool/00-pool2 
ns_param MaxIdle            0
ns_param MaxOpen            0
ns_param Connections        3
ns_param Verbose            Off
ns_param ExtendedTableInfo  On
ns_param LogSQLErrors       Off 
ns_param Driver             postgres
ns_param DataSource         ${datasource}
ns_param User               ${user}
ns_param Password           ${password}

ns_section ns/db/pool/00-pool3
ns_param MaxIdle            0
ns_param MaxOpen            0
ns_param Connections        3
ns_param Verbose            Off
ns_param ExtendedTableInfo  On
ns_param LogSQLErrors       Off
ns_param Driver             postgres
ns_param DataSource         ${datasource}
ns_param User               ${user}
ns_param Password           ${password}

set datasource aias::bookdb
ns_section ns/db/pool/bookdb
ns_param maxidle            0
ns_param maxopen            0
ns_param Connections        8
ns_param Verbose            Off
ns_param ExtendedTableInfo  On
ns_param LogSQLErrors       Off
ns_param Driver             postgres
ns_param DataSource         ${datasource}
ns_param User               ${user}
ns_param Password           ${password}

set COMMENT {
    set datasource aias::newsdb
    set user postgres
    set password ""
    ns_section ns/db/pool/newsdb 
    ns_param MaxIdle            0
    ns_param MaxOpen            0
    ns_param Connections        18
    ns_param Verbose            Off
    ns_param ExtendedTableInfo  On
    ns_param LogSQLErrors       Off
    ns_param Driver             postgres
    ns_param DataSource         ${datasource}
    ns_param User               ${user}
    ns_param Password           ${password}
}

#set datasource aias::echodb
#set datasource mars::echodb
set datasource aias::service-phgt-0
set user postgres
set password ""
ns_section ns/db/pool/echodb 
ns_param MaxIdle            0
ns_param MaxOpen            0
ns_param Connections        18
ns_param Verbose            Off
ns_param ExtendedTableInfo  On
ns_param LogSQLErrors       Off
ns_param Driver             postgres
ns_param DataSource         ${datasource}
ns_param User               ${user}
ns_param Password           ${password}

ns_section ns/server/${server}/db
#ns_param Pools              "*" 
#ns_param Pools              "main,00-pool2,00-pool3,bookdb,newsdb"
ns_param Pools              "main,00-pool2,00-pool3,bookdb,echodb"
ns_param defaultpool        main





#
# ldap pool ldap
#
ns_section      "ns/ldap/pool/ldap"
   ns_param        user           "cn=Manager, dc=phigita, dc=net"
   ns_param        password       "secret"
   ns_param        host           "localhost"
   ns_param        connections    1
   ns_param        verbose        on

#
# ldap pools
#
ns_section "ns/ldap/pools"
   ns_param ldap ldap

ns_section "ns/server/${server}/ldap"
   ns_param Pools *
   ns_param DefaultPool ldap







# 
# Socket driver module (HTTP)  -- nssock 
# 
ns_section ns/server/${server}/module/nssock
ns_param timeout            120
ns_param address            ${address}   ;# nkd:
ns_param hostname           ${hostname}  ;# nkd:
ns_param port               ${httpport}  ;# nkd:

# keepwait default: 30
# ns_param keepwait 30

# writersize default: 1024*1024
# ns_param writersize [expr {1024*1024}]


# Max upload size
#ns_param        maxinput                [expr {3 * 1024 * 1024}]
ns_param        maxinput                [expr {512 * 1024 * 1024}] ;# TEST TEST TEST

# Max line size
ns_param        maxline                 4096

# Read-ahead buffer size
ns_param        bufsize                 16384

# Max upload size when to use spooler
ns_param        readahead               16384

# Number of spooler threads
ns_param        spoolerthreads          4

# Number of writer threads
ns_param        writerthreads           4

# Read from file in bufsize chunks.
ns_param        writerbufsize           8192

# Min return file size when to use writer
ns_param        writersize              100000 ;# 1048576

# Timed-out waiting for complete request.
ns_param        readtimeoutlogging      false

# Unable to match request to a virtual server.
ns_param        serverrejectlogging     false

# Malformed request, or would exceed request limits.
ns_param        sockerrorlogging        false

# Error while attempting to shutdown a socket during connection close.
ns_param        sockshuterrorlogging    false

# Number of requests to accept at once
ns_param        acceptsize              100

# Max numbrer of sockets in the driver queue
ns_param        maxqueuesize            256




ns_param recvwait [expr 10 * 60]
ns_param maxsock 999 



#ns_limits set default -maxrun 999
#ns_limits set default -maxwait 999
#ns_pools set default -maxthreads 999
#ns_pools set default -maxconns 999




# 
# Access log -- nslog 
# 
ns_section ns/server/${server}/module/nslog 
ns_param logreqtime true
ns_param EnableHostnameLookup Off
ns_param File               ${webroot}/log/access.${httpport}.log
ns_param LogCombined        On
ns_param LogRefer           Off
ns_param LogUserAgent       Off
ns_param MaxBackup          180
ns_param RollDay            *
ns_param RollFmt            %Y-%m-%d-%H:%M
ns_param RollHour           0
ns_param RollOnSignal       On
ns_param RollLog            On
ns_param suppressquery      Off
ns_param maxbuffer          100   ;# nkd: How many access.log entries should be buffered before
                                  ;# writing to disk.  Default is zero.  Anything <= 0
                                  ;# means "write every line".
ns_param   extendedheaders COOKIE



ns_section      ns/server/${server}/module/nsimap
ns_param	idle_timeout	1800
ns_param	debug		0
#ns_param	mailbox		""
#ns_param	user		""
#ns_param	password	""


ns_section      "ns/server/${server}/module/nsclamav"
   ns_param        dbdir          /var/lib/clamav
   ns_param        maxfiles       1000
   ns_param        maxfilesize    10485760
   ns_param        maxreclevel    5
   ns_param        maxratio       200
   ns_param        archivememlim  0


ns_section      ns/server/${server}/module/nsdns
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




# SSL contexts. Define the ssl contexts for this server.

ns_section "ns/server/${server}/module/nsopenssl/sslcontexts"
ns_param ssl_incoming_requests_context   "SSL context used for regular user access to the website"

ns_section "ns/server/${server}/module/nsopenssl/defaults"
ns_param server               ssl_incoming_requests_context

ns_section "ns/server/${server}/module/nsopenssl/sslcontext/ssl_incoming_requests_context"
ns_param Role                  server
ns_param ModuleDir             ${serverroot}/etc/certs
ns_param CertFile              certfile.pem
ns_param KeyFile               keyfile.pem
#ns_param CADir                 ca-client/dir
#ns_param CAFile                ca-client/ca-client.crt
ns_param Protocols             "SSLv3, TLSv1"
ns_param CipherSuite           "ALL:!ADH:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP"
ns_param PeerVerify            false
ns_param PeerVerifyDepth       3
ns_param Trace                 false


# SSL drivers. Each driver defines a port and a named SSL context to associate with it.

ns_section "ns/server/${server}/module/nsopenssl/ssldrivers"
ns_param ssl_incoming_requests_driver "Driver for regular user access to the website"
#ns_param ssl_outgoing_requests_driver "Driver for outgoing requests"

ns_section "ns/server/${server}/module/nsopenssl/ssldriver/ssl_incoming_requests_driver"
ns_param sslcontext            ssl_incoming_requests_context
ns_param port                  $httpsport
ns_param hostname              $hostname
ns_param address               $address
ns_param   maxinput            [expr 1024 * 1024 * 100]
ns_param recvwait              [expr 15 * 60]





ns_section ns/server/${server}/module/nsjabber
ns_param jid              admin@phigita.net/Resource
ns_param pw               6CA39F76D51064A86EB4DB9ACFDEA7C5FB34CB26
ns_param jabber_server    phigita.net




#
# nsjava - aolserver module that embeds a java virtual machine. 

ns_section ns/server/${server}/module/nsjava
ns_param EnableJava         on  ;# Set to on to enable nsjava.
ns_param VerboseJvm         off  ;# Same as command line -debug.
ns_param LogLevel           Debug
ns_param DestroyJvm         on  ;# Destroy jvm on shutdown.
ns_param DisableJITCompiler off  
ns_param ClassPath          /usr/local/aolserver/bin/nsjava.jar:/web/phigitanet/packages/search/java/googleapi.jar

# 
# CGI interface -- nscgi, if you have legacy stuff. Tcl or ADP files inside 
# AOLserver are vastly superior to CGIs. I haven't tested these params but they
# should be right.
# 
# ns_section "ns/server/${server}/module/nscgi" 
#       ns_param   map "GET  /cgi-bin/ /web/$server/www/cgi-bin"
#       ns_param   map "POST /cgi-bin/ /web/$server/www/cgi-bin" 
#       ns_param   Interps CGIinterps

# ns_section "ns/interps/CGIinterps" 
#       ns_param .pl "/usr/bin/perl"

# 
# Modules to load 
# 
ns_section ns/server/${server}/modules 
ns_param nsdb            ${bindir}/nsdb.so
ns_param nssock          ${bindir}/nssock.so 
ns_param nslog           ${bindir}/nslog.so 
ns_param nsproxy         ${bindir}/nsproxy.so
ns_param qcluster        qcluster.so
ns_param smsq.so         smsq.so
ns_param generic-gsm.so  generic-gsm.so



ns_param libthread       ${homedir}/lib/thread2.6.5/libthread2.6.5.so

ns_param xo_utils       ${bindir}/xo_utils.so

#ns_param libttext        ${bindir}/libttext0.4.so
#ns_param libjsmin        ${bindir}/libjsmin0.2.so
#ns_param nsgd            ${bindir}/nsgd2.so
#ns_param nsaspell        ${bindir}/nsaspell.so
#ns_param nsclamav        ${bindir}/nsclamav.so
#ns_param nsimap          ${bindir}/nsimap.so


#ns_param nsldap          ${bindir}/nsldap.so
#ns_param nsreturnz       ${bindir}/nsreturnz.so
#ns_param nsdns           ${bindir}/nsdns.so
#ns_param nsotcl          ${bindir}/nsotcl.so

#ns_param nsrewrite       ${bindir}/nsrewrite.so 
#ns_param nsjabber        ${bindir}/nsjabber.so
#ns_param nsjava          ${bindir}/libnsjava.so
#ns_param php ${bindir}/libphp4.so
#ns_param ns_scheme       ${bindir}/ns_scheme.so 
#ns_param nsxml           ${bindir}/nsxml.so 
#ns_param nsfts           ${bindir}/nsfts.so
#ns_param nsperm          ${bindir}/nsperm.so 
#ns_param nscgi           ${bindir}/nscgi.so 
#ns_param dqd_utils       ${bindir}/dqd_utils8.so
#ns_param nsopenssl       ${bindir}/nsopenssl.so
#ns_param nsreturnb       ${bindir}/nsreturnb.so








ns_section      "ns/server/${server}/module/qcluster"
ns_param        address                 127.0.0.1
ns_param        port                    8787
ns_param        iam                     127.0.0.1

ns_section      "ns/server/${server}/module/qcluster/groups"
ns_param        group                  "incoming"
ns_param        group                  "outgoing"

ns_section      "ns/server/${server}/module/qcluster/cluster"
ns_param        member                 "127.0.0.1"
















# ns_section "ns/server/${server}/module/php"
#         ns_param map *.php






#
# Tcl Proxy module -- nsproxy
#
# Below is the list of all supported configuration options
# for the nsproxy module filled in with their default values.
# This list of default values is also compiled in the code
# in case you ommit the ns_param lines.
#

ns_section  "ns/server/${servername}/module/nsproxy"

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

ns_section "ns/limits"
ns_param default         "Default Limits" ;# Defines a limit.

ns_section "ns/limit/default"
ns_param maxrun          100       ;# Conn threads running for limit.
ns_param maxwait         100       ;# Conn threads waiting for limit.
ns_param maxupload       102400000 ;# Max size of file upload in bytes.
ns_param timeout         60        ;# Total seconds to wait for resources.

ns_section "ns/server/${servername}/limits"
ns_param default         "GET  /*" ;# Map default limit to URL.
ns_param default         "POST /*"
ns_param default         "HEAD /*"



ns_log notice "nsd.tcl: finished reading config file."
