proc encode_sstable_name {type_oid} {
    set sstable_name [join [split ${type_oid} {/}] {.}]
}

proc encode_sstable_fragment_name {type_oid fragment_num} {
    set sstable_name [encode_sstable_name $type_oid]
    set sstable_fragment_name ${sstable_name}.${fragment_num}
}

