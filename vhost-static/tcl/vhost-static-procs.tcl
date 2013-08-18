# if you plan to use fastpath, use: ns_server -server [ns_info server] pagedir

# get_pagedir_default
proc get_pagedir_ {} { return /web/data/build/resources }


#ns_log notice "url=$url file=$file url2file=[ns_url2file $url] conn_pool=[ns_conn pool]"
#ns_log notice "ns_config ns/server/[ns_info server]/pool/[ns_conn pool] add_header"

array set connection_pools_arr [ns_set array [ns_configsection ns/server/[ns_info server]/pools]]
set connection_pools [array names connection_pools_arr]
ns_log notice "connection pools = $connection_pools"
foreach pool ${connection_pools} {

    set pagedir [ns_config ns/server/[ns_info server]/pool/${pool} "x-root"]
    proc get_pagedir_${pool} {} "return [list ${pagedir}]"

    set add_headers_extra ""
    set add_headers [ns_config ns/server/[ns_info server]/pool/${pool} "x-add-header"]
    foreach add_header ${add_headers} {
	lassign $add_header key value
	append add_headers_extra "\n" "ns_set put \${outputheaders} [list ${key}] [list ${value}]"
    }

    set expires_extra ""
    set expires [ns_config ns/server/[ns_info server]/pool/${pool} "x-expires"]
    if { ${expires} ne {} } {

	set re {([0-9]+)(s|m|h|d|w|M|y)}

	# off prevents changes to the Expires and Cache-Control headers. 
	# epoch sets the Expires header to 1 January, 1970 00:00:01 GMT
	# max sets the Expires header to 31 December 2037 23:59:59 GMT, and the Cache-Control max-age to 10 years. 
	# Note: expires should only work for 200, 204, 301, 302, and 304 responses. 

	if { ${expires} eq {epoch} } {

	    append expires_extra "\n" "ns_set put \${outputheaders} \{Expires\} \{Thu, 1 January, 1970 00:00:01 GMT\}"

	} elseif { ${expires} eq {max} } {

	    append expires_extra "\n" "ns_set put \${outputheaders} \{Expires\} \{Thu, 31 Dec 2037 23:55:55 GMT\}"

	    append expires_extra "\n" "ns_set put \${outputheaders} \{Cache-Control\} \{max-age=315360000\}"

	} elseif { [regexp -- ${re} ${expires} _whole_ num precision] } {

	    switch -exact ${precision} {
		s  { set secs ${num} }
		m  { set secs [expr { ${num} * 60 }] }
		h  { set secs [expr { ${num} * 3600 }] }
		d  { set secs [expr { ${num} * 86400 }] }
		w  { set secs [expr { ${num} * 86400 * 7 }] }
		M  { set secs [expr { ${num} * 86400 * 30 }] }
		y  { set secs [expr { ${num} * 86400 * 365 }] }
	    }

	    append expires_extra "\n" "ns_set put \${outputheaders} \{Expires\} \[ns_httptime \[ns_time incr \[ns_time\] ${secs}\]\]"

	    append expires_extra "\n" "ns_set put \${outputheaders} \{Cache-Control\} \{max-age=${secs}\}"
	    

	}

    }

    set code {}
    if { ${add_headers_extra} ne {} || ${expires_extra} ne {} } {
	set code {}
	append code "\n" {set outputheaders [ns_conn outputheaders]}
	append code ${expires_extra}
	append code ${add_headers_extra}
    }

    # ns_log notice "process_outputheaders_${pool} ${code}"

    proc process_outputheaders_${pool} {} ${code}
}


proc serve_static_file {} {

    set url [ns_conn url]

    set pool [ns_conn pool] 

    # TODO: url2file - check if array exists / otherwise create it yourself
    set file [file normalize [get_pagedir_${pool}]/${url}]

    if { ![file isfile $file] || ![file readable $file]} {
	ns_log notice "pool=$pool file=$file not found - return 404" 
	ns_returnnotfound
	return
    }

    set mime [ns_guesstype ${file}]
    set headers [ns_conn headers]
    if {[ns_conn zipaccepted] && [ns_set iget ${headers} Range] eq {}} {
	set gzip_file ${file}.gz
	if { [file readable ${gzip_file}] } {
	    set file ${gzip_file}
	    set outputheaders [ns_conn outputheaders]
	    ns_set put ${outputheaders} Vary Accept-Encoding
	    ns_set put ${outputheaders} Content-Encoding gzip
	}
    }

    process_outputheaders_${pool}

    ns_returnfile 200 ${mime} ${file}

}

ns_unregister_op GET /
ns_unregister_op POST /
ns_unregister_op HEAD /

ns_register_proc GET / serve_static_file
ns_register_proc POST / serve_static_file
ns_register_proc HEAD / serve_static_file

#ns_register_proxy
