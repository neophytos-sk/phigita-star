ns_log notice "start reading configuration settings"
#set production_mode_p 1
set production_mode_p 0

set mode 0 ;# dev && debug
set mode 1 ;# not(dev) && debug
set mode 2 ;# dev && not(debug)
set mode 3 ;# not(dev) && not(debug) && connsperthread=10
set mode 4 ;# performance

if { $mode == 4 } {
    set performance_mode_p 1
    set connsperthread 1000
    set dev 0
    set debug 0
} elseif { $mode == 3 } {
    set performance_mode_p 0
    set connsperthread 10
    set dev 0
    set debug 0
} elseif { $mode == 2 } {
    set performance_mode_p 0
    set connsperthread 10
    set dev 1
    set debug 0
} elseif { $mode == 1 } {
    set performance_mode_p 0
    set connsperthread 10
    set dev 0
    set debug 1
} else {
    set performance_mode_p 0
    set connsperthread 1
    set dev 1
    set debug 1
}


set reverse_proxy_mode_p 0
set is_mail_server_p 1

set webroot               /web

set server		  service-phgt-0
set datasource		  localhost::${server}

set minthreads             5
set maxthreads             10
set db_pool_connections    15

set user                  nsadmin
set group                 web
set password              ${server}-662051

set email                 "webmaster@phigita.net"

set serverroot                "/web/servers/${server}"

# 
# AOLserver's home and binary directories. Autoconfigurable. 
#
set homedir                   "/opt/naviserver/"
set bindir                    [file dirname [ns_info nsd]]
set libdir                    ${serverroot}/lib


set httpport              8090
set httpsport             8443 

set storage_port          7001

# The hostname and address should be set to actual values.

if {1} {
    set hostname               megistias
    set address                127.0.0.1 ;#192.168.200.201;#0.0.0.0 ;# [ns_info address]
} else {
    set hostname               www.phigita.net;#[ns_info hostname]
    set address                127.0.0.1;#[ns_info address]
}

#---------------------------------------------------------------------
# if debug is false, all debugging will be turned off

set max_file_upload_mb        20
set max_file_upload_min        5

ns_log notice "done reading configuration settings"

set modules {}
#set modules {nssmptd}

set server_web "phigita-web"
set server_mail "phigita-mail"
set server_static "phigita-static"

set servername_web    "phigita web server"
set servername_mail   "phigita mail server"
set servername_static "phigita static server"


set server_static_host_and_port "i-test.uap.net:8090"

set servername $servername_web

source [file join $serverroot etc/nsd/config-phigita-global.tcl]
source [file join $serverroot etc/nsd/config-phigita-web.tcl]
source [file join $serverroot etc/nsd/config-phigita-static.tcl]

if { {nssmtpd} in ${modules} } {
    source [file join $serverroot etc/nsd/config-phigita-mail.tcl]
}
