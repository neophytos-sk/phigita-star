set category 6

# example: http://www.haravgi.com.cy/13_10_2005/main.html
if { [clock format [clock seconds] -format "%H"] > 14 } {
    set seconds [clock seconds]
} else {
#    set seconds 1136089563
    set seconds [expr {[clock seconds]-3600*24}]

}
set url [clock format $seconds -format "http://www.haravgi.com.cy/%d_%m_%Y/${category}/index.html"]
ad_returnredirect ${url}