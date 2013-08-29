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


proc ::feed_reader::classifier::learn_naive_bayes_text {multirow_slice_names categories {modelVar ""}} {

    if { $modelVar ne {} } {
	upvar $modelVar probability
    }

    set probability(categories) ${categories}

    array set vocabulary [list]
    foreach slicelist ${multirow_slice_names} category ${categories} {

	array set count_${category} [list]

	foreach contentsha1 ${slicelist} {

	    set filename \
		[::persistence::get_column                   \
		     "newsdb"                                \
		     "content_item/by_contentsha1_and_const" \
		     "${contentsha1}"                        \
		     "_data_"]

	    if { ![::persistence::exists_data_p ${filename}] } {
		continue
	    }

	    set content [join [::persistence::get_data ${filename}]]


	    wordcount_helper wordcount_${category} content

	}

	foreach word [array names wordcount_${category}] {
	    set vocabulary(${word}) 1
	}


	set slicelen [llength ${slicelist}]
	set num_docs(${category}) $slicelen
	set num_words(${category}) [array size wordcount_${category}]

	incr total_docs ${slicelen}
	#puts "num_words(${category})=$num_words(${category})"
	#puts "num_docs(${category})=$num_docs(${category})"

    }

    set vocabulary_size [array size vocabulary]

    puts total_words_in_vocabulary=$vocabulary_size

    foreach category ${categories} {

	set probability(cat_${category}) \
	    [expr { $num_docs(${category}) / double(${total_docs})  }]


	foreach {word num_occurrences} [array get wordcount_${category}] {

	    set probability(word_${word},${category})\
		[expr { double( ${num_occurrences} + 1 ) / double( $num_words(${category}) + ${vocabulary_size} ) }]

	}

    }


}

proc ::feed_reader::classifier::save_naive_bayes_model {modelVar axis} {

    upvar $modelVar model

    ::persistence::insert_column \
	"newsdb" \
	"classifier/model" \
	"${axis}" \
	"_data_" \
	[array get model]

}


proc ::feed_reader::classifier::load_naive_bayes_model {modelVar axis} {

    upvar $modelVar model

    ::persistence::get_column \
	"newsdb" \
	"classifier/model" \
	"${axis}" \
	"_data_" \
	"column_data"

    array set model ${column_data}

}


proc ::feed_reader::classifier::classify_naive_bayes_text {modelVar contentVar} {

    upvar $modelVar pr
    upvar $contentVar content


    set categories $pr(categories)

    set max_pr -9999999999 ;# 0
    set max_category ""
    foreach category ${categories} {
	#set p 1.0
	set p 0.0
	foreach token [lsort -unique [::util::tokenize ${content}]] {
	    set pr_word_given_cat [get_value_if pr(word_${token},${category}) "0.5"]
	    #set p [expr { ${p} * $pr_word_given_cat }]
	    set p [expr { ${p} + log(${pr_word_given_cat}) }]
	}
	#set p [expr { $pr(cat_${category}) * ${p} }]
	set p [expr { log($pr(cat_${category})) + ${p} }]

	if { ${p} > ${max_pr} } {
	    set max_pr ${p}
	    set max_category ${category}
	}

	puts "$category p=$p"
    }

    puts max_pr=$max_pr
    puts max_category=$max_category
    puts ---

}

proc ::feed_reader::classifier::train {axis {categories ""}} {

    #set axis "el.utf8.topic"
    set categories {politics sports}

    set multirow_predicate [list "in" [list ${categories}]]

    set multirow_slice \
	[::persistence::get_multirow_slice_names \
	     "newsdb"                            \
	     "classifier/${axis}"                \
	     "${multirow_predicate}"]

    learn_naive_bayes_text ${multirow_slice} ${categories} model

    save_naive_bayes_model model ${axis}
    

}

proc ::feed_reader::classifier::classify {axis contentVar} {

    upvar $contentVar content

    load_naive_bayes_model model ${axis}

    classify_naive_bayes_text model content

}



proc ::feed_reader::classifier::filter_stopwords {resultVar tokensVar} {

    upvar $resultVar result
    upvar $tokensVar tokens

    variable stopwords

    set result [list]
    foreach token ${tokens} {
	if { [info exists stopwords(${token})] } {
	    continue
	}
	lappend result ${token}
    }

}



proc ::feed_reader::classifier::wordcount_helper {countVar contentVar} {

    upvar $countVar count
    upvar $contentVar content

    # remove embedded content and urls
    set re {\{[^\}]+\}|https?://[^\s]+}
    regsub -all -- ${re} ${content} { } content

    set tokens0 [::util::tokenize ${content}]

    filter_stopwords tokens tokens0

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

    package require struct::prioqueue

    set pq [struct::prioqueue::prioqueue -integer]

    foreach {token prio} [array get count] {
	set item [array get count ${token}]
	${pq} put ${item} ${prio}
	#puts [list ${name} $count(${name})]
    }

    set limit 50
    while { [${pq} size] && [incr limit -1] } {
	set item [${pq} peek]
	#puts ${item}
	lassign ${item} token wc
	puts ${token}
	${pq} remove ${item}
    }

    ${pq} destroy

}
