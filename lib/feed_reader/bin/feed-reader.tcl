#!/usr/bin/tclsh

# TODO: extract comments from article pages

source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require feed_reader

#set dir [file dirname [info script]]
#source [file join ${dir} feed-procs.tcl]


proc print_usage_info {} {
    upvar argv0 argv0

    array set cmdinfo [list \
			   "sync" "?news_source? ?...?" \
			   "search" "keyword ?...?" \
			   "show" "urlsha1 ?...?" \
			   "show-url" "article_url" \
			   "show-content" "contentsha1 ?...?" \
			   "uses-content" "contentsha1 ?...?" \
			   "diff-content" "contentsha1_old contentsha1_new" \
			   "list" "?offset? ?limit?" \
			   "list-site" "domain ?offset? ?limit?" \
			   "revisions" "urlsha1" \
			   "register-axis" "axis_name" \
			   "register-label" "axis_name label_name" \
			   "test" "domain feed_name ?limit? ?fetch_item_p?" \
			   "remove-feed-items" "domain ?sort_date.urlsha1? ?...?" \
			   "cluster" "?limit? ?offset?" \
			   "label" "axis class contentsha1 ?...?" \
			   "unlabel" "axis class contentsha1 ?...?" \
			   "fex" "?limit? ?offset?" \
			   "stats" "?domain? ?...?" \
			   "wc" "?contentsha1? ?...?" \
			   "test-article" "domain feed_name article_url" \
			   "generate-feed" "feed_url"]


    foreach cmd [lsort [array names cmdinfo]] {
	puts "Usage: $argv0 ${cmd} $cmdinfo(${cmd})"
    }

}

set argc [llength $argv]
if { ${argc} < 1 } {

    print_usage_info

} else {

    set cmd [lindex $argv 0]

    if { ${cmd} eq {sync} && ${argc} >= 1 } {

        ::feed_reader::sync_feeds [lrange ${argv} 1 end]

    } elseif { ${cmd} eq {generate-feed} && ${argc} >= 2 } {

        ::feed_reader::generate_feed {*}[lrange ${argv} 1 end]

    } elseif { ${cmd} eq {test-article} && ${argc} == 4 } {

        ::feed_reader::test_article {*}[lrange ${argv} 1 end]

    } elseif { ${cmd} eq {test} && ${argc} >= 2} {

        set news_source [lindex ${argv} 1]
        ::feed_reader::test_feed ${news_source} {*}[lrange ${argv} 2 end]

    } elseif { ${cmd} eq {stats} && ${argc} >= 1} {

        ::feed_reader::stats [lrange ${argv} 1 end]

    } elseif { ${cmd} eq {show} && ${argc} >= 2 } {

        set urlsha1_list [lrange ${argv} 1 end]
        ::feed_reader::show_item ${urlsha1_list}

    } elseif { ${cmd} eq {wc} && ${argc} >= 1 } {

        set contentsha1_list [lrange ${argv} 1 end]
        ::feed_reader::wordcount ${contentsha1_list}

    } elseif { ${cmd} eq {search} && ${argc} >= 2 } {

        set keywords [lrange ${argv} 1 end]
        ::feed_reader::search ${keywords}

    } elseif { ${cmd} eq {revisions} && ${argc} == 2 } {

        set urlsha1 [lindex ${argv} 1]
        ::feed_reader::show_revisions ${urlsha1}

    } elseif { ${cmd} eq {register-axis} && ${argc} == 2 } {

        set axis [lindex ${argv} 1]
        ::feed_reader::classifier::register_axis ${axis}
        
    } elseif { ${cmd} eq {register-label} && ${argc} == 3 } {

        set axis [lindex ${argv} 1]
        set label [lindex ${argv} 2]
        ::feed_reader::classifier::register_label ${axis} ${label}

    } elseif { ${cmd} eq {show-url} && ${argc} == 2 } {

        set article_url [lindex ${argv} 1]
        ::feed_reader::show_item_from_url ${article_url}


    } elseif { ${cmd} eq {show-content} && ${argc} >= 2 } {

        set contentsha1_list [lrange ${argv} 1 end]
        ::feed_reader::show_content ${contentsha1_list}

    } elseif { ${cmd} eq {diff-content} && ${argc} == 3 } {

        set contentsha1_old [lindex ${argv} 1]
        set contentsha1_new [lindex ${argv} 2]
        ::feed_reader::diff_content ${contentsha1_old} ${contentsha1_new}

    } elseif { ${cmd} eq {uses-content} && ${argc} >= 2 } {

        set contentsha1_list [lrange ${argv} 1 end]
        ::feed_reader::uses_content ${contentsha1_list}	

    } elseif { ${cmd} eq {list} && ${argc} >= 1 } {

        ::feed_reader::list_all {*}[lrange ${argv} 1 end]

    } elseif { ${cmd} eq {list-site} && ${argc} >= 2 } {

        set news_source [lindex ${argv} 1]
        ::feed_reader::list_site ${news_source} {*}[lrange ${argv} 2 end]

    } elseif { ${cmd} eq {remove-feed-items} && ${argc} >= 2 } {

        set news_source [lindex ${argv} 1]
        set urlsha1_list [lrange ${argv} 2 end]
        ::feed_reader::remove_feed_items ${news_source} ${urlsha1_list}

    } elseif { ${cmd} eq {cluster} && ${argc} >= 1 } {

        ::feed_reader::cluster {*}[lrange ${argv} 1 end]

    } elseif { ${cmd} eq {label} && ${argc} >= 1 } {

        # label axis class contentsha1 ...
        #
        # e.g. label spam true ae23ff acb673
        # e.g. label priority important example123 example456
        # e.g. label topic politics  example742 example888 example923 example443
        # e.g. label edition cyprus  example742 example888 example923 example443
        set axis [lindex ${argv} 1]
        set label [lindex ${argv} 2]
        set contentsha1_list [lrange ${argv} 3 end]
        ::feed_reader::classifier::label ${axis} ${label} ${contentsha1_list}

    } elseif { ${cmd} eq {unlabel} && ${argc} >= 1 } {

        # unlabel axis class contentsha1 ...

        set axis [lindex ${argv} 1]
        set label [lindex ${argv} 2]
        set contentsha1_list [lrange ${argv} 3 end]
        ::feed_reader::classifier::unlabel ${axis} ${label} ${contentsha1_list}

    } elseif { ${cmd} eq {fex} && ${argc} >= 1 } {

        # TODO: word substrings, isFirstCapital, isLastPunct, isLastColon
        # TODO: word shapes:
        #    Varixella-zoster  Xx-xxx
        #    mRNA              xXXX
        #    CPA1              XXXd
        # hasDigit
        

        ::feed_reader::feature_extraction {*}[lrange ${argv} 1 end]

    } else {

        print_usage_info

    }

}
