ad_page_contract {

    Installs the core platform packages.

    @author Neophytos Demetriou (k2pts@phigita.net)
    @cvs-id $Id: install-core-platform.tcl,v 1.1.1.1 2002/11/22 09:47:31 nkd Exp $

} {
}


ns_write [install_header 200 "Installing Core Platform"]

if {[install_good_data_model_p] } {
    ns_write "Data model installed."
    return
}


cd [file join [acs_root_dir] packages core-platform sql [db_type]]
db_source_sql_file "create.sql"
#cd [file join [acs_root_dir] packages package-manager sql [db_type]]
#db_source_sql_file "create.sql"
#cd [file join [acs_root_dir] packages user-manager sql [db_type]]
#db_source_sql_file "create.sql"
#cd [file join [acs_root_dir] packages permissions sql [db_type]]
#db_source_sql_file "create.sql"
#cd [file join [acs_root_dir] packages security sql [db_type]]
#db_source_sql_file "create.sql"
#cd [file join [acs_root_dir] packages subsite sql [db_type]]
#db_source_sql_file "create.sql"



# DRB: Now initialize the APM's table of known database types.  This is
# butt-ugly.  We could have apm-create.sql do this but that would mean
# adding a new database type would require editing two places (the very
# obvious list in bootstrap.tcl and the less-obvious list in apm-create.sql).
# On the other hand, this is ugly because now this code knows about the
# apm datamodel as well as the existence of the special kernel module.

set apm_db_types_exists [db_string db_types_exists "
    select case when count(*) = 0 then 0 else 1 end from apm_package_db_types"]

if { !$apm_db_types_exists } {
    ns_log Notice "Populating apm_package_db_types"
    foreach known_db_type [db_known_database_types] {
        set db_type [lindex $known_db_type 0]
        set db_pretty_name [lindex $known_db_type 2]
        db_dml insert_apm_db_type {
            insert into apm_package_db_types
                (db_type_key, pretty_db_name)
            values
                (:db_type, :db_pretty_name)
        }
    }
}




#Temporary fix until I find a better place to put these:
cd [file join [acs_root_dir] packages core-platform sql [db_type]]
db_source_sql_file -callback apm_ns_write_callback "acs-create.sql"

apm_version_enable -callback apm_ns_write_callback [apm_package_install -callback apm_ns_write_callback "[file join [acs_root_dir] packages core-platform pkgIndex.info]"]
apm_version_enable -callback apm_ns_write_callback [apm_package_install -callback apm_ns_write_callback "[file join [acs_root_dir] packages package-manager pkgIndex.info]"]
#apm_version_enable -callback apm_ns_write_callback [apm_package_install -callback apm_ns_write_callback "[file join [acs_root_dir] packages user-manager pkgIndex.info]"]
#apm_version_enable -callback apm_ns_write_callback [apm_package_install -callback apm_ns_write_callback "[file join [acs_root_dir] packages permissions pkgIndex.info]"]
#apm_version_enable -callback apm_ns_write_callback [apm_package_install -callback apm_ns_write_callback "[file join [acs_root_dir] packages security pkgIndex.info]"]
#apm_version_enable -callback apm_ns_write_callback [apm_package_install -callback apm_ns_write_callback "[file join [acs_root_dir] packages subsite pkgIndex.info]"]



ns_write "<p>Loading package info files ... this will take a few minutes<p>"

# Preload all the pkgIndex.info files so the next page is snappy.
apm_dependency_check -initial_install [apm_scan_packages -new [file join [acs_root_dir] packages]]

proc ad_acs_kernel_id {} {
    if {[db_table_exists apm_packages]} {
	return [db_string acs_kernel_id_get {
	    select package_id from apm_packages
	    where package_key = 'core-platform'
	} -default 0]
    } else {
	    return 0
    }
}

ns_write "<h2>Installing Core Services</h2>"

# Attempt to install all packages.
set dependency_results [apm_dependency_check -initial_install [apm_scan_packages -new [file join [acs_root_dir] packages]]]
set dependencies_satisfied_p [lindex $dependency_results 0]
set pkg_list [lindex $dependency_results 1]
apm_packages_full_install -callback apm_ns_write_callback $pkg_list

# Complete the initial install.

if { ![ad_acs_admin_node] } {
    ns_write "  <p><li> Completing Install sequence.<p>
    <blockquote><pre>"
    cd [file join [acs_root_dir] packages bootstrap-installer data [db_type]]
    db_source_sql_file -callback apm_ns_write_callback install.sql
    ns_write "</pre></blockquote>"
} 

ns_write "All Packages Installed."

ns_write "<p>Generating secret tokens..."

populate_secret_tokens_db
ns_write "  <p>Done.<p>
[install_next_button "create-administrator"]
[install_footer]
"
