ad_library {

    Provides methods for authorizing and identifying ACS 
    (both logged in and not) and tracking their sessions.

    @creation-date 16 Feb 2000
    @author Jon Salz (jsalz@arsdigita.com)
    @author Richard Li (richardl@arsdigita.com)
    @cvs-id $Id: security-init.tcl,v 1.1.1.1 2001/03/13 22:59:26 ben Exp $

}

# Schedule a procedure to sweep for sessions.
ad_schedule_proc -thread f [ad_parameter SessionSweepInterval security 7200] sec_sweep_sessions

# Verify that the secret_tokens table is populated
set secret_tokens_exists [db_string secret_tokens_exists "select case when count(1) = 0 then 0 else 1 end from secret_tokens"]

if { $secret_tokens_exists == 0 } {
    populate_secret_tokens_db
}

ns_log Notice "Creating secret_tokens ns_cache..."
ns_cache_create secret_tokens 32768
ns_log Notice "Populating secret_tokens ns_cache..."
populate_secret_tokens_cache

# These procedures are dynamically defined so that ad_parameter
# does not need to be called directly in the RP. 
proc sec_session_timeout {} "
    return \"[ad_parameter -package_id [ad_acs_kernel_id] SessionTimeout security 2592000]\"
"

proc sec_session_renew {} "
    return \"[expr [sec_session_timeout] - [ad_parameter -package_id [ad_acs_kernel_id] SessionRenew security 2500000]]\"
"

# LoginTimeout, see openacs-5.0.4/packages/acs-tcl/tcl/security-
proc sec_login_timeout {} {
    return 28800
}

