#include "tlucene.h"

#include "CLucene.h"
#include "utf8.cc"


using namespace lucene::util;
using namespace lucene::index;
using namespace lucene::analysis;
using namespace lucene::store;
using namespace lucene::document;
using namespace lucene::search;
using namespace lucene::queryParser;

void getBooleanQueryString(std::wstring& buffer,BooleanQuery *bq);
void getTermQueryString(std::wstring& buffer,TermQuery *query);
void getPhraseQueryString(std::wstring& buffer,PhraseQuery *query);
void getQueryString(std::wstring& buffer,Query *query);


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

void getBooleanQueryString(std::wstring& buffer, BooleanQuery* bq) {

    int32_t size = bq->getClauseCount();
    BooleanClause** clauses = _CL_NEWARRAY(BooleanClause*, size);
    bq->getClauses(clauses);

    if (size>0) {
      for (int32_t j = 0;j<size;++j ){
	if (j>0) buffer.append( _T(" ") );
	//clauses[j]->required=1;

	Query * cq = clauses[j]->getQuery();
	getQueryString(buffer,cq);
      }
    }
    _CLDELETE_ARRAY(clauses);

}

void getTermQueryString(std::wstring& buffer, TermQuery* query) {
  buffer.append( _T("{") );
  buffer.append( ((TermQuery *) query)->getTerm()->field() );
  buffer.append( _T(" {") );
  buffer.append( ((TermQuery *) query)->getTerm()->text() );
  buffer.append( _T("}}") );
}

void getPhraseQueryString(std::wstring& buffer, PhraseQuery* query) {

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


void getQueryString(std::wstring& buffer, Query* q) {
  if (q->instanceOf(BooleanQuery::getClassName())) {
    getBooleanQueryString(buffer,(BooleanQuery *) q);
  } else if (q->instanceOf(TermQuery::getClassName())) {
    getTermQueryString(buffer,(TermQuery *) q);
  } else if (q->instanceOf(PhraseQuery::getClassName())) {
    getPhraseQueryString(buffer,(PhraseQuery *) q);
  }
}


void tlucene_ParseQuery(const char *utf8_query_string, char * result) {

  TCHAR wcs_query_string[MAX_QUERY_BYTELEN];
  lucene_utf8towcs(wcs_query_string,utf8_query_string,MAX_QUERY_BYTELEN);

  PerFieldAnalyzerWrapper *aWrapper = 
    _CLNEW PerFieldAnalyzerWrapper(_CLNEW standard::StandardAnalyzer());

  aWrapper->addAnalyzer( _T("subject"), _CLNEW KeywordAnalyzer());

  Query *q = getQuery(wcs_query_string,aWrapper);

  if (!q) return;

  std::wstring buffer;
  getQueryString(buffer,q);
  _CLDELETE(q);
  _CLDELETE(aWrapper);
  lucene_wcstoutf8(result,buffer.c_str(),buffer.size() * sizeof(wchar_t));

}

void tlucene_Tokenize(const char *utf8_query_string, std::map<std::string,std::list<int> >& result) {

  TCHAR input[MAX_QUERY_BYTELEN];
  lucene_utf8towcs(input,utf8_query_string,MAX_QUERY_BYTELEN);

  Analyzer *analyzer = _CLNEW standard::StandardAnalyzer();

  Reader* reader = _CLNEW StringReader(input);
  TokenStream* ts = analyzer->tokenStream(_T("dummy"), reader );
  Token t;

  char utf8_term_text[MAX_TOKEN_LEN];
  while (ts->next(&t)) {

    lucene_wcstoutf8(utf8_term_text,t.termBuffer(),MAX_TOKEN_LEN);
    result[std::string(utf8_term_text)].push_back(t.startOffset());

  }

  ts->close();
  _CLDELETE(reader);
  _CLDELETE(ts);
  _CLDELETE(analyzer);
  
}
