load /opt/naviserver/lib/libnsd.so
load /web/code/tlucene1.0/src/tlucene1.0.so
set qry {this is a test author:" Neophytos   Demetriou " hello "test cyprus greece" world -football INTITLE:TESTme inurl:phigita tag:inbox}
###set qry [join $qry { AND }]

set fp [open test.greek3]
fconfigure $fp -encoding utf-8 
set qry [read $fp]
close $fp



puts input_query=$qry
puts query=[::xo::lib::lucene parse_query $qry]

puts tokenizer=[::xo::lib::lucene tokenize $qry]


