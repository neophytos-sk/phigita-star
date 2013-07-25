package require critcl
set libdir [acs_root_dir]/packages/tools/lib/
#source [file join $libdir critcl-ext/tcl/module-critcl-ext.tcl]

ad_page_contract {
    @author Neophytos Demetriou
} {
    n:integer
    k:integer
}

# TODO: add unsigned to critcl data types
# http://blog.plover.com/math/choose.html
::critcl::cproc math_choose {int n int k} int {
    unsigned r = 1;
    unsigned d;
    if (k>n) return 0;
    for (d=1; d<=k; d++) {
      r *= n--;
      r /= d;
    }
    return r;
}

set result [math_choose $n $k]
doc_return 200 text/plain "given n=${n},k=${k}: choose(n,k) = $result"
return

### TCL version below

if { $k > $n } { set k $n }

proc pascal_triangle {n retVar} {
    upvar $retVar ret

    set ret(0,0) 1
    for {set i 1} {$i <= $n} {incr i} {
	set ret(${i},0) 1
	set ret(${i},${i}) 1
	for {set j 1} {$j < $i} {incr j} {
	    set prev_i [expr { ${i}-1 }]
	    set prev_j [expr { ${j}-1 }]
	    set ret($i,$j) [expr { $ret($prev_i,$prev_j) + $ret($prev_i,$j) }]
	}
    }
}

array set triangle [list]
pascal_triangle $n triangle

set result ""
for {set i 0} {$i <= $n} {incr i} {
    set line [list]
    for {set j 0} {$j <= $i} {incr j} {
	if { $i == $n && $k == $j } {
	    lappend line [format "%5s" "\[*\]"]
	} else {
	    lappend line [format "%5d" $triangle(${i},${j})]
	}
    }
    lappend result [join $line " "]
}

doc_return 200 text/plain "Binomial Coefficient (n=${n}, k=$k)=$triangle(${n},${k})\n\nPascal's Triangle (n=$n)\n\n[join $result \n]"
