::xo::lib::require liblinear


# ll_parameter
set solver_type 0
append result "\n ll_parameter::create = [::ll_parameter::create param]"
append result "\n ll_parameter::set = [::ll_parameter::set param "$solver_type 44.5 7.89 2 {11 22} {33 44}"]"
append result "\n ll_parameter::get = [::ll_parameter::get param]"

# ll_problem
append result "\n ll_problem::create = [::ll_problem::create problem]"
set n 6           ;# number of training data
set l 5           ;# number of feature, including bias (if bias > 0)
set y {1 2 1 2 3}
set x {
    {{2 0.1} {3 0.2} {6 1} {-1 0}}
    {{2 0.1} {3 0.3} {4 -1.2} {6 1} {-1 0}}
    {{1 0.4} {6 1} {-1 0}}
    {{2 0.1} {4 1.4} {5 0.5} {6 1} {-1 0}}
    {{1 -0.1} {2 -0.2} {3 0.1} {4 1.1} {5 0.1} {6 1} {-1 0}}
}
set bias 0.7
append result "\n ll_problem::set = [::ll_problem::set problem [list $l $n $y $x $bias]]"
append result "\n ll_problem::set = [::ll_problem::get problem]"

# ll_train
append result "\n ll_train = [ll_train trained_model problem param]"
append result "\n ll_model::get (trained_model) = [ll_model::get trained_model]"

# ll_model
append result "\n ll_model::create = [::ll_model::create model]"
set nr_class "2"
set nr_feature "3"
set w "{81.12 92.23} {63.44 24.85} {35.76 56.27}"
set label [iota $nr_class]
set bias 0.7
append result "\n ll_model::set = [::ll_model::set model [list param $nr_class $nr_feature $w $label $bias]]"
append result "\n ll_model::get = [::ll_model::get model]"


set nr_fold 5
append result "\n ll_cross_validation - accuracy = [::ll_cross_validation problem param $nr_fold]"

doc_return 200 text/plain $result
return
