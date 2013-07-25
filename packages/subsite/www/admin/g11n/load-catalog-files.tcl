ad_page_contract {
    Load all catalog files.

    @author Peter Marklund (peter@collaboraid.biz)
    @creation-date 2002-10-07
    @cvs-id $Id: load-catalog-files.tcl,v 1.3 2002/10/23 11:47:37 peterm Exp $
}

lang::catalog::import_from_all_files

ad_returnredirect "index"
