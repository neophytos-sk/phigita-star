package require core

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
    puts "typeof('${str}') = [::pattern::typeof $str]"
}



set url1 "http://www.japantimes.co.jp/news/2015/07/18/national/tokyo-opens-citys-first-swimming-beach-since-1960s/"
set fmt1 [url fmt_ex $url1]
puts "url_match($fmt1,$url1) => [url match $fmt1 $url1]"

set url2 "http://www.hurriyetdailynews.com/shifts-to-shuffles.aspx?pageID=238&nID=85330&NewsCatID=473"
set fmt2 [url fmt_ex $url2]
#set fmt2 "%T?pageID=%N&nID=%N&NewsCatID=%N"
puts "url_match($fmt2,$url2) => [url match $fmt2 $url2]"
puts "url_match($fmt2,$url1) => [url match $fmt2 $url1]"
puts "url_match($fmt1,$url2) => [url match $fmt1 $url2]"

set url3 "http://www.kepa.gov.cy/em/BusinessDirectory/Company/CompanyProduct.aspx?CompanyId=2b674aab-7c3e-4e12-ab09-6d852b507a56&ProductId=cffcf1e6-efcc-41df-8e6d-46efbeabf097"
set fmt3 [url fmt_ex $url3]
puts "url_match($fmt3,$url3) => [url match $fmt3 $url3]"
