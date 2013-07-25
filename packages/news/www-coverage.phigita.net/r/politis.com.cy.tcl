set category 1

# example: http://www.haravgi.com.cy/13_10_2005/main.html
if { [clock format [clock seconds] -format "%H"] > 11 } {
    set seconds [clock seconds]
} else {
    set seconds [expr {[clock seconds]-3600*24}]
#    set seconds 1136089563
}

set url [clock format $seconds -format "http://www.politis.com.cy/cgibin/hweb?-V=backissues&-F=1=%d/%m/%Y&-b=1&-dbackissues.html"]
ad_returnredirect ${url}