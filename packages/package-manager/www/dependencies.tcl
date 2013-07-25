ReturnHeaders
set packages [db_list enabled_packages_l {
        select distinct package_key
        from apm_package_versions
        where enabled_p='t'
    }]

set pkg_order [my_dependency_check $packages]
ns_write <hr>${pkg_order} 
return

set topological_sort [list]
foreach pkg $pkg_order {
    lappend topological_sort $pkg
    if { $pkg == "infrastructure" || $pkg == "core" } { lappend topological_sort <hr> }
}

doc_return 200 text/html "[join $topological_sort <br>]"
