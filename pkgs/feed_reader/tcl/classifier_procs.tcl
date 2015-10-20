package require naivebayes

namespace eval ::feed_reader::classifier {;}

proc ::feed_reader::classifier::get_classifier_dir {} {
    return [::feed_reader::get_base_dir]/classifier
}

proc ::feed_reader::classifier::get_training_dir {} {
    return [::feed_reader::get_base_dir]/train_item
}

proc ::feed_reader::classifier::check_axis_name {axis} {
    set re {^[[:alpha:]]{2}/[[:alnum:]_]+$}
    if { ![regexp -- ${re} ${axis}] } {
	error "axis=${axis} name must be of the form lang/alnum (or underscore), for example, el/topic"
    }
}

proc ::feed_reader::classifier::register_axis {axis} {

    check_axis_name ${axis}

    set training_dir [get_training_dir]
    set axis_dir ${training_dir}/${axis}

    file mkdir ${axis_dir}

}

proc ::feed_reader::classifier::get_axis_names {} {
   set classifier_dir [get_classifier_dir]
    return [lsort [glob -tails -directory ${classifier_dir} *]]
}

# deprecated
proc ::feed_reader::classifier::get_label_names {axis} {
    set axis_dir [get_training_dir]/${axis}
    return [lsort [glob -tails -directory ${axis_dir} *]]
}

proc ::feed_reader::classifier::register_label {axis label} {

    check_axis_name ${axis}

    set re {^[[:lower:][:digit:]_]+(/[[:lower:][:digit:]_]+)*$}
    if { ![regexp -- ${re} ${label}] } {
	error "label name must be an alphanumeric string (possibly separated by /)"
    }

    set training_dir [get_training_dir]
    set axis_dir ${training_dir}/${axis}
    set label_dir ${axis_dir}/+/${label}

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

    error "old - to be implemented again - should have label-for-manual-training and label-for-auto-classification/"

    # implies label-for-manual-training in the old classifier_dir, use training_dir if you choose to go that way

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

    error "old - see comment for label / same holds here, i.e. training vs. classification"

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

proc ::feed_reader::classifier::rename_label {axis old_name_path new_name_path} {

    ::persistence::rename_supercolumn \
	"newsdb" \
	"train_item" \
	"${axis}" \
	"${old_name_path}" \
	"${new_name_path}"

}

proc ::feed_reader::classifier::link_label {target_path link_path} {

    ::persistence::link "newsdb" "train_item" ${target_path} ${link_path}

}


proc ::feed_reader::classifier::list_training_labels {axis {supercolumn_path ""}} {

    foreach label_list [get_training_labels ${axis} ${supercolumn_path}] {
	lassign ${label_list} label lstat_map
	array set lstat $lstat_map
	puts -nonewline ${label}
	if { $lstat(type) eq {link} } {
	    puts " -> $lstat(target)"
	} else {
	    puts ""
	}
    }

}

proc ::feed_reader::classifier::get_training_labels {axis {supercolumn_path ""}} {

    set supercolumns_predicate {}
    set supercolumns_categories \
	[::persistence::get_supercolumns_paths_with_status \
	     "newsdb" \
	     "train_item" \
	     "${axis}" \
	     "${supercolumn_path}" \
	     "${supercolumns_predicate}"]


    return ${supercolumns_categories}

}


# axis = el/topic (for example)
# remaining_levels = 1 => two levels of categories, i.e. topic and sub-topic
proc ::feed_reader::classifier::train {axis {supercolumn_path ""} {remaining_levels "1"}} {

    set supercolumns_predicate {}
    set supercolumns_categories \
	[::persistence::get_supercolumns_names \
	     "newsdb" \
	     "train_item" \
	     "${axis}" \
	     "${supercolumn_path}" \
	     "${supercolumns_predicate}"]

    set supercolumns_examples \
	[::persistence::get_supercolumns_slice_names \
	     "newsdb" \
	     "train_item" \
	     "${axis}" \
	     "${supercolumn_path}" \
	     "${supercolumns_predicate}"]

    set supercolumns_filelist \
	[::persistence::names__directed_join \
	     "${supercolumns_examples}" \
	     "newsdb" \
	     "content_item/by_contentsha1_and_const"]

    ::naivebayes::learn_naive_bayes_text ${supercolumns_filelist} ${supercolumns_categories} model

    set filename \
	[::persistence::__get_column \
	     "newsdb" \
	     "classifier/model" \
	     "${axis}" \
	     "[file join ${supercolumn_path} _data_]"]

    ::naivebayes::save_naive_bayes_model model ${filename}

    if { ${remaining_levels} } {
        foreach path ${supercolumns_categories} {
            train ${axis} ${path} [expr { ${remaining_levels} - 1 }]
        }
    }

}

proc ::feed_reader::classifier::is_enabled_p {axis} {

    # TODO
    return 0

    set oid "newsdb/classifier_model_t.by_name/${axis}"

    set ks "newsdb"
    set cf "classifier_model_t"
    return [::persistence::exists_cf_p $ks $cf]

    set _ {
        "newsdb"
        "classifier/model"
        "${axis}"
        "_data_"
    }

}


proc ::feed_reader::classifier::classify {axis contentVar} {

    # TODO
    return ""

    upvar $contentVar content

    # category classification

    set filename \
        [::persistence::__get_column \
        "newsdb" \
        "classifier/model" \
        "${axis}" \
        "_data_"]

    variable __nb_model_${axis}
    if { ![info exists __nb_model_${axis}] } {
        ::naivebayes::load_naive_bayes_model __nb_model_${axis} ${filename}
    }

    set category [::naivebayes::classify_naive_bayes_text __nb_model_${axis} content]

    # sub-category classification

    set subcategory_filename \
        [::persistence::__get_column \
        "newsdb" \
        "classifier/model" \
        "${axis}" \
        "[file join ${category} _data_]"]

    set subcategory ""
    if { [::persistence::exists_data_p ${subcategory_filename}] } {

        if { ![info exists __nb_model_${axis}_${category}] } {
            ::naivebayes::load_naive_bayes_model __nb_model_${axis}_${category} ${subcategory_filename}
        }

        set subcategory [::naivebayes::classify_naive_bayes_text __nb_model_${axis}_${category} content]
    }

    return [file join ${category} ${subcategory}]


}


namespace eval ::feed_reader::classifier {

}



# * TODO: bin packing for word cloud 
# * TODO: word cloud for each cluster
# * label interactive could show word coud to ease training
#
proc ::feed_reader::classifier::wordcount {{contentsha1_list ""}} {


    set where_clause [list]
    array set options [list]
    if { $contentsha1_list eq {} } {
        set options(limit) 10
    } else {
        lappend where_clause [list contentsha1 in $contentsha1_list]
    }
    set slicelist [::newsdb::content_item_t find $where_clause options]

    array set count [list]
    foreach rev $slicelist {

        array set content_item [::newsdb::content_item_t get $rev]

        set content [concat $content_item(title) $content_item(body)]

        ::naivebayes::wordcount_helper count content 1 ;# filter_stopwords

    }

    ::naivebayes::print_words [::naivebayes::wordcount_topN count]

}

