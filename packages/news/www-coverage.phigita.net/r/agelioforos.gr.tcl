
# example: http://www.mesogios.gr/arxeio/2005/10/19/index.htm
set url [clock format [clock seconds] -format "http://www.agelioforos.gr/archive/topics.asp?month=%m&year=%Y"]
ad_returnredirect ${url}