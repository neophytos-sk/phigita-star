#!/bin/sh
#\
 exec tclsh "$0" "$@"

package require bloom_filter

set items_estimate 10
set false_positive_prob 0.1
set bf [::bloom_filter::create $items_estimate $false_positive_prob]
::bloom_filter::insert $bf abc
::bloom_filter::insert $bf qwerty

puts [::bloom_filter::may_contain $bf abc]
puts [::bloom_filter::may_contain $bf test]
puts [::bloom_filter::may_contain $bf qwerty]

# just for testing bf_string_rep
# (where obj->bytes, and obj->length can be set)
#
# puts bf=$bf

puts bytes(bf)=[binary encode hex [::bloom_filter::bytes $bf]]

# calls bf_free_rep
unset bf



#set bf2 $bf
#puts [::bloom_filter::may_contain $bf2 abc]
#puts [::bloom_filter::may_contain $bf2 test]
#puts [::bloom_filter::may_contain $bf2 qwerty]


