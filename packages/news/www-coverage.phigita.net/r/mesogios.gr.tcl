
# example: http://www.mesogios.gr/arxeio/2005/10/19/index.htm
if { [clock format [clock seconds] -format "%H"] > 19 } {
    set url [clock format [clock seconds] -format "http://www.mesogios.gr/arxeio/%Y/%m/%d/index.htm"]
} else {
    set url http://www.mesogios.gr/arxeio/2006/03/01/index.htm
}
ad_returnredirect ${url}