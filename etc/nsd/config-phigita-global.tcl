ns_section ns/servers 
ns_param $server_web    $servername_web
ns_param $server_static $servername_static
if { {nssmtpd} in ${modules} } {
    ns_param $server_mail   $servername_mail
}



ns_section ns/module/nssock
ns_param port $httpport
ns_param hostname $hostname
ns_param address $address
ns_param defaultserver $server_web
#ns_param address            ${address}
#ns_param hostname           ${hostname}
#ns_param port               ${httpport}

ns_param   maxinput     [expr {$max_file_upload_mb * 1024 * 1024}] ;# 1024*1024, maximum size for inputs
ns_param   recvwait     [expr {$max_file_upload_min * 60}] ;# 30, timeout for receive operations

#ns_param   maxline     8192    ;# 8192, max size of a header line
#ns_param   maxheaders      128 ;# 128, max number of header lines
#ns_param   uploadpath      /tmp    ;# directory for uploads
#ns_param   backlog     256 ;# 256, backlog for listen operations
#ns_param   maxqueuesize    256 ;# 1024, maximum size of the queue
ns_param   acceptsize      100 ;# 10  ;# value of "backlog", max number of accepted (but unqueued) requests
#ns_param   deferaccept         true    ;# false, Performance optimization, may cause recvwait to be ignored
#ns_param   bufsize     16384   ;# 16384, buffersize
# when to use spooler
#ns_param   readahead       16384   ;# value of bufsize, size of readahead for requests
#ns_param   sendwait        30  ;# 30, timeout in seconds for send operations
#ns_param   closewait       2   ;# 2, timeout in seconds for close on socket
#ns_param   keepwait        2   ;# 5, timeout in seconds for keep-alive
#ns_param   nodelay     true    ;# false; activate TCP_NODELAY if not activated per default on your OS
#ns_param   keepalivemaxuploadsize  500000  ;# 0, don't allow keep-alive for upload content larger than this
#ns_param   keepalivemaxdownloadsize    1000000 ;# 0, don't allow keep-alive for download content larger than this
#
# Spooling Threads
#
ns_param   spoolerthreads  4   ;# 0, number of upload spooler threads
ns_param   maxupload       [expr {$max_file_upload_mb * 1024 * 1024}]   ;# 0, when specified, spool uploads larger than this value to a temp file
ns_param   writerthreads   8   ;# 0, number of writer threads
ns_param   writersize      [expr {2*1024}] ;# 4096    ;# 1024*1024, use writer threads for files larger than this value
ns_param   writerbufsize   [expr {2*8192}]    ;# 8192, buffer size for writer threads
#ns_param   writerstreaming true    ;# false;  activate writer for streaming HTML output (e.g. ns_writer)
ns_param timeout            120

# Timed-out waiting for complete request.
ns_param        readtimeoutlogging      false

# Unable to match request to a virtual server.
ns_param        serverrejectlogging     false

# Malformed request, or would exceed request limits.
ns_param        sockerrorlogging        false

# Error while attempting to shutdown a socket during connection close.
ns_param        sockshuterrorlogging    false
ns_param maxsock 999 


# 
# Socket driver module (HTTP)  -- nssock 
# 
ns_section ns/module/nssock/servers
ns_param $server_web      ${hostname}:$httpport
ns_param $server_static   ${server_static_host_and_port}

#
# SSL
#

ns_section    "ns/module/nsssl"
       # cat host.cert host.key > server.pem
       ns_param      certificate	/web/data/ssl/phigita.net.pem ;# $serverroot/etc/next-scripting.org.pem
ns_param      defaultserver     $server_web
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


#ns_section ns/module/nsssl/servers
#ns_param $server_web    ${hostname}:$httpsport
#ns_param $server_static   ${server_secure_static_host_and_port}


ns_section ns/modules 
ns_param nssock          ${bindir}/nssock.so 
ns_param nsssl          ${bindir}/nsssl.so 







ns_section      "ns/fastpath"
##ns_param        serverdir      ""       ;# default: ""
ns_param        pagedir        "/web/data/build/resources"       ;# default: "pages"
##ns_param        cache          true     ;# default: false
##ns_param        cachemaxsize   10240000  ;# default: 1024*10000
##ns_param        cachemaxentry  8192      ;# default: 8192
ns_param        mmap             true     ;# default: false
#ns_param        directoryfile    ""       ;# index.adp index.tcl index.html index.htm
#ns_param        directorylisting "false"     ;# default: simple => _ns_dirlist for directoryproc
#ns_param        directoryproc    ""          ;# if directorylisting=simple, default is _ns_dirlist
#ns_param        directoryadp     ""


#---------------------------------------------------------------------
#
# NaviServer's directories. Autoconfigurable. 
#
#---------------------------------------------------------------------

# 
# Global server parameters 
#

ns_section ns/parameters 
ns_param user               ${user}
ns_param group              ${group}
ns_param counterlog         ${webroot}/log/counter.${httpport}.log
ns_param serverlog          ${webroot}/log/error.${httpport}.log
ns_param pidfile            ${webroot}/log/nsd.${httpport}.pid
ns_param home               ${homedir} 
ns_param debug              $debug

ns_param logroll            on
ns_param logmaxbackup       64
#ns_param   maxbackup   100
#ns_param   maxbackup   100
ns_param   logdebug     $debug
ns_param   logdev       $dev

#ns_param   mailhost    localhost 
#ns_param   jobsperthread   0
#ns_param   jobtimeout  300
#ns_param   schedsperthread 0


# Write asynchronously to log files (access log and error log)
ns_param   asynclogwriter  true    ;# false

# Enforce sequential thread initialization. This is not really
# desirably in general, but might be useful for hunting strange
# crashes or for debugging with valgrind.
# ns_param        tclinitlock         true	       ;# default: false



ns_param ReverseProxyMode   0

# Automatic adjustment of response content-type header to include charset
# This defaults to True.
ns_param hackcontenttype         true

# Default output charset.  When none specified, no character encoding of
# output is performed.
ns_param outputcharset           utf-8

# Default Charset for Url Encode/Decode. When none specified, no character
# set encoding is performed.
ns_param urlcharset              utf-8

# This parameter supports output encoding arbitration.
ns_param preferredcharsets             { utf-8 iso8859-1 }
ns_param mailhost            mail.phigita.net

# DNS tuning
ns_param   dnscache        false      ;# In-memory cache of DNS lookups
ns_param   dnscachetimeout 60        ;# How long to keep hostnames in cache
ns_param debug off
ns_param   shutdowntimeout    20  ;# Seconds to wait on shutdown if open connections
ns_param   schedmaxelapsed    2   ;# Warn when waiting on rely long procedures
ns_param   listenbacklog      32  ;# Number of pending connections



ns_section "ns/limits"
ns_param default         "Default Limits" ;# Defines a limit.

ns_section "ns/limit/default"
ns_param maxrun          100       ;# Conn threads running for limit.
ns_param maxwait         100       ;# Conn threads waiting for limit.
ns_param maxupload       102400000 ;# Max size of file upload in bytes.
ns_param timeout         60        ;# Total seconds to wait for resources.


# 
# Thread library (nsthread) parameters 
# 
ns_section ns/threads
    # The per-thread stack size must be a multiple of 8k for NaviServer to run under MacOS X
    ns_param   stacksize          [expr {128 * 8192}]





#
# Fastpath serves HTML
#
#ns_section "ns/fastpath"
#      ns_param mmap          false    ;# Use mmap(2) to read files from disk.
#      ns_param cache         false    ;# Cache file contents in memory.
#      ns_param cachemaxsize  10240000 ;# Size of file cache, if enabled.
#      ns_param cachemaxentry 8192     ;# Don't cache files larger than this


