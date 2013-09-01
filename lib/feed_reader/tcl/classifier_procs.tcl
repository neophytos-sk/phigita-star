::xo::lib::require naivebayes

namespace eval ::feed_reader::classifier {;}

proc ::feed_reader::classifier::get_classifier_dir {} {
    return [::feed_reader::get_base_dir]/classifier
}

proc ::feed_reader::classifier::check_axis_name {axis} {
    set re {^[[:alpha:]]{2}.utf8.[[:alnum:]]+$}
    if { ![regexp -- ${re} ${axis}] } {
	error "axis=${axis} name must be of the form lang.encoding.alnum, for example, el.utf8.topic"
    }
}

proc ::feed_reader::classifier::register_axis {axis} {

    check_axis_name ${axis}

    set classifier_dir [get_classifier_dir]
    set axis_dir ${classifier_dir}/${axis}

    file mkdir ${axis_dir}

}

proc ::feed_reader::classifier::get_axis_names {} {
   set classifier_dir [get_classifier_dir]
    return [lsort [glob -tails -directory ${classifier_dir} *]]
}

proc ::feed_reader::classifier::get_label_names {axis} {
    set axis_dir [get_classifier_dir]/${axis}
    return [lsort [glob -tails -directory ${axis_dir} *]]
}

proc ::feed_reader::classifier::register_label {axis label} {

    check_axis_name ${axis}

    set re {^[[:lower:][:digit:]_]+$}
    if { ![regexp -- ${re} ${label}] } {
	error "label name must be an alphanumeric string"
    }

    set classifier_dir [get_classifier_dir]
    set axis_dir ${classifier_dir}/${axis}
    set label_dir ${axis_dir}/${label}

    if { ![file isdirectory ${axis_dir}] } {
	puts "${axis} is not a registered axis name"
	puts "registered axis names:"
	puts [join [get_axis_names] "\n"]
	puts ---
	error "${axis} is not a registered axis name"
    }



    file mkdir ${label_dir}

}

proc ::feed_reader::classifier::label {axis label contentsha1_list} {

    set classifier_dir [get_classifier_dir]
    set axis_dir ${classifier_dir}/${axis}
    set label_dir ${axis_dir}/${label}

    if { ${axis} eq {} } {
	error "axis name cannot be empty string"
    }

    if { ${label} eq {} } {
	error "label name cannot be empty string"
    }

    if { ![file isdirectory ${axis_dir}] } {
	puts "${axis} is not a registered axis name"
	puts "registered axis names:"
	puts [join [get_axis_names] "\n"]
	puts ---
	error "${axis} is not a registered axis name"
    }

    if { ![file isdirectory ${label_dir}] } {
	puts "${label} is not a registered label name"
	puts "registered label names:"
	puts [join [get_label_names ${axis}] "\n"]
	puts ---
	error "${label} is not a registered label name"
    }

    set content_dir [::feed_reader::get_content_dir]
    set contentsha1_to_label_dir [::feed_reader::get_contentsha1_to_label_dir]

    if { ![file isdirectory ${contentsha1_to_label_dir}] } {
	file mkdir ${contentsha1_to_label_dir}
    }

    foreach contentsha1 ${contentsha1_list} {
	if { ![file exists ${content_dir}/${contentsha1}] } {
	    puts "no such content item contentsha1=${contentsha1}"
	    continue
	}

	# touch file
	close [open ${label_dir}/${contentsha1} "w"]

	set fp [open ${contentsha1_to_label_dir}/${contentsha1} "a"]
	puts $fp ${axis}/${label}
	close $fp
    }

}



proc ::feed_reader::classifier::unlabel {axis label contentsha1_list} {

    set classifier_dir [get_classifier_dir]
    set axis_dir ${classifier_dir}/${axis}
    set label_dir ${axis_dir}/${label}

    if { ${axis} eq {} } {
	error "axis name cannot be empty string"
    }

    if { ${label} eq {} } {
	error "label name cannot be empty string"
    }

    if { ![file isdirectory ${axis_dir}] } {
	puts "${axis} is not a registered axis name"
	puts "registered axis names:"
	puts [join [get_axis_names] "\n"]
	puts ---
	error "${axis} is not a registered axis name"
    }

    if { ![file isdirectory ${label_dir}] } {
	puts "${label} is not a registered label name"
	puts "registered axis names:"
	puts [join [get_label_names ${axis}] "\n"]
	puts ---
	error "${label} is not a registered label name"
    }

    set content_dir [::feed_reader::get_content_dir]
    set contentsha1_to_label_dir [::feed_reader::get_contentsha1_to_label_dir]

    if { ![file isdirectory ${contentsha1_to_label_dir}] } {
	file mkdir ${contentsha1_to_label_dir}
    }

    foreach contentsha1 ${contentsha1_list} {
	if { ![file exists ${content_dir}/${contentsha1}] } {
	    puts "no such content item contentsha1=${contentsha1}"
	    continue
	}


	file delete ${label_dir}/${contentsha1}

	set filename ${contentsha1_to_label_dir}/${contentsha1}
	set indexdata [::util::readfile ${filename}]
	set indexdata [lsearch -inline -all -not ${indexdata} ${axis}/${label}]
	if { ${indexdata} eq {} } {
	    file delete ${filename}
	} else {
	    ::util::writefile ${filename} ${indexdata}
	}
    }

}

proc ::feed_reader::classifier::clean_and_tokenize {contentVar {filter_stopwords_p 0}} { 

    upvar $contentVar content

    # remove embedded content and urls
    foreach re {
	{\{[^\}]+:\s*[^\}]+\}}
	{\{[^\}]+:\s*https?://[^\s]+\}}
	{\{[^\}]+:\s*https?://[^\s]+\}}
	{\"([^\}]+)\":[^\s]+}
	{https?://[^\s]+}
	{[^[:alnum:]]}
    } {
	regsub -all -- ${re} ${content} {\1 } content
    }

    set tokens0 [::util::tokenize ${content}]

    if { $filter_stopwords_p } {
	filter_stopwords tokens tokens0
	return ${tokens}
    }


    return ${tokens0}

}

# axis = el.utf8.topic (for example)
proc ::feed_reader::classifier::train {axis {categories ""}} {

    set categories {politics sports technology business society lifestyle}

    set multirow_predicate [list "in" [list ${categories}]]

    set multirow_categories \
	[::persistence::get_multirow_names \
	     "newsdb" \
	     "classifier/${axis}" \
	     "${multirow_predicate}"]

    set multirow_examples \
	[::persistence::get_multirow_slice_names \
	     "newsdb"                            \
	     "classifier/${axis}"                \
	     "${multirow_predicate}"]

    #::persistence::directed_join newsdb
    #  get_multirow_slice_names classifier/${axis}
    #  get_column content_item/by_contentsha1_and_const/%s/_data_

    proc directed_join {multirow_slice_names args} {
	set multirow_filelist [list]
	foreach names ${multirow_slice_names} { 
	    set filelist [list]
	    foreach name ${names} {
		set get_column_args [format ${args} ${name}]
		lappend filelist \
		    [::persistence::get_column {*}${get_column_args}]

	    } 
	    lappend multirow_filelist ${filelist}
	}
	return ${multirow_filelist}
    }
    

    set multirow_filelist \
	[directed_join ${multirow_examples} \
	     "newsdb" \
	     "content_item/by_contentsha1_and_const" \
	     "%s" \
	     "_data_"]

    ::naivebayes::learn_naive_bayes_text ${multirow_filelist} ${multirow_categories} model



    #learn_naive_bayes_text ${multirow_examples} ${multirow_categories} model
    #save_naive_bayes_model model ${axis}


    set filename \
	[::persistence::get_column \
	     "newsdb" \
	     "classifier/model" \
	     "${axis}" \
	     "_data_"]

    ::naivebayes::save_naive_bayes_model model ${filename}

}

proc ::feed_reader::classifier::classify {axis contentVar} {

    upvar $contentVar content

    set filename \
	[::persistence::get_column \
	     "newsdb" \
	     "classifier/model" \
	     "${axis}" \
	     "_data_"]

    ::naivebayes::load_naive_bayes_model model ${filename}

    return [::naivebayes::classify_naive_bayes_text model content]

}


namespace eval ::feed_reader::classifier {

}

proc ::feed_reader::classifier::filter_stopwords {resultVar tokensVar} {

    upvar $resultVar result
    upvar $tokensVar tokens

    variable ::feed_reader::stopwords

    set result [list]
    foreach token ${tokens} {
	if { [info exists stopwords(${token})] } {
	    continue
	}
	lappend result ${token}
    }

}

proc ::feed_reader::classifier::less_than_3 {num} {
    return [expr { ${num} < 3 }]
}


proc ::feed_reader::classifier::wordcount_helper {countVar contentVar {filter_stopwords_p 0}} {

    upvar $countVar count
    upvar $contentVar content

    set tokens [clean_and_tokenize content ${filter_stopwords_p}]

    foreach token ${tokens} {
	incr count(${token})
    }

}


# * TODO: bin packing for word cloud 
# * TODO: word cloud for each cluster
# * label interactive could show word coud to ease training
#
proc ::feed_reader::classifier::wordcount {{contentsha1_list ""}} {


    set multislicelist [::persistence::multiget_slice \
			    "newsdb" \
			    "content_item/by_contentsha1_and_const" \
			    "${contentsha1_list}"]

    array set count [list]
    foreach {contentsha1 slicelist} ${multislicelist} {

	# we know that slicelist is just one element
        # we are just keeping appearances here
	set contentfilename [lindex ${slicelist} 0]

	set content [join [::persistence::get_data $contentfilename]]

	wordcount_helper count content

    }

    print_words [wordcount_topN count]

}

proc ::feed_reader::classifier::print_words {words} {

    foreach token ${words} {
	puts -nonewline " ${token} "
	if { [incr x] % 10 == 0 } {
	    puts ""
	}
    }
    puts ""


}

proc ::feed_reader::classifier::wordcount_topN {countVar {limit "50"}} {

    upvar $countVar count

    package require struct::prioqueue

    set pq [struct::prioqueue::prioqueue -integer]

    foreach {token prio} [array get count] {
	set item [array get count ${token}]
	${pq} put ${item} ${prio}
	#puts [list ${name} $count(${name})]
    }

    set result [list]
    while { [${pq} size] && [incr limit -1] } {

	set item [${pq} peek]
	lassign ${item} token wc
	${pq} remove ${item}

	lappend result ${token}

    }

    ${pq} destroy


    return ${result}

}
