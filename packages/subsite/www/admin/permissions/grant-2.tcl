# packages/acs-core-ui/www/acs_object/permissions/grant-2.tcl

ad_page_contract {

  @author rhs@mit.edu
  @creation-date 2000-08-20
  @cvs-id $Id: grant-2.tcl,v 1.2 2001/04/22 16:13:15 stevew Exp $
} {
  object_id:integer,notnull
  party_id:integer,notnull
  privilege
}

ad_require_permission $object_id admin

db_exec_plsql grant {
  begin
    acs_permission.grant_permission(:object_id, :party_id, :privilege);
  end;
}

ad_returnredirect "one?[export_url_vars object_id]"
