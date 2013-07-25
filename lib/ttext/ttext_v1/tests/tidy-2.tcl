#!/usr/bin/tclsh
load ../unix/libttext0.3.so
#set html "<html><body><p>helol<b>hsdf</b></p><body></htm>"
set f [open "tidy-2.html" "r"]
set htmldata [read $f]
puts [ttext::tidy --force-output y --show-warnings n --show-errors 0 -q $htmldata]