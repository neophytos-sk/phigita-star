#include "tcl.h"
#include "math.h"

#include "common.h"

static int naivebayes_ModuleInitialized;

int persistence_GetData(Tcl_Interp *interp, Tcl_Obj *pathPtr, Tcl_Obj *content) {

  Tcl_Channel channel = Tcl_FSOpenFileChannel(interp,pathPtr,"r",0644);
  if (!channel) {
    return TCL_ERROR;
  }

  Tcl_ReadChars(channel,content,-1,0);

  Tcl_Close(interp,channel);

  return TCL_OK;
}


int wordcount_helper(Tcl_Interp *interp, Tcl_HashTable *wordcount_tablePtr, Tcl_Obj *content) {

  // TODO: set tokens [clean_and_tokenize content]
  Tcl_Obj *tokens = content;
  int numTokens;
  Tcl_ListObjLength(interp,tokens,&numTokens);

  int i;
  for (i=1; i<numTokens; ++i) {

    Tcl_Obj *word_objPtr;
    Tcl_ListObjIndex(interp, tokens, i, &word_objPtr);

    const char *word_key = Tcl_GetString(word_objPtr);
    Tcl_HashEntry *word_entryPtr = Tcl_FindHashEntry(wordcount_tablePtr, word_key);
    int value;
    if (word_entryPtr) {
      // ClientData value
      value = (int) Tcl_GetHashValue(word_entryPtr);
    } else {
      value = 0;
    }
    Tcl_SetHashValue(word_entryPtr, value+1);

  }

}



int naivebayes_LearnCmd(ClientData clientData,Tcl_Interp *interp,int objc,Tcl_Obj * const objv[]) {
  CheckArgs(2,3,1,"examplesVar categoriesVar");

  // examples = multirow of slices
  // categories = list
  Tcl_Obj *examples = Tcl_ObjGetVar2(interp, objv[1], NULL, TCL_LEAVE_ERR_MSG);
  Tcl_Obj *categories = Tcl_ObjGetVar2(interp, objv[2], NULL, TCL_LEAVE_ERR_MSG);

  int num_categories;
  Tcl_ListObjLength(interp, categories, &num_categories);

  // number of docs and words in each category
  int *num_docs = (int *) Tcl_Alloc(num_categories * sizeof(int));
  int *num_words = (int *) Tcl_Alloc(num_categories * sizeof(int));


  Tcl_HashTable **wordcount_tablePtr = (Tcl_HashTable **) Tcl_Alloc(num_categories * sizeof(Tcl_HashTable));
  Tcl_HashTable vocabulary;
  Tcl_InitHashTable(&vocabulary, TCL_STRING_KEYS);

  int i, j, total_docs;
  for (i=1; i<num_categories; ++i) {
    Tcl_Obj *slice;
    Tcl_Obj *category;
    Tcl_ListObjIndex(interp, examples, i, &slice);
    Tcl_ListObjIndex(interp, categories, i, &category);

    Tcl_InitHashTable(wordcount_tablePtr[i],TCL_STRING_KEYS);

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
      wordcount_helper(interp, wordcount_tablePtr[i],content);

      // update the vocabulary hash table
      num_words[i] = 0;
      Tcl_HashSearch *searchPtr;
      Tcl_HashEntry *category_word_entryPtr = Tcl_FirstHashEntry(wordcount_tablePtr[i], searchPtr);
      while(category_word_entryPtr) {
	const char *word_key = Tcl_GetHashKey(wordcount_tablePtr[i], category_word_entryPtr);

	Tcl_HashEntry *vocabulary_word_entryPtr = Tcl_FindHashEntry(&vocabulary, word_key);
	ClientData value = Tcl_GetHashValue(vocabulary_word_entryPtr);
	Tcl_SetHashValue(vocabulary_word_entryPtr, value+1);

	category_word_entryPtr = Tcl_NextHashEntry(searchPtr);

	num_words[i]++;
      }

      num_docs[i] = slicelen;

    }

    total_docs += slicelen;

  }

  Tcl_Free(wordcount_tablePtr);
  Tcl_Free(num_docs);
  Tcl_Free(num_words);

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

