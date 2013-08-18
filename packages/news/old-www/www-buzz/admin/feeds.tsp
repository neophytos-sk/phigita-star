set channeldata [db::Set new -pool newsdb -type ::buzz::Feed -where [list "feed_p" "buzz_p" "(language is null or language='el')"] -order "last_crawl desc"]
$channeldata load

tmpl::master {	     

    form -action "feed-add" -method "post" {
	t "URL: "
        input -name url -type text
	br
	t "Guard: "
	input -name guard -type input -class big
	br
	t "Edition: "
	input -type input -name classification__edition_sk -value ""
        input -type submit -value "Add Feed"
    }


    h3 { t "[llength [$channeldata set result]] Buzz Channels" }
    ul {
	foreach o [$channeldata set result] {
	    array set uri [uri::split [$o set url]]
	    li {
		a -href ../?host=$uri(host) {
		    t $uri(host)
		}
		small {
		    t " \["
		    a -href [$o set url] {
			t feed
		    }
	t " | "
		    a -href feed-status-toggle?url=[ns_urlencode [$o set url]]&active_p=[::util::decode [$o set active_p] t f f t] {
			t [::util::decode [$o set active_p] t disable f enable]
		    }
		    t "\]"
		    ul {
			li {
			    t "Last Crawl: [$o set last_crawl]"
			}
			li {
			    t "Crawl Interval: [$o set crawl_interval]"
			}
			li {
			    t "Language: [$o set language]"
			}
		    }
		}
	    }
	}
    }
}