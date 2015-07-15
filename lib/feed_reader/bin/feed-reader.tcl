#!/usr/bin/tclsh

# TODO: extract comments from article pages

package require core

source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require feed_reader

#set dir [file dirname [info script]]
#source [file join ${dir} feed-procs.tcl]


proc print_usage_info {} {
    upvar argv0 argv0

    array set cmdinfo [list \
			   "sync" "?news_source? ?...?" \
			   "resync" ""\
			   "search" "keywords offset limit" \
			   "show" "urlsha1 ?...?" \
			   "show-url" "article_url" \
			   "show-content" "contentsha1 ?...?" \
			   "train" "axis"\
			   "classify" "axis urlsha1 ?...?" \
			   "classify-content" "axis contentsha1 ?...?" \
			   "uses-content" "contentsha1 ?...?" \
			   "diff-content" "contentsha1_old contentsha1_new" \
			   "list" "?offset? ?limit?" \
			   "list-site" "domain ?offset? ?limit?" \
			   "revisions" "urlsha1" \
			   "register-axis" "axis_name" \
			   "register-label" "axis_name label_name" \
			   "test" "news_source ?limit? ?fetch_item_p? ?exclude_keys?" \
			   "remove-feed-items" "domain ?sort_date.urlsha1? ?...?" \
			   "cluster" "?limit? ?offset?" \
			   "label-interactive" "axis label keywords ?offset? ?limit? ?callback?" \
			   "label-batch" "axis label keywords ?offset? ?limit?" \
			   "rename-label" "axis old_name new_name" \
			   "label" "axis class contentsha1 ?...?" \
			   "unlabel-interactive" "axis label keywords ?offset? ?limit? ?callback?" \
			   "unlabel" "axis class contentsha1 ?...?" \
			   "list-training-labels" "axis ?supercolumn_path?" \
			   "link-label" "target_axis/+/target_supercolumn_path link_axis/+/link_supercolumn_path" \
			   "fex" "?limit? ?offset?" \
			   "stats" "?domain? ?...?" \
			   "wc" "?contentsha1? ?...?" \
			   "curl" "url" \
			   "test-article" "domain feed_name article_url" \
			   "generate-feed" "feed_url ?anchor_link_keyword? ?encoding?"]


    foreach cmd [lsort [array names cmdinfo]] {
        puts "Usage: $argv0 ${cmd} $cmdinfo(${cmd})"
    }

}

proc parse_args {{argsVar "args"}} {
    upvar $argsVar args
}

proc ls {args} {

    rewrite_args {
        -a,--all        => -all_p
        -l,--long       => -long_p
        -A,--almost-all => -almost_all_p
    }

    parse_args {
        -all_p
        -almost_all_p
        -long_p
        {-something "123"}
        feed_name
    }

    vcheck_vars {
        all_p {boolean}
        almost_all_p {boolean}
        long_p {boolean}
        something {naturalnum}
        feed_name {ascii}
    }

    assert { vcheck("boolean",${all_p}) }

    # argtype varname vcheck_list 
    @opt {-a --all}         all_p           {boolean}
    @opt {-A --almost-all}  almost_all_p    {boolean}
    @opt {-l}               long_p          {boolean} "use long listing format"
    @arg {}                 feed_name       {ascii}

    @arg feed_name {ascii}

    # @arg vcheck_list varname short_option long_option
    foreach {quantifier argtype varname vcheck_list short_option long_option} {
        optional flag all_p -a --all
        optional flag almost_all_p -A --almost-all
        optional flag long_listing_p -s "l" -l "long-listing"
        required arg feed_name {ascii}
    } {
        set $varname [ns_set get args $long_option $argtype]
        foreach pattern_name $vcheck_list {
            assert { vcheck(${pattern_name}, ${long-listing}) }
        }

    }


    assert { !( exists("all_p") && exists("almost_all_p") ) } {
        ## Conflict Resolution
        #  prefer exists(all_p) over exists(almost_all_p)
        disable_flag almost_all_p
    }

}

set argc [llength $argv]
if { ${argc} < 1 } {

    print_usage_info

} else {

    set cmd [lindex $argv 0]

    if { ${cmd} eq {sync} && ${argc} >= 1 } {

        ::feed_reader::sync_feeds [lrange ${argv} 1 end]

    } elseif { ${cmd} eq {resync} && ${argc} == 1 } {

        ::feed_reader::resync

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
        ::feed_reader::classifier::wordcount ${contentsha1_list}

    } elseif { ${cmd} eq {search} && ${argc} >= 2 } {

        set keywords [lindex ${argv} 1]
        ::feed_reader::search ${keywords} {*}[lrange ${argv} 2 end]

    } elseif { ${cmd} eq {label-interactive} && ${argc} >= 2 } {

	set axis [lindex ${argv} 1]
	set label [lindex ${argv} 2]
        set keywords [lindex ${argv} 3]
        ::feed_reader::label_interactive ${axis} ${label} ${keywords} {*}[lrange ${argv} 4 end]

    } elseif { ${cmd} eq {unlabel-interactive} && ${argc} >= 2 } {

	set axis [lindex ${argv} 1]
	set label [lindex ${argv} 2]
        set keywords [lindex ${argv} 3]
        ::feed_reader::unlabel_interactive ${axis} ${label} ${keywords} {*}[lrange ${argv} 4 end]

    } elseif { ${cmd} eq {label-batch} && ${argc} >= 2 } {

	set axis [lindex ${argv} 1]
	set label [lindex ${argv} 2]
        set keywords [lindex ${argv} 3]
        ::feed_reader::label_batch ${axis} ${label} ${keywords} {*}[lrange ${argv} 4 end]

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

    } elseif { ${cmd} eq {train} && ${argc} == 2 } {
	
	set axis [lindex ${argv} 1]
        ::feed_reader::classifier::train ${axis}

    } elseif { ${cmd} eq {classify} && ${argc} >= 3 } {

        set axis [lindex ${argv} 1]
        set urlsha1_list [lrange ${argv} 2 end]
        ::feed_reader::classify ${axis} ${urlsha1_list}

    } elseif { ${cmd} eq {classify-content} && ${argc} >= 3 } {

        set axis [lindex ${argv} 1]
        set contentsha1_list [lrange ${argv} 2 end]
        ::feed_reader::classify_content ${axis} ${contentsha1_list}

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

    } elseif { ${cmd} eq {list-training-labels} && ${argc} >= 2 } {

        set axis [lindex ${argv} 1]
        ::feed_reader::classifier::list_training_labels ${axis} {*}[lrange ${argv} 2 end]

    } elseif { ${cmd} eq {link-label} && ${argc} == 3 } {

        set target_path [lindex ${argv} 1]
	set link_path [lindex ${argv} 2]
        ::feed_reader::classifier::link_label ${target_path} ${link_path}

    } elseif { ${cmd} eq {rename-label} && ${argc} == 4 } {

        set axis [lindex ${argv} 1]
	set old_name [lindex ${argv} 2]
	set new_name [lindex ${argv} 3]
        ::feed_reader::classifier::rename_label ${axis} ${old_name} ${new_name}

    } elseif { ${cmd} eq {fex} && ${argc} >= 1 } {

        # TODO: word substrings, isFirstCapital, isLastPunct, isLastColon
        # TODO: word shapes:
        #    Varixella-zoster  Xx-xxx
        #    mRNA              xXXX
        #    CPA1              XXXd
        # hasDigit
        

        ::feed_reader::feature_extraction {*}[lrange ${argv} 1 end]

    } elseif { ${cmd} eq {curl} && ${argc} == 2 } {

        set url [lindex ${argv} 1]
        ::feed_reader::curl $url

    } else {

        print_usage_info

    }

}
