package provide naivebayes 0.1

::xo::lib::require critcl
::xo::lib::require persistence

####

::critcl::reset

::critcl::clibraries -L/opt/naviserver/lib -lm

::critcl::config I /opt/naviserver/include

::critcl::cinit {
    // init_text

    Tcl_CreateObjCommand(ip, "::naivebayes::classify", naivebayes_ClassifyCmd, NULL, NULL);

} {
    // init_exts
}

critcl::ccode {

    #include "tcl.h"
    #include "math.h"

        #define CheckArgs(min,max,n,msg) \
                     if ((objc < min) || (objc >max)) { \
                         Tcl_WrongNumArgs(interp, n, objv, msg); \
                         return TCL_ERROR; \
                     }

    static int naivebayes_ModuleInitialized;

    int naivebayes_ClassifyCmd(ClientData clientData,Tcl_Interp *interp,int objc,Tcl_Obj * const objv[]) {
	
	CheckArgs(2,3,1,"modelVar wordsVar");
	
	Tcl_Obj *modelObjPtr = objv[1]; // Tcl_ObjGetVar2(interp,objv[1], NULL, TCL_LEAVE_ERR_MSG);
	Tcl_Obj *wordListPtr = Tcl_ObjGetVar2(interp,objv[2], NULL, TCL_LEAVE_ERR_MSG);

	int numWords;
	if (TCL_OK != Tcl_ListObjLength(interp, wordListPtr, &numWords)) {
	    // some error
	    return TCL_ERROR;
	}

	// fprintf(stderr,"%s\n",Tcl_GetString(wordListPtr));


	Tcl_Obj *nameObjPtr;
	nameObjPtr = Tcl_NewStringObj("categories",-1);

	Tcl_Obj *catListPtr = Tcl_ObjGetVar2(interp, modelObjPtr, nameObjPtr, TCL_LEAVE_ERR_MSG);

	if (!catListPtr) {
	    fprintf(stderr, "no categories found\n");
	    return TCL_ERROR;
	}

	int numCategories;
	if (TCL_OK != Tcl_ListObjLength(interp, catListPtr, &numCategories)) {
	    // some error occurred
	    return TCL_ERROR;
	}



	// fprintf(stderr, "numWords=%d categories: %s\n", numWords, Tcl_GetString(catListPtr));

	double max_pr = -9999999999;

	Tcl_Obj *maxCatObjPtr = NULL;

	Tcl_Obj *catObjPtr;
	Tcl_Obj *wordObjPtr;

	int i,j;
	for(i=0;i<numCategories;++i) 
	{

	 Tcl_ListObjIndex(interp,catListPtr,i,&catObjPtr);


	 nameObjPtr = Tcl_NewStringObj("cat_",-1);
	 Tcl_AppendObjToObj(nameObjPtr, catObjPtr);
	 Tcl_AppendObjToObj(nameObjPtr, Tcl_NewStringObj("_default_pr",-1));
	 Tcl_Obj *prCatDefaultObjPtr = Tcl_ObjGetVar2(interp,modelObjPtr,nameObjPtr,TCL_LEAVE_ERR_MSG);

	 double pr_cat_default;
	 Tcl_GetDoubleFromObj(interp,prCatDefaultObjPtr, &pr_cat_default);

	 nameObjPtr = Tcl_NewStringObj("cat_",-1);
	 Tcl_AppendObjToObj(nameObjPtr, catObjPtr);
	 Tcl_Obj *prCatObjPtr = Tcl_ObjGetVar2(interp,modelObjPtr,nameObjPtr,TCL_LEAVE_ERR_MSG);

	 double pr_cat;
	 Tcl_GetDoubleFromObj(interp,prCatDefaultObjPtr, &pr_cat);

	 if (!pr_cat) {continue;}
	 // fprintf(stderr, "category: %s pr_cat=%f pr_cat_default=%f numWords=%d\n", Tcl_GetString(catObjPtr),pr_cat,pr_cat_default,numWords);

	 double p;
	 p = 0.0;
	 for(j=0; j<numWords; ++j) 
	 {

	  Tcl_ListObjIndex(interp,wordListPtr,j,&wordObjPtr);

	  nameObjPtr = Tcl_NewStringObj("word_",-1);
	  Tcl_AppendObjToObj(nameObjPtr, wordObjPtr);
	  Tcl_AppendObjToObj(nameObjPtr, Tcl_NewStringObj(",",-1));
	  Tcl_AppendObjToObj(nameObjPtr, catObjPtr);

	  Tcl_Obj *prWordGivenCatObjPtr = Tcl_ObjGetVar2(interp,modelObjPtr,nameObjPtr,0);

	  double pr_word_given_cat;
	  if (prWordGivenCatObjPtr) {
	      Tcl_GetDoubleFromObj(interp,prWordGivenCatObjPtr, &pr_word_given_cat);
	  } else {
	      pr_word_given_cat = pr_cat_default;
	  }

	  p += log(pr_word_given_cat);
      }
	 p += log(pr_cat);


	 // fprintf(stderr,"category: %s p=%f\n",Tcl_GetString(catObjPtr),p);
	    
	 if (p > max_pr) {
	     max_pr = p;
	     maxCatObjPtr = catObjPtr;
	 }

     }

	if (maxCatObjPtr) {
	    Tcl_SetObjResult(interp,Tcl_DuplicateObj(maxCatObjPtr));
	}
	return TCL_OK;

    }


}

::critcl::cbuild [file normalize [info script]]

# ::critcl::ccodedir naivebayes_c

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
	if { ![info exists vocabulary(${word})] } {
	    continue
	}
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

	if { $num_docs(${category}) != 0 } {

	    set category_pr \
		[expr { $num_docs(${category}) / double(${total_docs})  }]

	    # for words in the vocabulary that are not found
	    # in the category
	    set default_word_pr \
		[expr { 1.0 / double( $num_words(${category}) + ${vocabulary_size} ) }]


	} else {

	    set category_pr 0
	    set default_word_pr 0

	}

	set probability(cat_${category}) ${category_pr}
	set probability(cat_${category}_default_pr) ${default_word_pr}

	foreach {word num_occurrences} [array get wordcount_${category}] {

	    set probability(word_${word},${category})\
		[expr { double( ${num_occurrences} + 1 ) / double( $num_words(${category}) + ${vocabulary_size} ) }]

	}


    }


}

proc ::naivebayes::save_naive_bayes_model {modelVar filename} {

    upvar $modelVar model

    ::persistence::set_data ${filename} [array get model]

}


proc ::naivebayes::load_naive_bayes_model {modelVar filename} {

    upvar $modelVar model

    array set model [::persistence::get_data ${filename}]

}




proc ::naivebayes::clean_and_tokenize {contentVar {filter_stopwords_p 0}} { 

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

proc ::naivebayes::wordcount_helper {countVar contentVar {filter_stopwords_p 0}} {

    upvar $countVar count
    upvar $contentVar content

    set tokens [clean_and_tokenize content ${filter_stopwords_p}]

    foreach token ${tokens} {
	incr count(${token})
    }

}

proc ::naivebayes::wordcount_topN {countVar {limit "50"}} {

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

proc ::naivebayes::print_words {words} {

    foreach token ${words} {
	puts -nonewline " ${token} "
	if { [incr x] % 10 == 0 } {
	    puts ""
	}
    }
    puts ""


}

proc ::naivebayes::classify_naive_bayes_text {modelVar contentVar} {

    upvar $modelVar pr
    upvar $contentVar content

    # we wordcount_helper as it strips out embedded content (images,video)

    # wordcount_helper wordcount_text content
    # set words [array names wordcount_text]
    set words [clean_and_tokenize content]

    return [::naivebayes::classify pr words]

    # ---- 


    set categories $pr(categories)

    set max_pr -9999999999 ;# 0
    set max_category ""
    foreach category ${categories} {
       #set p 1.0
       set p 0.0
       foreach word ${words} {
           set pr_word_given_cat [get_value_if pr(word_${word},${category}) "$pr(cat_${category}_default_pr)"]

           #set p [expr { ${p} * $pr_word_given_cat }]
           set p [expr { ${p} + log(${pr_word_given_cat}) }]
       }
       #set p [expr { $pr(cat_${category}) * ${p} }]
       set p [expr { log($pr(cat_${category})) + ${p} }]

       if { ${p} > ${max_pr} } {
           set max_pr ${p}
           set max_category ${category}
       }

       #puts "$category p=$p"
    }

    #puts max_pr=$max_pr
    #puts max_category=$max_category
    #puts ---

    return ${max_category}

}

proc ::naivebayes::filter_stopwords {resultVar tokensVar} {

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
