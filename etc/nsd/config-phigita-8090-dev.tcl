ns_log notice "start reading configuration settings"

set production_mode_p 0
set performance_mode_p 0
set connsperthread 1000
set debug 0
set dev 0
set reverse_proxy_mode_p 1
set is_mail_server_p 0  ;# ::xo::mail::process_incoming_mail

set webroot               /web

set server		  service-phigita
set datasource		  localhost::service-phgt-0

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

set storage_port          7000

# The hostname and address should be set to actual values.

if {1} {
    set hostname               atlas
    set address                0.0.0.0 ;# 127.0.0.1 ;#192.168.200.201;# [ns_info address]
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


set server_web "phigita-web"
set server_mail "phigita-mail"
set server_static "phigita-static"
set server_secure_static "phigita-secure-static"

set servername_web    "phigita web server"
set servername_mail   "phigita mail server"
set servername_static "phigita static server"
set servername_secure_static "phigita secure static server"



set server_static_host "static.phigita.net"
set server_static_host_and_port ${server_static_host}
set server_secure_static_host_and_port "${server_static_host}:443"

set servername $servername_web

source [file join $serverroot etc/nsd/config-phigita-global.tcl]
source [file join $serverroot etc/nsd/config-phigita-web.tcl]
source [file join $serverroot etc/nsd/config-phigita-static.tcl]

if { {nssmtpd} in ${modules} } {
    source [file join $serverroot etc/nsd/config-phigita-mail.tcl]
}

