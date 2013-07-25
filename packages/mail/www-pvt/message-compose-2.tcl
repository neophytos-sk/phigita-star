::xo::kit::reload [acs_root_dir]/packages/mail/tcl/sendmail-procs.tcl

::xo::kit::require_secure_conn

ad_page_contract {
    @author Neophytos Demetriou (k2pts@phigita.net)
} {
    to:trim,notnull
    {cc ""}
    {bcc ""}
    {subject ""}
    {content ""}
    {reply_to ""}
    {rr ""}
}

#set mailhost [ns_config ns/parameters mailhost]


set from "k2pts@phigita.net"
#set from "neophytos@phigita.net"

set Version "PHIGITA MAIL 0.1d"
set hdrs [ns_set new]
ns_set put $hdrs X-Mailer $Version
ns_set put $hdrs "MIME-Version" "1.0"
if { $reply_to != "" } { ns_set update $hdrs Reply-To $reply_to }
# Message return receipt
if { $rr != "" } { ns_set put $hdrs Disposition-Notification-To $from }

set text $content

if { [catch { ::xo::mail::sendmail $to \
                  $from \
                  $subject \
                  $text \
                  $hdrs \
                  $bcc \
		  $cc} errMsg] } {
    error "Unable to send message: $errMsg"
}


doc_return 200 text/html "Message Sent"

