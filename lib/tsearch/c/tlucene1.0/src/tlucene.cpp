#include <stdio.h>
#include <unistd.h>
#include <sys/time.h>

#include "CLucene.h"

#include <boost/shared_ptr.hpp>


#include <tcl.h>
#include <string>

//#define DEBUG

#define DEFINE_string(x,y) std::string x = Tcl_GetString(y);
#define DEFINE_int64(x,y)  int64_t x = atoi(Tcl_GetString(y));
#define DEFINE_int32(x,y) int32_t x = atoi(Tcl_GetString(y));
#define MAX_TOKEN_LEN 1024
#define MAX_TERM_LEN 1024
#define MAX_QUERY_BYTELEN 4096

#define tr(container, it) \
  for(typeof(container.begin()) it = container.begin(); it != container.end(); it++)

#define CheckArgs(min,max,n,msg) \
                     if ((objc < min) || (objc > max)) { \
                         Tcl_WrongNumArgs(interp, n, objv, msg); \
                         return TCL_ERROR; \
                     }

using namespace lucene::util;
using namespace lucene::index;
using namespace lucene::analysis;
using namespace lucene::store;
using namespace lucene::document;
using namespace lucene::search;
using namespace lucene::queryParser;



void getBooleanQueryString(StringBuffer& buffer,BooleanQuery *bq);
void getTermQueryString(StringBuffer& buffer,TermQuery *query);
void getPhraseQueryString(StringBuffer& buffer,PhraseQuery *query);
void getQueryString(StringBuffer& buffer,Query *query);


Query* getQuery(const TCHAR* query, Analyzer* a) {
  try{
    bool del = (a==NULL);
    if (a == NULL)
      a = _CLNEW standard::StandardAnalyzer();

    QueryParser qp(_T("FTS"), a);
    Query* ret = qp.parse(query);

    if ( del )
      _CLDELETE(a);
    return ret;
  }catch(CLuceneError& e){
    return NULL;
  }catch(...){
    return NULL;
  }
}

void getBooleanQueryString(StringBuffer& buffer, BooleanQuery* bq) {

    int32_t size = bq->getClauseCount();
    BooleanClause** clauses = _CL_NEWARRAY(BooleanClause*, size);
    bq->getClauses(clauses);

    if (size>0) {
      for (int32_t j = 0;j<size;++j ){
	if (j>0) buffer.append( _T(" ") );
	//clauses[j]->required=1;

	Query * cq = clauses[j]->query;
	getQueryString(buffer,cq);
      }
    }
    _CLDELETE_ARRAY(clauses);

}

void getTermQueryString(StringBuffer& buffer, TermQuery* query) {
  buffer.append( _T("{") );
  buffer.append( ((TermQuery *) query)->getTerm()->field() );
  buffer.append( _T(" {") );
  buffer.append( ((TermQuery *) query)->getTerm()->text() );
  buffer.append( _T("}}") );
}

void getPhraseQueryString(StringBuffer& buffer, PhraseQuery* query) {

  buffer.append( _T("{") );
  buffer.append( ((PhraseQuery *) query)->getFieldName());
  buffer.append( _T(" ") );
  buffer.append( _T("{") );
  Term *T = NULL;
  Term **terms = ((PhraseQuery *) query)->getTerms();
  uint32_t i = 0;
  while (terms[i] != NULL) {
    T = terms[i];
    buffer.append( T->text() );
    i++;
    if (terms[i] != NULL) buffer.append( _T(" ") );
  }
  buffer.append( _T("}") );
  buffer.append( _T("}") );

}


void getQueryString(StringBuffer& buffer, Query* q) {
  if (q->instanceOf(BooleanQuery::getClassName())) {
    getBooleanQueryString(buffer,(BooleanQuery *) q);
  } else if (q->instanceOf(TermQuery::getClassName())) {
    getTermQueryString(buffer,(TermQuery *) q);
  } else if (q->instanceOf(PhraseQuery::getClassName())) {
    getPhraseQueryString(buffer,(PhraseQuery *) q);
  }
}




static int
Tlucene_luceneCmd(ClientData clientData
		       ,Tcl_Interp *interp
		       ,int objc
		       ,Tcl_Obj *CONST objv[])
{ 

  CheckArgs(2,objc,objc,"wrong # args: should be \"cassandra subcommand args\"");
  
  boost::shared_ptr<std::string> cmd(new std::string(Tcl_GetString(objv[1])));

  if ( 0 == cmd->compare("parse_query") ) {

    CheckArgs(3,3,objc,"wrong # args: should be \"cassandra parse_query query_string\"");
    const TCHAR* buf = NULL;
    //const TCHAR *field=_T("FTS");
    int charlength=0;
    char *utf8_query_string = Tcl_GetStringFromObj(objv[2],&charlength);
    TCHAR wcs_query_string[MAX_QUERY_BYTELEN];
    lucene_utf8towcs(wcs_query_string,utf8_query_string,MAX_QUERY_BYTELEN);
    char result[MAX_QUERY_BYTELEN];
    result[0]='\0';

    //Analyzer *analyzer = _CLNEW standard::StandardAnalyzer();
    //Analyzer *analyzer = _CLNEW SimpleAnalyzer();
    //Analyzer *analyzer3  = _CLNEW WhitespaceAnalyzer();
    //Analyzer *analyzer4 = _CLNEW QPTestAnalyzer();
    PerFieldAnalyzerWrapper *analyzer = _CLNEW PerFieldAnalyzerWrapper(_CLNEW standard::StandardAnalyzer());
    analyzer->addAnalyzer( _T("subject"), _CLNEW KeywordAnalyzer());




    // [NOTE]
    //   QueryParser call with one or two arguments is not threadsafe, 
    //   use one per thread or use a thread lock.
    // [DEPRECATED DUE TO THREAD-SAFETY ISSUES]
    //   Query *q = QueryParser::parse(wcs_query_string, field, analyzer);
    //
    //QueryParser *parser = _CLNEW QueryParser(field,analyzer);
    //QueryParser *parser = _CLNEW QueryParser(_T("FTS2"),analyzer);
    //Query *q=parser->parse(wcs_query_string);

    Query *q = getQuery(wcs_query_string,analyzer);


    //const TCHAR *qry= _T("hello tag:inbox world");
    //Query *q = parser->parse(qry);

    StringBuffer buffer;
    getQueryString(buffer,q);
    buf = buffer.toString();
    _CLDELETE(q);
    _CLDELETE(analyzer);
    if (buf != NULL) {
      lucene_wcstoutf8(result,buf,MAX_QUERY_BYTELEN);
      _CLDELETE_CARRAY(buf);
    }


    //wprintf(L"%ls\n",buffer.toString());
    //buf = bq->toString(_T("FTS"));
    //int result_length = _tcslen(buf)+1;

    Tcl_SetObjResult(interp, Tcl_NewStringObj(result,-1));

  } else if ( 0 == cmd->compare("tokenize") ) {

    CheckArgs(3,3,objc,"wrong # args: should be \"cassandra tokenize text\"");


    // SOL1_OLD: charlength = Tcl_GetCharLength(objv[2]);


    //TCHAR * input = _T("The quick brown fox jumped over 234");
    int charlength=0;
    char *str = Tcl_GetStringFromObj(objv[2],&charlength);
    TCHAR input[charlength+1];
    lucene_utf8towcs(input,str,charlength+1);


    Analyzer *analyzer = _CLNEW standard::StandardAnalyzer();

    Reader* reader = _CLNEW StringReader(input);
    TokenStream* ts = analyzer->tokenStream(_T("dummy"), reader );
    Token t;
    const TCHAR* buf;
    Tcl_Obj *keyPtr;
    Tcl_Obj *listPtr;
    Tcl_Obj *dictPtr = Tcl_NewDictObj();
    char utf8_term_text[MAX_TOKEN_LEN];
    while (ts->next(&t)) {
      buf = t.termText();
      lucene_wcstoutf8(utf8_term_text,buf,MAX_TOKEN_LEN);
      keyPtr = Tcl_NewStringObj(utf8_term_text,-1);

      Tcl_DictObjGet(interp
		     ,dictPtr
		     ,keyPtr
		     ,&listPtr);
      if (listPtr == NULL) {
	listPtr = Tcl_NewListObj(0,NULL);
      }
      Tcl_ListObjAppendElement(interp,listPtr,Tcl_NewIntObj(t.startOffset()));

      Tcl_DictObjPut(interp
		     ,dictPtr
		     ,keyPtr
		     ,listPtr);

      //wprintf(L"token.termText()=%ls startOffset()=%d endOffset()=%d type()=%ls token.toString()=%ls\n",t.termText(),t.startOffset(),t.endOffset(),t.type(),t.toString());
    }
    ts->close();
    _CLDELETE(reader);
    _CLDELETE(ts);
    _CLDELETE(analyzer);
    Tcl_SetObjResult(interp, dictPtr);

  }


  return TCL_OK;
}


/*
 *----------------------------------------------------------------------
 *
 * The following structure defines a command to be created
 * in new interps.
 *
 *----------------------------------------------------------------------
 */

typedef struct Cmd {
  const char *name;
  Tcl_CmdProc *proc;
  Tcl_ObjCmdProc *objProc;
} Cmd;


static Cmd cmds[] = {
  
  {"::xo::lib::lucene", NULL, Tlucene_luceneCmd},
  
  /*
   * Add more server Tcl commands here.
   */
  
  {0, NULL}
};    



static void AddCmds(Tcl_Interp *interp, Cmd *cmdPtr)
{
  while (cmdPtr->name != NULL) {
    if (cmdPtr->objProc != NULL) {
      Tcl_CreateObjCommand(interp, cmdPtr->name, cmdPtr->objProc, 
			   (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
    } else {
      Tcl_CreateCommand(interp, cmdPtr->name, cmdPtr->proc, 
			(ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
    }
    ++cmdPtr;
  }
}

extern "C" {
  int  Tlucene_Init(Tcl_Interp *interp)
  {
    
    Tcl_Eval(interp, "namespace eval ::xo {;}");
    Tcl_Eval(interp, "namespace eval ::xo::lib {;}");
    AddCmds(interp,cmds);
    return TCL_OK;
  }
  
}
