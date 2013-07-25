
# example: http://www.haravgi.com.cy/13_10_2005/main.html
set url [clock format [clock seconds] -format "http://www.haravgi.com.cy/%d_%m_%Y/main.html"]
ad_returnredirect ${url}