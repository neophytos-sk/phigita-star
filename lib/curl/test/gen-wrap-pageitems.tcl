#!/usr/bin/tclsh

source ../../naviserver_compat/tcl/module-naviserver_compat.tcl


::xo::lib::require curl
::xo::lib::require tdom_procs
::xo::lib::require util_procs
::xo::lib::require htmltidy

set dir [file dirname [info script]]
source [file join $dir helper-procs.tcl]

set url [string trim [lindex $argv 0]]
set product_id [string trim [lindex $argv 1]]
set keywords [string trim [lindex $argv 2]]

if { $url eq {} } {

    puts "Usage: $argv0 url"

    puts "--->>> proceeding with example url"

    set url "http://www1.macys.com/shop/mens-clothing/mens-coats?id=3763"
}


set options(followlocation) 1
set options(maxredirs) 5

set dir [file dirname [info script]]
set options(cookiefile) [file join ${dir} "cookies.txt"]

set errorcode [::http::fetch html $url options info]

if { $errorcode } {
    puts "--->>> errorcode=$errorcode"
    exit
}

set html [htmltidy::tidy $html]
set doc [dom parse -html $html]


proc get_image_data {node} {
    set imageUrl [$node @src ""]
    set pageUrl [get_parent_url $node]
    # puts "--->>> imageUrl=$imageUrl"
    # puts "--->>> pageUrl=$pageUrl"

    set isPageItem false
    if { $pageUrl ne {} } {
        # TODO: check image size
        set isPageItem true
    }

    return [list isPageItem $isPageItem imageUrl $imageUrl pageUrl $pageUrl]
}

proc get_parent_url {node} {
    set count 0
    set tagName ""
    set currNode $node 
    while { $currNode ne {} && [set tagName [string tolower [$currNode nodeName]]] ne {a} && $count < 15 } {
        set currNode [$currNode parentNode]
        incr count
    }


    if { $tagName eq {a} && [set href [$currNode @href ""]] ne {} } {
        # puts "--->>> href=$href"
        return $href
    }
}

exec_xpath images $doc {//img}

set pageItems [list]
foreach node $images {
    array set imageDataArr [set imageData [get_image_data $node]]
    if { $imageDataArr(isPageItem) } {
        lappend pageItems $imageData
    }
}

set pages [list]
foreach item $pageItems {
    array set itemArr $item
    lappend pages $itemArr(pageUrl)
}


puts pages=[join $pages "\n"]

$doc delete

# puts [array get info]
# puts errorcode=$errorcode
# puts $options(cookiefile) 

