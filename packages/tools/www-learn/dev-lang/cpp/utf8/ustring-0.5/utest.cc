/*
  ustring, a C++ Unicode library.
  Copyright (C) 2000 Rodrigo Reyes, reyes@charabia.net

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*/

#include "WString.h"
#include "UnicodeData.h"
#include "WRegExp.h"

using namespace ustring;

void displayList(list<WChar> &lst)
{
  cerr << "{";
  for (list<WChar>::iterator i=lst.begin(); i!=lst.end(); )
    {
      char buf[32];
      sprintf(buf, "%04x::%d::(%d)", *i,*i, UnicodeDataBase::getInstance().getCombiningClass(*i));
      cerr << buf;
      ++i;
      if (i != lst.end())
	cerr << ",";
    }
  cerr << "}";
}

int main()
{
  WString ws1("latin1", "été");
  cerr << ws1.toString("utf-8") << " : " <<  ws1.debugString() << endl;
  cerr << "canonical decomp : " << ws1.getCanonicalDecomposition().debugString() << endl;
  cerr << "compat decomp : " << ws1.getCompatibilityDecomposition().debugString() << endl;

  UnicodeDataBase& database = UnicodeDataBase::getInstance();

  WString ws2 = ws1.getCompatibilityDecomposition();
  cerr << "canonical1 : ";
  list<WChar> tmpl = ws2.getData();
  displayList(tmpl); cerr << endl;

  list<WChar> res;
  database.canonicalComposition(ws2.getData(), res);
  cerr << "canonical : ";
  displayList(res);
  cerr << endl;

  list<WChar> sorttest;
  sorttest.push_back(0x49); // I
  sorttest.push_back(0x300); // grave cc: 230

  sorttest.push_back(0x315); // cc: 232
  sorttest.push_back(0x314); // cc: 230
  sorttest.push_back(0x316); // cc: 220
  sorttest.push_back(0x49); // I
  sorttest.push_back(0x49); // I
  sorttest.push_back(0x49); // I

  cerr << "before : "; 
  displayList(sorttest);
  cerr << endl;
  database.sortCombiningClasses(sorttest);

  cerr << "after : "; 
  displayList(sorttest);

  cout << endl;
  //  cout << "BEGIN : " << *ws1.begin() << endl;
  for (WString::const_iterator iter1 = ws1.begin(); iter1 != ws1.end(); iter1++)
    {
      cout << "ITER: " << *iter1 << endl;
    }
  WString cw(ws1);
  //  WString::iterator j = cw.begin();
  //  WString::const_iterator cj = j;
  //  *(j+1) = (WChar) 0xe5;

  ws1 = ws1.getNormalizationFormC();
  //ws1 = ws1.getLowerCase();
  
  cout << "FINAL : " << ws1.toString("UTF-8") << endl;
  cout << ws1.debugString() << endl;

  cout << "NO MARKS : " << ws1.getCanonicalDecompositionNoMark().getUpperCase().toString("UTF-8") << endl;

  ws1 = ws1.getCanonicalDecompositionNoMark();
  ws1 = WString("latin1","r@dde.ne-t");
  WRegExp wre;
  wre.setExpression("[a-z]+@({L}|{P})+", 1);
  wre.printDebug(cerr);
  cerr << "check : " <<  wre.match(ws1) << endl;
}
