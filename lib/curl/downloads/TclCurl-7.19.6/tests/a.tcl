package require TclCurl

curl::init

curl1 configure -url "http://www.hola.es"
curl1 configure -timeout 30
curl1 configure -sslverifypeer 0
curl1 configure -usessl all
curl1 configure -ftpsslauth tls
curl1 configure -username ftpuser
curl1 configure -password ftppass
curl1 configure -proxy proxy:port
curl1 configure -proxytype socks5
curl1 configure -proxyuserpwd user:pwd
curl1 configure -ftpuseepsv 0
curl1 configure -customrequest "site stat"
curl1 configure -verbose 1

curl1 cleanup






