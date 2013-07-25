# packages/acs-core-ui/www/acs_object/permissions/grant.tcl

ad_page_contract {

  @author rhs@mit.edu
  @creation-date 2000-08-20
  @cvs-id $Id: grant.tcl,v 1.3 2002/11/07 18:06:55 peterm Exp $
} {
  object_id:integer,notnull
}

ad_require_permission $object_id admin

# The object name is used in various localized messages below
set name [db_string name {select acs_object.name(:object_id) from dual}]

doc_body_append "[ad_header "[_ acs-subsite.lt_Grant_Permission_on_n]"]

<h2>[_ acs-subsite.lt_Grant_Permission_on_n]</h2>

[ad_context_bar [list ./?[export_url_vars object_id] "[_ acs-subsite.Permissions_for_name]"] "[_ acs-subsite.Grant]"]
<hr>

<form method=get action=grant-2>
[export_form_vars object_id]

<input type=submit value=\"[_ acs-subsite.Grant]\">

<select name=privilege>
"
db_foreach privileges {
  select privilege
  from acs_privileges
  order by privilege
} {
  doc_body_append "<option value=$privilege>$privilege</option>\n"
}

doc_body_append "
</select>
[_ acs-subsite.on] $name [_ acs-subsite.to]
<select name=party_id>
"

db_foreach party {
  select party_id, acs_object__name(party_id) as name
  from parties order by party_id
} {
    doc_body_append "<option value=$party_id>${party_id} - $name</option>\n"
}

doc_body_append "
</select>

</form>

[ad_footer]
"
