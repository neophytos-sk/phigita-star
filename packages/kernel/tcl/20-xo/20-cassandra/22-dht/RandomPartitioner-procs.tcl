namespace eval ::xo::dht {;}

# preservesOrder: false
# hash: sha1
Object ::xo::dht::RandomPartitioner
::xo::dht::RandomPartitioner proc getToken {key} {
    return [::math::bignum::fromstr [string tolower [ns_sha1 $key]] 16]
}
