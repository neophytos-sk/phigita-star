#   crawldb {
#       sync_info {
#           by_urlsha1_and_const
#       }
#       round_stats {
#           by_timestamp_and_const
#       }
#       feed_stats {
#           by_feed_and_const
#           by_feed_and_period
#       }
#   }

set dir [file dirname [info script]]
::persistence::load_type_from_file [file join $dir crawldb.sync_info_t.pdl]

