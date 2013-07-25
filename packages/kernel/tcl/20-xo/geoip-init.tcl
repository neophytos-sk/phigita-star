ns_log notice "initializing geoip_blocks.cbt_db"
::xo::lib::require geoip
::xo::geoip::init
ns_log notice "DONE: initializing geoip_blocks.cbt_db"