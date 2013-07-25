source [file dirname [ad_conn file]]/module-statistics.tcl


#   Ref:
#     (1) http://www.matsusaka-u.ac.jp/~okumura/algo/
#     (2) http://www5.airnet.ne.jp/tomy/cpro/sslib11.htm
#     (3) http://blade.nagaokaut.ac.jp/~sinara/ruby/math/statistics2/statistics2-0.53/ext/statistics2.c
#     (4) "How Not to Sort By Average Rating":http://www.evanmiller.org/how-not-to-sort-by-average-rating.html



package require math::statistics

# package require math::lognorm
#   IUSE math::lognorm::norminv
source [file dirname [ad_conn file]]/tcl-code/math-lognorm.tcl 



set power 0.10
set x [expr {1 - $power / 2.0}]

set p_value_from_c [pnormaldist $x]
set p_value_from_tcl [math::lognorm::norminv $x]

# First Example: Wrong Solution 1: Score = (positive ratings) - (negative ratings)
set ci_lower_bound_A1 [ci_lower_bound 209 259 0.10]
set ci_lower_bound_A2 [ci_lower_bound 118 143 0.10]
# Second Example: Wrong Solution 2: Score = Average rating = (positive ratings) / (total ratings)
set ci_lower_bound_B1 [ci_lower_bound 2 2 0.10]
set ci_lower_bound_B2 [ci_lower_bound 100 101 0.10]

set ci_lower_bound_C [ci_lower_bound 17 38 0.10]
set ci_lower_bound_D [ci_lower_bound 76 128 0.10]


set result ""
lappend result "p_value_from_c=$p_value_from_c"
lappend result "p_value_from_tcl=$p_value_from_tcl"
lappend result "ci_lower_bound, first example: $ci_lower_bound_A1 must be less than (<) $ci_lower_bound_A2"
lappend result "ci_lower_bound, second example: $ci_lower_bound_B1 must be less than (<) $ci_lower_bound_B2"
lappend result "ci_lower_bound, third example, from actual data: $ci_lower_bound_C"
lappend result "ci_lower_bound, fourth example, from actual data: $ci_lower_bound_D"

doc_return 200 text/plain [join $result \n]