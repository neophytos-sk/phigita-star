ad_page_contract { 
    Enables a version of the package.
    
    @param version_id The package to be processed.
    @author Jon Salz [jsalz@arsdigita.com]
    @date 9 May 2000
    @cvs-id $Id: version-enable.tcl,v 1.1.1.1 2002/11/22 09:47:32 nkd Exp $
} {
    {version_id:integer}

}

apm_version_enable -callback apm_dummy_callback $version_id

ns_returnredirect "version-view?version_id=$version_id"
