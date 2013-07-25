#!/usr/bin/tclsh
load /opt/aolserver/lib/libnsd.so
load ../unix/libttext0.3.so
#set html "<html><body><p>helol<b>hsdf</b></p><body></htm>"

#set filename tidy-1.html
set filename phileleftheros.html

set fp [open ${filename} "r"]
set text [read ${fp}]
close ${fp}

puts [ttext::tidy \
	  --force-output y \
	  --show-warnings n \
	  --show-errors 0 \
	  --output-encoding raw \
	  --quiet y \
	  --tidy-mark 0 \
	  --drop-empty-paras 0 \
	  ${text}]
