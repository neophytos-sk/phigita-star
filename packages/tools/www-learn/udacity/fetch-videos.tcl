set url "http://gdata.youtube.com/feeds/api/videos?author=Udacity&v=2"


for {set i 1} {$i < 10} {incr i} {
    set filename "udacity-${i}"
    set startIndex [expr { $i * 10 }]
    set api_url "\"${url}&start-index=${startIndex}\""
    exec /bin/sh -c "wget -O $filename $api_url || exit 0" 2> /dev/null
}
