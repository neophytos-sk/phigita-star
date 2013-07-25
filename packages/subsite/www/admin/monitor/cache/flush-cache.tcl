ad_page_contract {
    Flush one or more values from util_memoize's cache
} {
    suffix
}

ns_cache_flush $suffix

ad_returnredirect "."