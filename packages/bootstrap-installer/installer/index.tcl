ad_page_contract {

    If no database driver is available, the acs-kernel libraries may not have
    been loaded (which is fine, since index.tcl will display a message
    instructing the user to install the database driver and restart the server
    before proceeding any further; in this case we won't use any procedures
    depending on the core libraries). Otherwise, all -procs.tcl files in
    acs-kernel (but not any -init.tcl files) will have been run.

    @author Jon Salz (jsalz@arsdigita.com)
    @author Bryan Quinn (bquinn@arsdigita.com)
    @author Richard Li (richardl@arsdigita.com)
    @creation-date Mon Oct  9 15:19:31 2000
    @cvs-id index.tcl,v 1.7.2.2 2001/01/12 20:07:41 richardl Exp
} {

}

if { [ns_queryexists done_p] } {
    # When installation is complete, the user is redirected to /index?done_p=1
    # (well, actually, /?done_p=1). This is so the user can just hit his/her
    # browser's Reload button to get the main OpenACS login page once (s)he's
    # restarted the OpenNSD.
    
  if { [ad_verify_install] } {
    install_return 200 "Installation Complete" "

You have successfully installed the Phigita Web Server (PWS)!

<p> Your server process has been terminated.  Unless you have configured your
web server to restart automatically, as outlined in the Installation Guide, 
you will need to start your web server again.
When the web server restarts, PWS will be fully functional and you can reload 
this page to access the running web server.
"
    exit
  } else {
    install_return 200 "Error" "
The installation program has encounted an error.  Please drop your PWS tablespace
and the PWS username, recreate them, and try again. 
"
    return
  }
  return

}

set body "

Thank you for installing the Phigita Web Server,
a suite of fully-integrated enterprise-class solutions
for collaborative commerce.
This is the Installer which performs all the steps necessary
to get the toolkit running on your server.<p>

"

set error_p 0

# do some error checking.
if { [nsv_exists acs_properties database_problem] } {
    # This NSV entry is set if there's some sort of problem with the database
    # driver. We aren't going to get very far in that case.

    append body "<p>
[nsv_get acs_properties database_problem]

<p><b>The first step involved in setting up your
installation is to configure your RDBMS, correctly install a database driver,
and configure PWS to use it.
<p>
Once you're sure everything is installed and configured correctly, restart PWS.</b></p>
"
    install_return 200 "Error" $body
    return
} 

# Perform database-specific checks
db_installer_checks errors error_p

if { !$error_p } {
    append body "<p>Your [db_name] driver is correctly installed and configured.\n"
}


# OpenNSD must support ns_sha1
if { [catch { ns_sha1 quixotusishardcore }] } {
    append errors "<li><p><b>The sha1 function is missing. This function is
    required in PWS so that passwords can be securely stored in
    the database. This function is available in the pws_sha1 module that is part of the PWS distribution.</b></p>"

    set error_p 1
}

# OpenNSD must support Tcl 8.x
if { [string range [info tclversion] 0 0] < 8 } {
    append errors " <li><p><strong> You are using a version of Tcl less than 8.0.  You must use Tcl version 8.0
    for PWS to work. 
    </pre></blockquote>
    "
    set error_p 1
}


# AOLserver must support the "fancy" ADP parser.
set adp_support [ns_config "ns/server/[ns_info server]/adp" DefaultParser]
if { [string compare $adp_support "fancy"] } {
    append errors "<li><p><strong>The fancy page parser is not enabled.  This is required to support 
the PWS Templating System.  Without this templating system, none of the PWS pages installed by default
will display. 
After adding support for the fancy page parser, please restart your web server.
</strong></p>"
    set error_p 1
}   

# AOLserver must have a large stack size (at least 128K)
set stacksize [ns_config "ns/threads" StackSize]
if { $stacksize < [expr 128 * 1024] } {

    append errors "<li><p>The configured PWS Stacksize is too small ($stacksize).
PWS requires a StackSize parameter of at least 131072 (ie 128K).
After adding support the larger stacksize, please restart your web server.
</strong></p>"
    set error_p 1
}   


# We have the workspace dir, but what about the package root?
if { ![file writable [file join [acs_root_dir] packages]] } {
    append errors "<li><p><strong>The PWS packages directory has incorrect permissions.  It must be owned by
    the user executing the web server.</strong></p>"
    set error_p 1
}

db_helper_checks errors error_p

# Now that we know that the database and aolserver are set up
# correctly, let's check out the actual db.
if {$error_p} {
    append body "<p>
<strong>At least one misconfiguration was discovered that must be corrected.
Please fix all of them, restart the web server, and try running the PWS installer again.
You can proceed without resolving these errors, but the system may not function
correctly.
</strong>
<p>
<ul>
$errors
</ul>
<p>
"
}

# See whether the data model appears to be installed or not. The very first
# thing to be installed is the apm_packages table - does that exist?
if { ![db_table_exists apm_packages] } {
    # Nope. Need to install the data model.
    append body "<p>The next step is to install the PWS kernel data model. Click the <i>Next</i>
    button to proceed.
    
    [install_next_button "install-core-platform"]
    "
} else {
    # OK, apm_packages is installed - let's check out some other stuff too:
    if { ![install_good_data_model_p] } {
	append body "<p>It appears that the PWS data model is only partially installed.
	Please drop your tablespace and start from scratch."
    } else {
	append body "<p>The PWS data model is already installed. Click <i>Next</i> 
	to scan the available packages.
	
	[install_next_button "packages-install"]
	"
    }
}

install_return 200 "Welcome" $body
