set url [clock format [clock seconds] -format "http://www.cna.org.cy/website/pr_results2.asp?from_date=%d/%m/%Y&to_date=%d/%m/%Y"]
ad_returnredirect ${url}