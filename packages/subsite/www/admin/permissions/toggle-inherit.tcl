# packages/acs-subsite/www/permissions/toggle-inherit.tcl

ad_page_contract {

  Toggles the security_inherit_p flag.

  @author rhs@mit.edu
  @creation-date 2000-09-30
  @cvs-id $Id: toggle-inherit.tcl,v 1.2 2002/03/13 22:54:34 yon Exp $
} {
  object_id:integer,notnull
}

ad_require_permission $object_id admin

permission::toggle_inherit -object_id $object_id

ad_returnredirect one?[export_url_vars object_id]
