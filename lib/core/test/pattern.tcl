set dir [file dirname [info script]]

source [file join $dir ../tcl/data/pattern.tcl]

foreach str {
    12345
    abcdef
    123.45
    192.168.150.3
    somename@example.com
    http://www.phigita.net/
    Max Awesome
    12/29/2015
    02/07/2014
    phigita.net
    my.phigita.net
} {
    puts "typeof('${str}') = [::data::pattern::typeof $str]"
}
