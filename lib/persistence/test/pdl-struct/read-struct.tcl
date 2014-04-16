package require tdom

set filename "messaging.struct"

dom createNodeCmd elementNode struct
dom createNodeCmd elementNode attr
dom createNodeCmd elementNode index
dom createNodeCmd elementNode extends

set doc [dom createDocument "pdl"]
set root [$doc documentElement]
if { [catch {$root appendFromScript "source $filename"} errMsg] } {
    $doc delete
    error $errMsg
    return
} else {
    puts [$doc asXML]
    # ::util::writefile $specfile [$doc asHTML]
    # ::xo::tdp::compile_doc $doc $filename
}

