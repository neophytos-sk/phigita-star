::xotcl::THREAD mail_server {

    #package require smtpd

    proc handle_mail {sock when} {

	ns_log notice "sock=$sock when=$when"
	set fds [ns_sockaccept $sock]
	set rfd [lindex $fds 0]
	set wfd [lindex $fds 1]
	#puts $wfd "Hello!"
	set data [read $rfd]
	close $rfd
	close $wfd

	deliver_mail data

    }


    proc deliver_mail {dataVar} {
	upvar $dataVar data

	set dirname "/web/local-data/mail/"
	file mkdir $dirname
	
	set date [clock format [clock seconds] -format "%Y%m%dT%H%M%S"]
	
	#set mail ""
	#append mail "From: $sender"
	#append mail "\n" "Recipients: $recipients"
	#append mail "\n" "Date: $date"
	#append mail "\n" $data
	
	set filename [file join $dirname "${date}.[clock milliseconds]"]
	set fp [open $filename w]
	puts $fp $data
	close $fp
    }

    
    proc init_mail_server {} {
	ns_log notice "starting smtpd..."
	#set addr "192.168.10.1"
	#set addr "0.0.0.0"
	set addr "*"
	set port 25
	#smtpd::start ;# $addr $port
	#smtpd::configure -deliver deliver_mail
	set sock [ns_socklisten $addr $port]
	ns_log notice "listening to sock=$sock"
	ns_socknonblocking $sock
	ns_sockcallback $sock handle_mail r
	# keep $sock open after connection closes
	#ns_detach $sock
	#ns_log notice "started smtpd..."
    }

} -persistent 1


