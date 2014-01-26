#include "tcl.h"
#include "math.h"

#include "common.h"
#include "persistence.h"
#include "heapq.h"

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
  Tcl_InitHashTable(&c->word_pr,TCL_STRING_KEYS);
  return TCL_OK;
}  

int clean_and_tokenize(Tcl_Interp *interp, Tcl_Obj *content, Tcl_Obj *resObjPtr, int *num_tokens) {
    // content is a list of two elements, the title and the content
    // join them together

    int i,j,listLen,subListLen;
    Tcl_Obj **elemPtrs;

    if (Tcl_ListObjGetElements(interp, content, &listLen, &elemPtrs) != TCL_OK) {
        // TODO: cleanup
        return TCL_ERROR;
    }

    int count=0;
    Tcl_Obj *objPtr;
    for (i = 0;  i < listLen;  i++) {
        Tcl_ListObjLength(interp, elemPtrs[i], &subListLen);
        for (j = 0; j < subListLen; j++) {
            Tcl_ListObjIndex(interp, elemPtrs[i], j, &objPtr);

            // TODO: investigate why this is needed
            if (!objPtr) continue;

            Tcl_ListObjAppendElement(interp, resObjPtr, objPtr);
            count++;
        }
    }

    *num_tokens = count;

    return TCL_OK;
}
int wordcount_helper(Tcl_Interp *interp, category_t *c, Tcl_Obj *content) {

  Tcl_Obj *tokens = Tcl_NewListObj(0,NULL);
  clean_and_tokenize(interp, content, tokens, &c->num_words);

// printf("num_words=%d\n",c->num_words);

  Tcl_Obj *word_objPtr;
  Tcl_HashEntry *entryPtr;

  int i;
  for (i=0; i < c->num_words; ++i) {

    Tcl_ListObjIndex(interp, tokens, i, &word_objPtr);
// printf("ListObjIndex\n");

    const char *word_key = Tcl_GetString(word_objPtr);

// printf("word_key=%s i=%d / num_words=%d\n", word_key, i, c->num_words);

    int value;
    int new;
    entryPtr = Tcl_CreateHashEntry(&(c->wordcount), word_key, &new);

    if (new) {

      // new word
      value = 1;
// printf("new word, value=%d\n",value);

    } else {

      // existing word
      value = *((int *) Tcl_GetHashValue(entryPtr));
      value++;
//printf("existing word, value=%d\n",value);

    }

    Tcl_SetHashValue(entryPtr, &value);
// printf("SetHashValue\n");
  }

}

int compare_wordcount_hashentry(const void *d1, const void *d2)
{
  int v1 = *((int *) Tcl_GetHashValue((Tcl_HashEntry *) d1));
  int v2 = *((int *) Tcl_GetHashValue((Tcl_HashEntry *) d2));

  return (v1>v2) ? -1 : ((v1<v2) ? 1 : 0);
}

void mark_frequent_words(Tcl_Interp *interp, Tcl_Obj *remove_words_listPtr, Tcl_HashTable *vocabulary_tablePtr, int top_n) {

  heapq_t q;
  heapq_init(&q,compare_wordcount_hashentry);


  Tcl_HashSearch searchPtr;
  Tcl_HashEntry *entryPtr = Tcl_FirstHashEntry(vocabulary_tablePtr, &searchPtr);
  while(entryPtr) {

    heapq_insert(&q,entryPtr);

    if (heapq_size(&q) > top_n) {
      // remove lowest priority item
      heapq_pop_back(&q);
    }

    entryPtr = Tcl_NextHashEntry(&searchPtr);

  }

  while(!heapq_empty(&q) && top_n) {

    entryPtr = heapq_top(&q);

    const char *word_key = 
      Tcl_GetHashKey(vocabulary_tablePtr, entryPtr);
    
    // int num_occurrences = *((int *) Tcl_GetHashValue(entryPtr));
    Tcl_ListObjAppendElement(interp, remove_words_listPtr, Tcl_NewStringObj(word_key,-1));

    heapq_pop(&q);
    top_n--;
  }

}

void mark_rare_words(Tcl_Interp *interp, Tcl_Obj *remove_words_listPtr, Tcl_HashTable *vocabulary_tablePtr, int threshold) {

  Tcl_HashSearch searchPtr;
  Tcl_HashEntry *entryPtr = Tcl_FirstHashEntry(vocabulary_tablePtr, &searchPtr);
  while(entryPtr) {

    const char *word_key = 
      Tcl_GetHashKey(vocabulary_tablePtr, entryPtr);
   
   // printf("word_key=%s\n",word_key);

    int num_occurrences = *((int *) Tcl_GetHashValue(entryPtr));
    if (num_occurrences < threshold) {
      Tcl_ListObjAppendElement(interp, remove_words_listPtr, Tcl_NewStringObj(word_key,-1));
    }

    entryPtr = Tcl_NextHashEntry(&searchPtr);

  }

}

void remove_marked_words(Tcl_Interp *interp, Tcl_Obj *remove_words_listPtr, Tcl_HashTable *vocabulary_tablePtr, category_t *categories, int num_categories) {

  int i,j,len;

  Tcl_ListObjLength(interp, remove_words_listPtr, &len);

  Tcl_Obj *word_objPtr;
  Tcl_HashEntry *vocabulary_word_entryPtr;
  Tcl_HashEntry *category_word_entryPtr; 
  const char *word_key;
  category_t *c;

  for (i=0; i<len; i++) {

    Tcl_ListObjIndex(interp, remove_words_listPtr, i, &word_objPtr);

    word_key = Tcl_GetString(word_objPtr);

 // printf("word_key=%s\n",word_key);

    // remove word from vocabulary
    vocabulary_word_entryPtr = Tcl_FindHashEntry(vocabulary_tablePtr, word_key);

    if (vocabulary_word_entryPtr) {
      Tcl_DeleteHashEntry(vocabulary_word_entryPtr);
    }
// printf("remove word from all categories\n");

    // remove word from all categories
    for (j=0; j<num_categories; j++) {
      c = &categories[j];

// printf("word_key=%s j=%d, c=%p &c->wordcount=%p\n",word_key,j,c,&c->wordcount);

      category_word_entryPtr = Tcl_FindHashEntry(&c->wordcount, word_key);

// printf("category_word_entryPtr=%p\n\n",category_word_entryPtr);

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

//  printf("vocabulary word_key=%s\n",word_key);

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

int set_model_info(Tcl_Interp *interp, Tcl_Obj *outvarname, category_t *categories, int num_docs, int num_categories) {
    // category
    // category.name
    // category.category_pr
    // category.default_word_pr
    // category.word_pr_map
    //
    Tcl_Obj *modelPtr = Tcl_NewDictObj();

    Tcl_DictObjPut(interp, modelPtr, Tcl_NewStringObj("num_docs",-1), Tcl_NewIntObj(num_docs));
    Tcl_DictObjPut(interp, modelPtr, Tcl_NewStringObj("num_categories",-1), Tcl_NewIntObj(num_docs));


    int i;
    Tcl_Obj *listPtr, *wordlistPtr, *categoriesListPtr;

    categoriesListPtr = Tcl_NewListObj(0,NULL);
    for (i = 0; i < num_categories; i++) {
        category_t *c = &categories[i];

        listPtr = Tcl_NewListObj(0,NULL);

        Tcl_ListObjAppendElement(interp, listPtr, Tcl_NewStringObj("name",-1));
        Tcl_ListObjAppendElement(interp, listPtr, c->name);
        Tcl_ListObjAppendElement(interp, listPtr, Tcl_NewStringObj("num_docs",-1));
        Tcl_ListObjAppendElement(interp, listPtr, Tcl_NewIntObj(c->num_docs));
        Tcl_ListObjAppendElement(interp, listPtr, Tcl_NewStringObj("num_words",-1));
        Tcl_ListObjAppendElement(interp, listPtr, Tcl_NewIntObj(c->num_words));
        Tcl_ListObjAppendElement(interp, listPtr, Tcl_NewStringObj("category_pr",-1));
        Tcl_ListObjAppendElement(interp, listPtr, Tcl_NewDoubleObj(c->pr));
        Tcl_ListObjAppendElement(interp, listPtr, Tcl_NewStringObj("default_word_pr",-1));
        Tcl_ListObjAppendElement(interp, listPtr, Tcl_NewDoubleObj(c->default_word_pr));

        // word_pr_map
        wordlistPtr = Tcl_NewListObj(0,NULL);

        Tcl_HashSearch searchPtr;
        Tcl_HashEntry *entryPtr = Tcl_FirstHashEntry(&c->word_pr, &searchPtr);
        while(entryPtr) {

          const char *word_key = Tcl_GetHashKey(&c->word_pr, entryPtr);
          double word_pr = *((double *) Tcl_GetHashValue(entryPtr));

          Tcl_ListObjAppendElement(interp, wordlistPtr, Tcl_NewStringObj(word_key,-1));
          Tcl_ListObjAppendElement(interp, wordlistPtr, Tcl_NewDoubleObj(word_pr));

          entryPtr = Tcl_NextHashEntry(&searchPtr);

        }

        Tcl_ListObjAppendElement(interp, listPtr, Tcl_NewStringObj("word_pr_map",-1));
        Tcl_ListObjAppendElement(interp, listPtr, wordlistPtr);

        Tcl_ListObjAppendElement(interp, categoriesListPtr, c->name);
        Tcl_ListObjAppendElement(interp, categoriesListPtr, listPtr);

    }

    Tcl_DictObjPut(interp, modelPtr, Tcl_NewStringObj("categories",-1), categoriesListPtr);

    Tcl_ObjSetVar2(interp, outvarname, NULL, modelPtr, TCL_LEAVE_ERR_MSG); 
    
}



int compute_word_probabilities(category_t *c, int vocabulary_size) {

    Tcl_HashSearch searchPtr;
    Tcl_HashEntry *entryPtr = Tcl_FirstHashEntry(&c->wordcount,&searchPtr);
    while(entryPtr) {
      
      const char *word_key = Tcl_GetHashKey(&c->wordcount, entryPtr);

      int num_occurrences = *((int *) Tcl_GetHashValue(entryPtr));

      double value = (1.0 + (double) num_occurrences) / ((double) c->num_words + vocabulary_size);

// printf("word_key=%s\n",word_key);

      int new;
      Tcl_HashEntry *newEntryPtr = Tcl_CreateHashEntry(&c->word_pr, word_key, &new);

      // it must be a new entry
      Tcl_SetHashValue(newEntryPtr,&value);

      entryPtr = Tcl_NextHashEntry(&searchPtr);

    }

    return TCL_OK;

}



int naivebayes_LearnCmd(ClientData clientData,Tcl_Interp *interp,int objc,Tcl_Obj * const objv[]) {
  CheckArgs(3,4,1,"examplesVar categoriesVar modelVar");

  // examples = multirow of slices
  // categories = list
  Tcl_Obj *examples = Tcl_ObjGetVar2(interp, objv[1], NULL, TCL_LEAVE_ERR_MSG);
  Tcl_Obj *category_names = Tcl_ObjGetVar2(interp, objv[2], NULL, TCL_LEAVE_ERR_MSG);
  Tcl_Obj *outvarname = objv[3]; // Tcl_ObjGetVar2(interp, objv[3], NULL, TCL_LEAVE_ERR_MSG);


  int num_categories;
  Tcl_ListObjLength(interp, category_names, &num_categories);

  category_t *categories = (category_t *) Tcl_Alloc(num_categories * sizeof(category_t));

  Tcl_HashTable vocabulary;
  Tcl_InitHashTable(&vocabulary, TCL_STRING_KEYS);

  // initialize vocabulary_size
  int vocabulary_size = 0;


  int i, j, total_docs;
  for (i=0; i < num_categories; ++i) {

    // initialize category structure
    initialize_category(&categories[i]);

    // get the category name and set it in the structure
    Tcl_ListObjIndex(interp, category_names, i, &categories[i].name);

// printf("HERE: category=%s\n", Tcl_GetString(categories[i].name));

    // get the ith slice
    Tcl_Obj *slice;
    Tcl_ListObjIndex(interp, examples, i, &slice);

    int slicelen;
    Tcl_ListObjLength(interp, slice, &slicelen);

    Tcl_Obj *content = Tcl_NewObj();
    for (j=1; j< slicelen; ++j) {
      Tcl_Obj *infile;
      Tcl_ListObjIndex(interp, slice, j, &infile);

      // Tcl_IncrRefCount(content);

      // printf("infile=%s i=%d slicelen=%d\n", Tcl_GetString(infile), i, slicelen);
      // read the data from the given file
      persistence_GetData(interp, infile, content);
 
      // count words in content and update wordcount for category i
      wordcount_helper(interp, &categories[i], content);

      // update the vocabulary hash table
      update_vocabulary_count(&vocabulary, &categories[i], &vocabulary_size);

      categories[i].num_docs = slicelen;

      Tcl_SetObjLength(content,0);

    }

    total_docs += slicelen;

  }

printf("mark top 300 words for removal\n");

  // mark top 300 words for removal
  Tcl_Obj *remove_words_listPtr = Tcl_NewObj();
  mark_frequent_words(interp, remove_words_listPtr, &vocabulary, 300);

printf("mark words with less than 20 occurrences for removal\n");

  // mark words with less than 20 occurrences for removal
  mark_rare_words(interp, remove_words_listPtr, &vocabulary, 20);

printf("actually remove marked words\n");

  // actually remove marked words
  remove_marked_words(interp, remove_words_listPtr, &vocabulary, categories, num_categories);


  /*
    # TODO: use zipf's law to compute how many 
    # frequent and rare words to remove
   */

printf("compute category probabilities\n");

  for (i=0; i < num_categories; ++i) {
    compute_category_probabilities(&categories[i], total_docs, vocabulary_size);
  }

printf("set model info\n");
    set_model_info(interp, outvarname, categories, total_docs, num_categories);

  Tcl_Free((char *) categories);

  return TCL_OK;
}

int naivebayes_ClassifyCmd(ClientData clientData,Tcl_Interp *interp,int objc,Tcl_Obj * const objv[]) {
	
  CheckArgs(2,3,1,"modelVar wordsVar");
	
  Tcl_Obj *modelPtr = Tcl_ObjGetVar2(interp, objv[1], NULL, TCL_LEAVE_ERR_MSG);
  Tcl_Obj *wordListPtr = Tcl_ObjGetVar2(interp,objv[2], NULL, TCL_LEAVE_ERR_MSG);

  int numWords;
  if (TCL_OK != Tcl_ListObjLength(interp, wordListPtr, &numWords)) {
    // some error
    return TCL_ERROR;
  }

  // fprintf(stderr,"%s\n",Tcl_GetString(wordListPtr));


  double max_pr = -9999999999;

  Tcl_Obj *maxCatObjPtr = NULL;
  Tcl_Obj *catObjPtr;
  Tcl_Obj *wordObjPtr;
  Tcl_Obj *categoriesDictPtr, *catDictPtr;
  Tcl_DictObjGet(interp, modelPtr, Tcl_NewStringObj("categories",-1), &categoriesDictPtr);

  int size=0;
  Tcl_DictObjSize(interp, categoriesDictPtr, &size);
// printf("modelPtr=%p categoriesDictPtr=%p size=%d\n",modelPtr, categoriesDictPtr, size);
  if (!size) {
    return TCL_OK;
  }

  int i,j;
  Tcl_Obj *prCatDefaultObjPtr;
  double pr_cat_default;
  Tcl_Obj *prCatObjPtr;
  double pr_cat;

    Tcl_DictSearch search;
    Tcl_Obj *key, *value;
    int done;

    /*
     * Assume interp and objPtr are parameters.  This is the
     * idiomatic way to start an iteration over the dictionary; it
     * sets a lock on the internal representation that ensures that
     * there are no concurrent modification issues when normal
     * reference count management is also used.  The lock is
     * released automatically when the loop is finished, but must
     * be released manually when an exceptional exit from the loop
     * is performed. However it is safe to try to release the lock
     * even if we've finished iterating over the loop.
     */
    if (Tcl_DictObjFirst(interp, categoriesDictPtr, &search,
            &key, &value, &done) != TCL_OK) {
        return TCL_ERROR;
    }
    for (; !done ; Tcl_DictObjNext(&search, &key, &value, &done)) {

        catObjPtr = key;
        catDictPtr = value;

        // Tcl_DictObjGet(interp, categoriesDictPtr, catObjPtr, &catDictPtr);

 // printf("Here %s\n", Tcl_GetString(catObjPtr));

        Tcl_DictObjGet(interp, catDictPtr, Tcl_NewStringObj("default_word_pr",-1), &prCatDefaultObjPtr);
        Tcl_GetDoubleFromObj(interp,prCatDefaultObjPtr, &pr_cat_default);

        Tcl_DictObjGet(interp, catDictPtr, Tcl_NewStringObj("category_pr",-1), &prCatObjPtr);
        Tcl_GetDoubleFromObj(interp,prCatObjPtr, &pr_cat);

        if (!pr_cat) {continue;}
        // fprintf(stderr, "category: %s pr_cat=%f pr_cat_default=%f numWords=%d\n", Tcl_GetString(catObjPtr),pr_cat,pr_cat_default,numWords);

        Tcl_Obj *word_pr_mapPtr;
        Tcl_DictObjGet(interp, catDictPtr, Tcl_NewStringObj("word_pr_map",-1), &word_pr_mapPtr);

        double p;
        p = 0.0;
        Tcl_Obj *prWordGivenCatObjPtr;
        for(j=0; j<numWords; ++j) {

          Tcl_ListObjIndex(interp,wordListPtr,j,&wordObjPtr);
          Tcl_DictObjGet(interp, word_pr_mapPtr, wordObjPtr, &prWordGivenCatObjPtr);


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

    Tcl_DictObjDone(&search);

  if (maxCatObjPtr) {
      // printf("maxCatObjPtr=%s\n", Tcl_GetString(maxCatObjPtr));
      Tcl_SetObjResult(interp,Tcl_DuplicateObj(maxCatObjPtr));
      // Tcl_SetResult(interp, Tcl_GetString(maxCatObjPtr));
  }

    // printf("done\n");

  return TCL_OK;

}

