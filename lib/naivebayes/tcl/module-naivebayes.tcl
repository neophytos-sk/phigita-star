package provide naivebayes 0.1


namespace eval ::naivebayes {;}

proc ::naivebayes::learn_naive_bayes_text {multirow_examples multirow_categories {modelVar ""}} {

    if { $modelVar ne {} } {
	upvar $modelVar probability
    }

    set probability(categories) ${multirow_categories}

    array set vocabulary [list]
    foreach slicelist ${multirow_examples} category ${multirow_categories} {

	puts "--->>> wordcount category = ${category}"

	array set count_${category} [list]

	foreach filename ${slicelist} {

	    if { ![::persistence::exists_data_p ${filename}] } {
		continue
	    }

	    set content [join [::persistence::get_data ${filename}]]

	    wordcount_helper wordcount_${category} content

	    foreach word [array names wordcount_${category}] {
		incr vocabulary(${word})
	    }

	}

	set slicelen [llength ${slicelist}]
	set num_docs(${category}) $slicelen
	set num_words(${category}) [array size wordcount_${category}]

	incr total_docs ${slicelen}

    }

    # TODO: use zipf's law to compute how many 
    # frequent and rare words to remove

    #
    # mark top 300 words for removal
    #
    set remove_frequent_words [wordcount_topN vocabulary 300]
    puts "frequent words (to be removed):"
    print_words $remove_frequent_words

    #
    # mark words with less than 20 occurrences for removal
    #
    set remove_rare_words [list]
    foreach word [array names vocabulary] {
	if { $vocabulary(${word}) <= 20 } {
	    lappend remove_rare_words ${word}
	}
    }
    puts "rare words (to be removed):"
    print_words ${remove_rare_words}

    #
    # actually remove marked words
    #

    set remove_words [concat ${remove_frequent_words} ${remove_rare_words}]
    foreach word ${remove_words} {
	unset vocabulary(${word})
	incr vocabulary_size -1
	foreach category ${multirow_categories} {
	    if { [info exists wordcount_${category}(${word})] } {
		unset wordcount_${category}(${word})
		incr num_words(${category}) -1
	    }
	}
    }


    set vocabulary_size [array size vocabulary]
    puts ""
    puts "--->>> model vocabulary"
    puts total_words_in_vocabulary=$vocabulary_size
    print_words [wordcount_topN vocabulary 40]

    foreach category ${multirow_categories} {
	puts "--->>> model category = ${category}"
	puts "num_words(${category})=$num_words(${category})"
	puts "num_docs(${category})=$num_docs(${category})"
	print_words [wordcount_topN wordcount_${category} 40]
    }


    foreach category ${multirow_categories} {

	set probability(cat_${category}) \
	    [expr { $num_docs(${category}) / double(${total_docs})  }]


	foreach {word num_occurrences} [array get wordcount_${category}] {

	    set probability(word_${word},${category})\
		[expr { double( ${num_occurrences} + 1 ) / double( $num_words(${category}) + ${vocabulary_size} ) }]

	}

    }


}

proc ::naivebayes::save_naive_bayes_model {modelVar filename} {

    upvar $modelVar model

    ::persistence::set_data ${filename} [array get model]

    if {0} {
	::persistence::insert_column \
	    "newsdb" \
	    "classifier/model" \
	    "${axis}" \
	    "_data_" \
	    [array get model]
    }

}


proc ::naivebayes::load_naive_bayes_model {modelVar ${filename}} {

    upvar $modelVar model

    array set model [::persistence::get_data ${filename}]

    if {0} {
	::persistence::get_column \
	    "newsdb" \
	    "classifier/model" \
	    "${axis}" \
	    "_data_" \
	    "column_data"

	array set model ${column_data}
    }

}

