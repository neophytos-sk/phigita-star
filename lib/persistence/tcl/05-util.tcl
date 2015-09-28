proc encode_sstable_name {type_oid} {
    set sstable_name [join [split ${type_oid} {/}] {.}]
}


