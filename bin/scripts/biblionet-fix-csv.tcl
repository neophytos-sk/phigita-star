#!/usr/bin/tclsh


source /web/bin/scripts/translations.tcl



package require textutil

set filename [lindex $argv 0]
set fp [open $filename]

namespace eval isbn {;}

proc ::isbn::valid_checksum_p isbn {
     set digits 0
     set sum 0
    foreach d [split $isbn {}] {
        if {![string is digit $d]} { ;# Not a digit...
            if {(${digits} == 9 && ${d} ne {x} && ${d} ne {X}) || (${digits}<9 && ${d} eq {-})} {
                # ... Nor a 'x' as last character. Skip it.
                continue
            } else {
                return 0
            }
        }
        incr digits
        if {$d eq {x} || $d eq {X}} {set d 10}
        set sum [expr {$sum+($d*(11-$digits))}]
    }
    if {$digits == 10 && ($sum % 11) == 0} {return 1}
     return 0
}


proc ::isbn::ean13_csum { number } {
        set odd 1
        set sum 0
    foreach digit [split $number ""] {
	set odd [expr {!$odd}]
	#puts "$sum += ($odd*2+1)*$digit :: [expr {($odd*2+1)*$digit}]"
	incr sum [expr {($odd*2+1)*$digit}]
    }
    set check [expr {$sum % 10}]
    if { ${check} > 0 } {
	return [expr {10 - ${check}}]
    }
    return ${check}
}

proc ::isbn::convert_to_ean13 {isbn} {
    if { [isbn::valid_checksum_p ${isbn}] } {
	set isbn10_no_dashes [string map {- {}} ${isbn}]
	set first12digits "978[string range ${isbn10_no_dashes} 0 end-1]"
	return "${first12digits}[ean13_csum ${first12digits}]"
    }
    return {}
}



proc biblionet.convert.to.csv {line} {

    global en_to_el

    set line [string trim $line \"]
    set parts [::textutil::splitx [string map {| \\|} [string trim $line \"]] \",\"]
    lassign $parts book_id image_p authorlist categories author main_category description isbn10 isbn13 pages price publisher title year x_author x_price_text x_publisher x_title zzz_1 zzz_2


    if { [string range $pages 0 3] eq {ISBN} } {
	set pages ""
	set isbn10 $pages
    }
    if { ![string match *ISBN* $isbn10] || ![string match *ISBN* $isbn13] } {
	set isbn10 ""
	regexp -- {ISBN ([0-9\-]+)} $zzz_1 isbn10
	set isbn13 ""
	regexp -- {ISBN-13 ([0-9\-]+)} $zzz_1 isbn13
    }
    if { $isbn10 ne {} && $isbn13 eq {} } {
	set isbn13 [::isbn::convert_to_ean13 [string trim [string range $isbn10 5 end]]]
    }

    set subtitle ""
    regexp -- { \: ([^\/]+) \/} $zzz_2 __match__ subtitle

    set dimensions ""
    set width ""
    set height ""
    regexp -- {([0-9]+x[0-9]+)} $zzz_2 dimensions
    lassign [split $dimensions x] width height

    set edition ""
    set edition_place ""
    regexp -- {\. - ([0-9]+)[^\.]+\. - ([^\:]+)\: } $zzz_2 __match__ edition edition_place

    set cover ""
    regexp -- {\(([^\)]+)\)} $zzz_1 __match__ cover

    set prototype ""
    regexp -- "$en_to_el(prototype)\\:(\[^\\\}\]+)" $zzz_1 __match__ prototype
    set prototype [string trim $prototype]

    set bibliography_p ""
    regexp -- "($en_to_el(bibliography))" $zzz_1 __match__ bibliography_p
    if { [llength $bibliography_p] } {
	set bibliography_p t
    } else {
	set bibliography_p f
    }


    if { $isbn13 eq {}  && $isbn10 eq {} } {
	return ""
    }

    set extra ""
    foreach key {prologue epimetro bilingual distribution sinipeuthinotita coeditor includes first_edition distributor republish scale} {
	set value ""
	regexp -- "$en_to_el(${key})\\:(\[^\\\}\\\:\]+)(\\\. |\\\})" $zzz_1 __match__ value
	if { $value ne {} } {
	    lappend extra \"${key}\"=>\"[string map {\\ \\\\} [string map {' {\'}} [string trim ${value} ". "]]]\"
	}
    }
    set extra [join $extra ,]


    lappend new_parts $book_id
    lappend new_parts $image_p
    lappend new_parts $authorlist
    lappend new_parts $categories
    lappend new_parts $author
    lappend new_parts $description
    lappend new_parts [string range $isbn10 5 end]
    lappend new_parts [string map {- {}} [lindex [split $isbn13] 1]]
    lappend new_parts [lindex [split $pages] 0]
    lappend new_parts [regsub -all -- {[^0-9.]} [string map {, .} $price] {}]
    lappend new_parts $publisher
    lappend new_parts $title
    lappend new_parts [string trim $year "()"]
    lappend new_parts $subtitle
    lappend new_parts $width
    lappend new_parts $height
    lappend new_parts $edition
    lappend new_parts $edition_place
    lappend new_parts $cover
    lappend new_parts $prototype
    lappend new_parts $bibliography_p
    lappend new_parts $extra
#    lappend new_parts $zzz_1

    set new_new_parts ""
    foreach part $new_parts {
	if { $part ne {} } {
	    lappend new_new_parts $part
	} else {
	    lappend new_new_parts {\N}
	}
    }

    return [join $new_new_parts |]
}


set line ""
while { ![eof $fp] } {
    set next_line [gets $fp]
    if { [string index $next_line 0] eq {"} && [string is integer -strict [string range $next_line 1 5]] } {
	puts [biblionet.convert.to.csv $line]
        set line $next_line
    } else {
	append line \\n$next_line
    }
}
puts [biblionet.convert.to.csv $line]

close $fp