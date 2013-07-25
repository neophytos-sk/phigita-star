
# Use shiny new ns_cache-based util_memoize.
# Create the cache used by util_memoize.

# Note: we must pass the package_id to ad_parameter, because
# otherwise ad_parameter will end up calling util_memoize to figure
# out the package_id.


#ns_cache_create util_memoize [ad_parameter -package_id [ad_acs_kernel_id] MaxSize memoize 200000]
ns_cache_create util_memoize 200000

