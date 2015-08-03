#!/bin/sh
#\
 exec tclsh "$0" "$@"

package require bloom_filter

set items_estimate 1000
set false_positive_prob 0.00001
::bloom_filter::create $items_estimate $false_positive_prob
