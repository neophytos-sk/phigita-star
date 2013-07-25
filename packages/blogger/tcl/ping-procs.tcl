namespace eval ::blogger {;}

proc ::blogger::ping {} {

    set format_string {<?xml version="1.0"?>
	<methodCall>
	<methodName>weblogUpdates.ping</methodName>
	<params>
	<param>
	<value>%s</value>
	</param>
	<param>
	<value>%s</value>
	</param>
	</params>
	</methodCall>
    }

    set rpc_endpoint "http://rpc.technorati.com/rpc/ping"

# "BlogFlux"       http://pinger.blogflux.com/rpc/
# "Syndic8"        http://ping.syndic8.com/xmlrpc.php
# "FeedSky"        http://www.feedsky.com/api/RPC2
# "BulkFeeds"      http://bulkfeeds.net/rpc
# "NewsGator"      http://services.newsgator.com/ngws/xmlrpcping.aspx
# "Blog Update"    http://blogupdate.org/ping/
# "Moreover"       http://api.moreover.com/RPC2
#	"Technorati"     http://rpc.technorati.com/rpc/ping

    foreach {service_name rpc_endpoint} {
	"Google"         http://blogsearch.google.com/ping/RPC2
	"Weblogs.com"    http://rpc.weblogs.com/RPC2
	"Feed Burner"    http://ping.feedburner.com/
	"BlogRolling"    http://rpc.blogrolling.com/pinger/
	"Ping-o-Matic"  http://rpc.pingomatic.com/
	"Blog People"    http://www.blogpeople.net/servlet/weblogUpdates
	"Howly Cow Dude" http://www.holycowdude.com/rpc/ping/
    } {

	set service_name [string map {" " "_"} $service_name]

	set curl [::xo::comm::CurlHandle new -method POST -url $rpc_endpoint]

	set limit 100
	set data [::db::Set new \
		      -select {bs.user_id first_names last_name screen_name last_shared_entry} \
		      -type [::db::Inner_Join new \
				 -join_condition "cc.user_id=bs.user_id" \
				 -rhs [::db::Set new -select {user_id screen_name first_names last_name} -alias cc -from CC_Users] \
				 -lhs [::db::Set new \
					   -alias bs \
					   -type ::sw::agg::Blog_Stats \
					   -limit ${limit} \
					   -order "last_shared_entry" \
					   -where [list "last_shared_entry > coalesce(extra->[ns_dbquotevalue ${service_name}.last_ping],'1977-09-27')::timestamp"]]] \
		      -limit ${limit} \
		      -order "last_shared_entry"]

	${data} load


	foreach o [$data set result] {

	    ns_log notice "Ping ${service_name} for user_id=[$o set user_id]"

	    set blog_name "[$o set first_names] [$o set last_name] (~[$o set screen_name]) > Blog"
	    set blog_url http://www.phigita.net/~[$o set screen_name]/blog/
	    set xml [format $format_string $blog_name $blog_url]
	    
	    [$curl set curlHandle] configure -postfields $xml -httpheader {Content-Type: text/xml}
  
	    set ${curl}::curlResponseBody ""
	    if { [catch "$curl perform" errmsg] } {
		ns_log notice "errmsg, ping service_name=$service_name user_id=[$o set user_id] errmsg=$errmsg"
	    } else {

		if { [set ${curl}::curlResponseBody] ne {} } {
		    # dom parse -simple [set ${curl}::curlResponseBody] docId
		    set response [set ${curl}::curlResponseBody]
		    if { [catch {

			set sql  "update xo.xo__sw__agg__blog_stats set extra=coalesce(extra,''::hstore) || ([ns_dbquotevalue ${service_name}.last_ping]=>current_timestamp::text)::hstore || ([ns_dbquotevalue ${service_name}.last_response]=>[::util::dbquotevalue $response])::hstore where user_id=[ns_dbquotevalue [$o set user_id]]"

			### ns_log notice "ping-procs.tcl: sql=$sql"

			[$data getConn] do $sql

		    } errmsg] } {
			ns_log notice "ping-procs.tcl, saving response errmsg=$errmsg"
		    }

		}

	    }
	    
	}

	$curl destroy

    }

}