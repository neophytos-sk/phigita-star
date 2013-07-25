ad_library {

    initialization for acs_mail_lite module

    @author Eric Lorenzo (eric@openforce.net)
    @creation-date 22 March, 2002
    @version $Id: acs-mail-lite-init.tcl,v 1.1.1.1 2002/11/22 09:47:32 nkd Exp $

}

ns_log notice "is_mail_p= [ns_config ns/server/[ns_info server] is_mail_p 0]"

# Default interval is 1 minute.
if { [ns_config ns/server/[ns_info server] is_mail_p 0] } {
    ad_schedule_proc -thread t 60 acs_mail_lite::sweeper
}