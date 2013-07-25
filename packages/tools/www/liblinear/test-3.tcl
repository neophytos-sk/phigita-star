::xo::lib::require liblinear

ll_problem::load problem "/web/service-phgt-0/lib/liblinear/test/news20-dataset/news20"

append result "problem=$problem"

#set the_problem [ll_problem::get problem]
#set fp [open "/web/tmp/the_problem.txt" w]
#puts $fp $the_problem
#close $fp
#foreach el $the_problem {
#    append result "\n element in problem spec, llength = [llength $el]"
#}
doc_return 200 text/plain $result