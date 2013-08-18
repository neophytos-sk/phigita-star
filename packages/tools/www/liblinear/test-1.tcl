#set libdir [acs_root_dir]/packages/tools/lib/
#source [file join $libdir liblinear-ext/tcl/module-liblinear-ext.tcl]

::xo::lib::require liblinear

set result ""


append result "\n------------------------------ programming collective intelligence page 217"

set n 2           ;# number of training data
set l 2           ;# number of feature, including bias (if bias > 0)
set y {1 -1}

# x is a list of lists of feature nodes
# a feature node is a pair of index and value
# Note that feature index must start from 1 (but not 0).

set x {
    {{1 1.0} {2 0} {-1 0}}
    {{1 -1.0} {2 0.0} {-1 0}}
}
set bias -1  ;# < 0 if no bias term

append result "\n ll_problem::create = [::ll_problem::create problem]"
append result "\n ll_problem::set = [::ll_problem::set problem [list $l $n $y $x $bias]]"



#ll_parameter::set param solver type eps C nr_weight weight_1 weight_2 ...
set solver_type 0 ;# L2R_LR
set eps "0.01" ;# default is 0.01 for solvers 0 and 2, 0.1 for solvers 1, 3 and 4, and 0.01 for 5 and 6 (see README)
set C "10.0"
set nr_weight "0"
set weight_labels [list]
set weights [list]

append result "\n ll_parameter::create = [::ll_parameter::create param]"
append result "\n ll_parameter::set = [::ll_parameter::set param [list $solver_type $eps $C $nr_weight ${weight_labels} ${weights}]]"

append result "\n ll_train = [ll_train model problem param]"
append result "\n ll_model::get = [set model_list [::ll_model::get model]]"



# NOTE THAT WE NEED TO INCLUDE THE PARAM BY NAME (NOT BY VALUE)
#set model_list "param 2 2 {{2.1273942068149014 0.0} {3.809858470965158e+180 2.6e-322}} {1 -1} -1.0"
set model_list "\nparam [lrange $model_list 1 end]"
append result "\n ll_model::create = [::ll_model::create new_model]"
append result "\n ll_model::set = [::ll_model::set new_model $model_list]"
append result "\n ll_model::get = [::ll_model::get new_model]"

append result "\n ll_predict = [::ll_predict new_model {{1 0.2} {2 0.3}}]"

ll_model::save new_model "/web/service-phigita/lib/liblinear/example.m"
append result "\n------------------------------"


doc_return 200 text/plain $result
return
