ad_page_contract {

    @author Neophytos Demetriou

} {

    package_id:integer
    node_id:integer
    {return_url ""}
}

ad_conn_set form_count 0

form create pkg_form -action edit-2 -method post -mode edit -edit_buttons {} -show_required_p 0 

db_0or1row get_pkg_instance_info "select instance_name from apm_packages where package_id=:package_id"

element create pkg_form node_id -widget "hidden" -value $node_id
element create pkg_form package_id -widget "hidden" -value $package_id
element create pkg_form return_url -widget "hidden" -value $return_url

element create pkg_form instance_name -value $instance_name -label "Instance Name"
