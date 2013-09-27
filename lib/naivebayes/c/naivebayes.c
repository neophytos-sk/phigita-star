#include "tcl.h"
#include "math.h"

#include "common.h"
#include "persistence.h"
#include "heapq.c"

typedef struct {
  Tcl_Obj *name;
  int num_docs;
  int num_words;
  double pr;
  double default_word_pr;
  Tcl_HashTable wordcount;
  Tcl_HashTable word_pr;
} category_t;


static int naivebayes_ModuleInitialized;



int wordcount_helper(Tcl_Interp *interp, category_t *c, Tcl_Obj *content);
int compute_category_probabilities(category_t *c, int total_docs, int vocabulary_size);
int compute_word_probabilities(category_t *c, int vocabulary_size);


int initialize_category(category_t *c) {
  c->name = NULL;
  c->num_docs = 0;
  c->num_words = 0;
  c->pr = 0;
  c->default_word_pr = 0;
  Tcl_InitHashTable(&c->wordcount,TCL_STRING_KEYS);
  return TCL_OK;
}  

int wordcount_helper(Tcl_Interp *interp, category_t *c, Tcl_Obj *content) {

  // TODO: set tokens [clean_and_tokenize content]
  Tcl_Obj *tokens = content;
  Tcl_ListObjLength(interp,tokens,&c->num_words);

  int i;
  for (i=1; i < c->num_words; ++i) {

    Tcl_Obj *word_objPtr;
    Tcl_ListObjIndex(interp, tokens, i, &word_objPtr);

    const char *word_key = Tcl_GetString(word_objPtr);

    int value;
    int new;
    Tcl_HashEntry *entryPtr = 
      Tcl_CreateHashEntry(&(c->wordcount), word_key, &new);

    if (new) {

      // new word
      value = 1;

    } else {

      // existing word
      value = *((int *) Tcl_GetHashValue(entryPtr));
      value++;

    }

    Tcl_SetHashValue(entryPtr, &value);

  }

}

int compare_wordcount_hashentry(const void *d1, const void *d2)
{
  int v1 = *((int *) Tcl_GetHashValue((Tcl_HashEntry *) d1));
  int v2 = *((int *) Tcl_GetHashValue((Tcl_HashEntry *) d2));

  return (v1>v2) ? -1 : ((v1<v2) ? 1 : 0);
}

void mark_frequent_words(Tcl_Interp *interp, Tcl_Obj *remove_words_listPtr, Tcl_HashTable *vocabulary_tablePtr, int top_n) {

  heapq_t *q = heapq_new(100,compare_wordcount_hashentry);


  Tcl_HashSearch searchPtr;
  Tcl_HashEntry *entryPtr = Tcl_FirstHashEntry(vocabulary_tablePtr, &searchPtr);
  while(entryPtr) {

    heapq_insert(q,entryPtr);

    if (heapq_size(q) > top_n) {
      // remove lowest priority item
      heapq_pop_back(q);
    }

    entryPtr = Tcl_NextHashEntry(&searchPtr);

  }

  while(!heapq_empty(q) && top_n) {

    entryPtr = heapq_top(q);

    const char *word_key = 
      Tcl_GetHashKey(vocabulary_tablePtr, entryPtr);
    
    // int num_occurrences = *((int *) Tcl_GetHashValue(entryPtr));
    Tcl_ListObjAppendElement(interp, remove_words_listPtr, Tcl_NewStringObj(word_key,-1));

    heapq_pop(q);
    top_n--;
  }

}

void mark_rare_words(Tcl_Interp *interp, Tcl_Obj *remove_words_listPtr, Tcl_HashTable *vocabulary_tablePtr, int threshold) {

  Tcl_HashSearch searchPtr;
  Tcl_HashEntry *entryPtr = Tcl_FirstHashEntry(vocabulary_tablePtr, &searchPtr);
  while(entryPtr) {

    const char *word_key = 
      Tcl_GetHashKey(vocabulary_tablePtr, entryPtr);
    
    int num_occurrences = *((int *) Tcl_GetHashValue(entryPtr));
    if (num_occurrences < threshold) {
      Tcl_ListObjAppendElement(interp, remove_words_listPtr, Tcl_NewStringObj(word_key,-1));
    }

    entryPtr = Tcl_NextHashEntry(&searchPtr);

  }

}

void remove_marked_words(Tcl_Interp *interp, Tcl_Obj *remove_words_listPtr, Tcl_HashTable *vocabulary_tablePtr, category_t *categories, int num_categories) {

  int i,len;

  Tcl_ListObjLength(interp, remove_words_listPtr, &len);

  Tcl_Obj *word_objPtr;
  for (i=0; i<len; i++) {

    Tcl_ListObjIndex(interp, remove_words_listPtr, i, &word_objPtr);

    const char *word_key = Tcl_GetString(word_objPtr);

    // remove word from vocabulary
    Tcl_HashEntry *vocabulary_word_entryPtr = 
      Tcl_FindHashEntry(vocabulary_tablePtr, word_key);

    if (vocabulary_word_entryPtr) {
      Tcl_DeleteHashEntry(vocabulary_word_entryPtr);
    }


    // remove word from all categories
    int j;
    for (j=0; j<num_categories; j++) {
      category_t *c = &categories[j];

      Tcl_HashEntry *category_word_entryPtr = 
	Tcl_FindHashEntry(&c->wordcount, word_key);

      if (category_word_entryPtr) {
	Tcl_DeleteHashEntry(category_word_entryPtr);
      }
      
    }
    
    
  }

}

int update_vocabulary_count(Tcl_HashTable *vocabulary_tablePtr, category_t *c, int *vocabulary_sizePtr) {

  Tcl_HashSearch searchPtr;
  Tcl_HashEntry *entryPtr = Tcl_FirstHashEntry(&c->wordcount, &searchPtr);
  while(entryPtr) {
    const char *word_key = 
      Tcl_GetHashKey(&c->wordcount, entryPtr);

    int value;
    int new;
    Tcl_HashEntry *vocabulary_word_entryPtr = 
      Tcl_CreateHashEntry(vocabulary_tablePtr, word_key, &new);

    if (new) {

      // new word
      value = 0;
      (*vocabulary_sizePtr)++;

    } else {

      // existing word
      value = *((int *) Tcl_GetHashValue(vocabulary_word_entryPtr));
      value++;

    }

    Tcl_SetHashValue(vocabulary_word_entryPtr, &value);

    entryPtr = Tcl_NextHashEntry(&searchPtr);
  }

  return TCL_OK;

}

int compute_category_probabilities(category_t *c, int total_docs, int vocabulary_size) {

  if ( c->num_docs != 0 ) {

    c->pr = ((double) c->num_docs) / total_docs;

    // for words in the vocabulary that are not found
    // in the category
    c->default_word_pr = 1.0 / (c->num_words + vocabulary_size );

  }

  // compute word probabilities given this category
  return compute_word_probabilities(c, vocabulary_size);
  
}


int compute_word_probabilities(category_t *c, int vocabulary_size) {

    Tcl_HashSearch searchPtr;
    Tcl_HashEntry *entryPtr = Tcl_FirstHashEntry(&c->wordcount,&searchPtr);
    while(entryPtr) {
      
      const char *word_key = Tcl_GetHashKey(&c->wordcount, entryPtr);

      int num_occurrences = *((int *) Tcl_GetHashValue(entryPtr));

      double value = (1.0 + (double) num_occurrences) / ((double) c->num_words + vocabulary_size);

      int new;
      Tcl_HashEntry *newEntryPtr = Tcl_CreateHashEntry(&c->word_pr, word_key, &new);

      // it must be a new entry
      Tcl_SetHashValue(newEntryPtr,&value);

      entryPtr = Tcl_NextHashEntry(&searchPtr);

    }

    return TCL_OK;

}



int naivebayes_LearnCmd(ClientData clientData,Tcl_Interp *interp,int objc,Tcl_Obj * const objv[]) {
  CheckArgs(2,3,1,"examplesVar categoriesVar");

  // examples = multirow of slices
  // categories = list
  Tcl_Obj *examples = Tcl_ObjGetVar2(interp, objv[1], NULL, TCL_LEAVE_ERR_MSG);
  Tcl_Obj *category_names = Tcl_ObjGetVar2(interp, objv[2], NULL, TCL_LEAVE_ERR_MSG);

  int num_categories;
  Tcl_ListObjLength(interp, category_names, &num_categories);

  category_t *categories = (category_t *) Tcl_Alloc(num_categories * sizeof(category_t));

  Tcl_HashTable vocabulary;
  Tcl_InitHashTable(&vocabulary, TCL_STRING_KEYS);

  // initialize vocabulary_size
  int vocabulary_size = 0;


  int i, j, total_docs;
  for (i=1; i < num_categories; ++i) {

    // initialize category structure
    initialize_category(&categories[i]);

    // get the category name and set it in the structure
    Tcl_ListObjIndex(interp, category_names, i, &categories[i].name);

    // get the ith slice
    Tcl_Obj *slice;
    Tcl_ListObjIndex(interp, examples, i, &slice);

    int slicelen;
    Tcl_ListObjLength(interp, slice, &slicelen);

    for (j=1; j< slicelen; ++j) {
      Tcl_Obj *filename;
      Tcl_ListObjIndex(interp, slice, j, &filename);

      Tcl_Obj *content = Tcl_NewObj();
      Tcl_IncrRefCount(content);

      // read the data from the given file
      persistence_GetData(interp, filename, content);

      // count words in content and update wordcount for category i
      wordcount_helper(interp, &categories[i],content);

      // update the vocabulary hash table
      update_vocabulary_count(&vocabulary, &categories[i], &vocabulary_size);

      categories[i].num_docs = slicelen;

    }

    total_docs += slicelen;

  }


  // mark top 300 words for removal
  Tcl_Obj *remove_words_listPtr = Tcl_NewObj();
  mark_frequent_words(interp, remove_words_listPtr, &vocabulary, 300);

  // mark words with less than 20 occurrences for removal
  mark_rare_words(interp, remove_words_listPtr, &vocabulary, 20);

  // actually remove marked words
  remove_marked_words(interp, remove_words_listPtr, &vocabulary, categories, num_categories);


  /*
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

  */


  for (i=0; i < num_categories; ++i) {
    compute_category_probabilities(&categories[i], total_docs, vocabulary_size);
  }

  Tcl_Free((char *) categories);

}

int naivebayes_ClassifyCmd(ClientData clientData,Tcl_Interp *interp,int objc,Tcl_Obj * const objv[]) {
	
  CheckArgs(2,3,1,"modelVar wordsVar");
	
  Tcl_Obj *modelObjPtr = objv[1];
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
  for(i=0;i<numCategories;++i) {

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
    for(j=0; j<numWords; ++j) {

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

