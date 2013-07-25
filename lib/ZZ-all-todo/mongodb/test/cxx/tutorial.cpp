#include <iostream>
#include "client/dbclient.h"


using namespace mongo;
using namespace std;

void run() {
  DBClientConnection c;
  c.connect("localhost");

  // GENOID is optional. if not done by client, server will add an _id
  c.insert("mydb.users", BSON(GENOID<<"a"<< rand()%10 <<"b"<< rand() ));
  // then optionally:
  string err = c.getLastError();

  /*  auto_ptr<DBClientCursor> cursor = 
    c.query("mydb.users", QUERY ("a"<< BSON("$lte" << 7)).sort("b") );
  */
  auto_ptr<DBClientCursor> cursor = 
    c.query("mydb.users", QUERY ("a"<< GT << 7).sort("b") );


  while( cursor->more() ) {
    BSONObj p = cursor->next();
    cout << p.toString() << " --- " << p.getIntField("b") << endl;
  }

  cout << "------------------\n";

  BSONObj cmdResult;
  bool ok = c.runCommand("mydb", BSON("distinct" << "users"
				      << "key" << "b"
				      << "query" << BSON("a"<<8)),
			 cmdResult);

  cout << cmdResult["values"].toString() <<endl;

  list<int> results;
  cmdResult["values"].Obj().Vals(results);

  /*
  BSONObjIterator i(cmdResult["values"].Obj());
  while( i.more() ) {
    int x;
    i.next().Val(x);
    cout << x << endl;

    //BSONObj y;
    //cout << x.Val(y);
    //results.push_back(y);
  }
  */



  list<int>::const_iterator it = results.begin();
  for(; it != results.end(); ++it) {
    cout << "result:" << *it << endl;
  }

  c.remove("mydb.users", QUERY("a"<<"7"));
  // then optionally:
  err = c.getLastError();
  cout << "err=" << err << endl;

  /*
include<algorithm>

  std::copy(results.begin(),results.end(),ostream_iterator<int>(cout,"\n"));
  */

}


int main() {
  srand(time(NULL));

  try {
    run();
    cout << "connected ok" << endl;
  } catch( DBException &e ) {
    cout << "caught " << e.what() << endl;
  }

  return 0;
}
