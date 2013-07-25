

Object o 
o ad_proc t1 {{-a 1} -b:required x {y 4}} {} {
  expr {$a + $b + $x + $y}
}


ad_proc t2 {{-a 1} -b:required x {y 4}} {} {
  expr {$a + $b + $x + $y}
}

set v1 [o t1 -b 2 3]
set v2 [t2 -b 2 3]


ns_return 200 text/plain "
xotcl ad_proc  t1=$v1 [time {time {o t1 -b 2 3} 10000}]
ad_proc        t2=$v2 [time {time {t2 -b 2 3} 10000}]
xotcl ad_proc  t1=$v1 [time {time {o t1 -b 2 3} 10000}]
ad_proc        t2=$v2 [time {time {t2 -b 2 3} 10000}]
"

