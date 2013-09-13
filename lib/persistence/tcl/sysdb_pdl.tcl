::persistence::define_ks "sysdb"

foreach column_family {

    refcount_item

} {
    ::persistence::define_cf "sysdb" ${column_family}
}

