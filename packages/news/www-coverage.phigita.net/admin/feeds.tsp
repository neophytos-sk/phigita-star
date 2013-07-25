namespace eval ::tmpl {
    dom createNodeCmd -returnNodeCmd elementNode option
}

set channeldata [db::Set new -pool newsdb -type ::sw::agg::Url -where [list "feed_p" "NOT buzz_p" "(language is null or language='el')"] -order "url"]
$channeldata load


set classList [db::Set new -pool newsdb -type ::classification::Class -order tree_sk]
$classList load



tmpl::master {	     


a -href "classification/" {
	t Categories
}
t " - "
a -href "reclassify?numHours=36" {
	t Reclassify
}
t " - "
a -href "recluster?numHours=36" {
	t Recluster
}
t " - "
a -href "news-test" {
	t "Admin News Items"
}
p


style {
	c {
		.big { font-size: 20px; width:400; padding: 5px; }
        }
}


    form -action "feed-add" -method "post" {
	t "URL: "
        input -name url -type text
	br
	t "Guard: "
	input -name guard -type input -class big
	br
	t "Topic: "
	select -name classification__tree_sk {
	    option -value "" { t "None" }
	    foreach classObject [$classList set result] {
		set optionNode [tmpl::option -value [$classObject set tree_sk] {
		    t "[::util::pad [$classObject set id] 3] - [$classObject set tree_sk]"
		}]
	    }
	}
	t "Edition: "
	input -type input -name classification__edition_sk -value ""
        input -type submit -value "Add Feed"
    }


    h3 { t "[llength [$channeldata set result]] News Channels" }
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
		    t "\]"
		    t " \["
		    a -href ttext-tidy?url=[$o set url] {
			t tidy
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
			li {
			    form -action class-change -method get {
				input -type hidden -name url -value [$o set url]
				t "Topic: "
				select -name classification__tree_sk {
				    option -value "" { t "None" }
				    foreach classObject [$classList set result] {
					set optionNode [tmpl::option -value [$classObject set tree_sk] {
					    t "[util::pad [$classObject set id] 0] - [$classObject set tree_sk]"
					}]
					if { [$classObject set tree_sk] == [$o set classification__tree_sk] } {
					    $optionNode setAttribute selected ""
					}
				    }
				}
				input -type submit -value "Change"
			    }
			}
			li {
			    form -action guard-change -method post {
				input -type hidden -name url -value [$o set url]
				t "Guard: "
				input -class big -type input -name guard -size 40 -value [$o set guard]
				input -type submit -value "Save"
			    }
			}
			li {
			    form -action edition-change -method post {
				input -type hidden -name url -value [$o set url]
				t "Edition: "
				input -type input -name classification__edition_sk -value [$o set classification__edition_sk]
				input -type submit -value "Change Edition"
			    }
			}
			li {
			    t "URL SHA1: [$o set url_sha1]"
			}
		    }
		}
	    }
	}
    }
}