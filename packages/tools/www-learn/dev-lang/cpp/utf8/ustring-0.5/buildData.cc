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

#include <iostream>
#include <string>
#include <fstream>
#include <vector>
#include <list>
#include <map>
#include <stdio.h>

#include "UnicodeDataEnums.h"
#include "WStringTypes.h"

struct UnicodeDataChar
{

  // # 0
  int Code; 
  // # 1
  const char* Name;
  
  // #2
  UnicodeCategory Category;
  UnicodeSubCategory Subcategory;

  // #3
  int CombiningClasses;
  
  // #4
  UnicodeBidirectionalCategory Bidi;

  // #5
  UnicodeDecompositionCategory DecompCategory;
  string DecompValues;

  // #6
  int DecimalValue;
  // #7 
  int DigitValue;
  // #8
  int NumericValue;

  // #9
  bool Mirrored;
  
  // #10 : Unicode 1.0 names
  // #11 : 10646 comment field
  // #12
  int UpperCase;

  // #13
  int LowerCase;

  // #14
  int TitleCase;
  
};

struct catMapping 
{
  char* val;
  UnicodeCategory cat;
  UnicodeSubCategory subcat;
};

struct catMapping catmapping [] =  {
  { "Lu", UNICODE_LETTER, UNICODE_LETTER_UPPERCASE },
  { "Ll", UNICODE_LETTER, UNICODE_LETTER_LOWERCASE },
  { "Lt", UNICODE_LETTER, UNICODE_LETTER_TITLECASE },
  { "Lm", UNICODE_LETTER, UNICODE_LETTER_MODIFIER },
  { "Lo", UNICODE_LETTER, UNICODE_LETTER_OTHER },

  { "Mn", UNICODE_MARK, UNICODE_MARK_NONSPACING },
  { "Mc", UNICODE_MARK, UNICODE_MARK_SPACING },
  { "Me", UNICODE_MARK, UNICODE_MARK_ENCLOSING },

  { "Nd", UNICODE_NUMBER, UNICODE_NUMBER_DECIMAL },
  { "Nl", UNICODE_NUMBER, UNICODE_NUMBER_LETTER },
  { "No", UNICODE_NUMBER, UNICODE_NUMBER_OTHER },

  { "Zs", UNICODE_SEPARATOR, UNICODE_SEPARATOR_SPACE },
  { "Zl", UNICODE_SEPARATOR, UNICODE_SEPARATOR_LINE },
  { "Zp", UNICODE_SEPARATOR, UNICODE_SEPARATOR_PARAGRAPH },

  { "Cc", UNICODE_OTHER, UNICODE_OTHER_CONTROL },
  { "Cf", UNICODE_OTHER, UNICODE_OTHER_FORMAT },
  { "Cs", UNICODE_OTHER, UNICODE_OTHER_SURROGATE },
  { "Co", UNICODE_OTHER, UNICODE_OTHER_PRIVATE },
  { "Cn", UNICODE_OTHER, UNICODE_OTHER_NOTASSIGNED },

  { "Pc", UNICODE_PUNCTUATION, UNICODE_PUNCTUATION_CONNECTOR },
  { "Pd", UNICODE_PUNCTUATION, UNICODE_PUNCTUATION_DASH },
  { "Ps", UNICODE_PUNCTUATION, UNICODE_PUNCTUATION_OPEN },
  { "Pe", UNICODE_PUNCTUATION, UNICODE_PUNCTUATION_CLOSE },
  { "Pi", UNICODE_PUNCTUATION, UNICODE_PUNCTUATION_INITIALQUOTE },
  { "Pf", UNICODE_PUNCTUATION, UNICODE_PUNCTUATION_FINALQUOTE },
  { "Po", UNICODE_PUNCTUATION, UNICODE_PUNCTUATION_OTHER },

  { "Sm", UNICODE_SYMBOL, UNICODE_SYMBOL_MATH },
  { "Sc", UNICODE_SYMBOL, UNICODE_SYMBOL_CURRENCY },
  { "Sk", UNICODE_SYMBOL, UNICODE_SYMBOL_MODIFIER },
  { "So", UNICODE_SYMBOL, UNICODE_SYMBOL_OTHER },
  { 0 }
};

struct bidiMapping {
  char* val;
  UnicodeBidirectionalCategory cat;
};

struct bidiMapping bidimapping[]  = {
  { "L", UNICODE_BIDI_L },
  { "LRE", UNICODE_BIDI_LRE },
  { "LRO", UNICODE_BIDI_LRO },
  { "R", UNICODE_BIDI_R },
  { "AL", UNICODE_BIDI_AL },
  { "RLE", UNICODE_BIDI_RLE },
  { "RLO", UNICODE_BIDI_RLO },
  { "PDF", UNICODE_BIDI_PDF },
  { "EN", UNICODE_BIDI_EN },
  { "ES", UNICODE_BIDI_ES },
  { "ET", UNICODE_BIDI_ET },
  { "AN", UNICODE_BIDI_AN },
  { "CS", UNICODE_BIDI_CS },
  { "NSM", UNICODE_BIDI_NSM },
  { "BN", UNICODE_BIDI_BN },
  { "B", UNICODE_BIDI_B },
  { "B", UNICODE_BIDI_B },
  { "S", UNICODE_BIDI_S},
  { "WS", UNICODE_BIDI_WS },
  { "ON", UNICODE_BIDI_ON },
  { 0 }
};

struct decompMapping {
  char* val;
  UnicodeDecompositionCategory cat;
};

struct decompMapping decompmapping[] = {
  { "<font>", UNICODE_DECOMP_FONT },
  { "<noBreak>", UNICODE_DECOMP_NOBREAK },
  { "<initial>", UNICODE_DECOMP_INITIAL },
  { "<medial>", UNICODE_DECOMP_MEDIAL },
  { "<final>", UNICODE_DECOMP_FINAL },
  { "<isolated>", UNICODE_DECOMP_ISOLATED },
  { "<circle>", UNICODE_DECOMP_CIRCLE },
  { "<sub>", UNICODE_DECOMP_SUB },
  { "<vertical>", UNICODE_DECOMP_VERTICAL },
  { "<wide>", UNICODE_DECOMP_WIDE },
  { "<narrow>", UNICODE_DECOMP_NARROW },
  { "<small>", UNICODE_DECOMP_SMALL },
  { "<square>", UNICODE_DECOMP_SQUARE },
  { "<fraction>", UNICODE_DECOMP_FRACTION },
  { "<compat>", UNICODE_DECOMP_COMPAT },
  { 0 }
};

class SimpleDAGNode
{
  map<WChar, SimpleDAGNode> m_next;
  list<WChar> m_result;

public:
  
  SimpleDAGNode()
  {
  }

  void add(const WChar& wc, list<int>::const_iterator cur, const list<int>::const_iterator& end)
  {
    if (cur == end)
      {
	m_result.push_back(wc);
	return;	
      }
    SimpleDAGNode& dagn = m_next[*cur];
    dagn.add(wc, ++cur, end);
  }
  
  int nextCount() const
  {
    return m_next.size();
  }

  const map<WChar, SimpleDAGNode>& getNext() const
  {
    return m_next;
  }
  const list<WChar>& getResults() const
  {
    return m_result;
  }
  
  string toString()
  {
    char buffer[64];
    string result = "";
    result += "[";
    for (map<WChar,SimpleDAGNode>::iterator i=m_next.begin(); i!=m_next.end(); i++)
      {
	sprintf(buffer, "%d=", (int)i->first);
	result += buffer;
	result += i->second.toString();
      }
    result += "]";
    return result;
  }
};

int outputDAGSize(const SimpleDAGNode& node)
{
  const list<WChar>& results = node.getResults();
  const map<WChar, SimpleDAGNode>& next = node.getNext();

  int size = 2 + results.size() + (next.size()*2);

  for (map<WChar, SimpleDAGNode>::const_iterator i = next.begin(); i!=next.end(); ++i)
    {
      size += outputDAGSize(i->second);
    }
  return size;
}


void outputDAG(const SimpleDAGNode& node, vector<int>& data, int& curindex)
{
  const list<WChar>& results = node.getResults();
  const map<WChar, SimpleDAGNode>& next = node.getNext();
  int nodesize = 2 + results.size() + (next.size()*2);
  int after = curindex + nodesize;

  data[curindex] = results.size();
  int offset = 1;
  for (list<WChar>::const_iterator i = results.begin(); i != results.end(); ++i)
    {
      data[curindex + offset++] = *i;
    }

  data[curindex + offset++] = next.size();
  for (map<WChar, SimpleDAGNode>::const_iterator i = next.begin(); i!=next.end(); ++i)
    {
      data[curindex + offset++] = i->first;
      data[curindex + offset++] = after;
      outputDAG(i->second, data, after);
    }
  curindex = after;
}


void tokenizeLine(string* result, const string& line)
{
  
  for (unsigned int i=0, curidx=0; i<15; i++)
    {
      unsigned int next = line.find(';', curidx);
      if (next  != line.npos)
	{
	  result[i] = line.substr(curidx, next - (curidx));
	  curidx = next+1;
	}
      else
	{
	  result[i] = line.substr(curidx+1);
	}
    }
}

void fillVector(const string& str, vector<string>& result)
{
  unsigned int lasti = 0;
  unsigned int i = str.find(' ');
  while (i != str.npos)
    {
      string s = str.substr(lasti, i-lasti);
      result.push_back(s);
      lasti = i+1;
      i = str.find(' ', i+1);
    }
  string s = str.substr(lasti);
  if (s.length() > 0)
    result.push_back(s);

}


void writeOutput2(list<UnicodeDataChar>& data, ostream& out, ostream& outh)
{
  int count;

  out << "#include \"UnicodeDataEnums.h\"\n";
  out << "#include \"WString.h\"\n";
  outh << "#ifndef __UNICODEDATA_GEN_H_\n";
  outh << "#define __UNICODEDATA_GEN_H_\n";
  outh << "#include \"UnicodeDataEnums.h\"\n";
  outh << "#include \"WStringTypes.h\"\n";

  out << "namespace ustring {\n";
  outh << "namespace ustring {\n";

  outh << "extern int unicodeDataBase_Size;\n";
  out << "int unicodeDataBase_Size = " << data.size() << ";\n";
  
  SimpleDAGNode rootnode;
  for (list<UnicodeDataChar>::iterator i=data.begin(); i != data.end(); ++i)
    {
      if (i->DecompCategory == UNICODE_DECOMP_CANONICAL)
	{
	  vector<string> fillit;
	  list<int> seq;
	  fillVector(i->DecompValues, fillit);
	  for (unsigned int vc=0; vc<fillit.size(); vc++)
	    {
	      seq.push_back( strtol(fillit[vc].c_str(), NULL, 16) );
	    }
	  rootnode.add(i->Code, seq.begin(), seq.end());
	}
    }


  int dagsize = outputDAGSize(rootnode);
  vector<int> dataMap(dagsize);
  int curdatamapidx = 0;
  outputDAG(rootnode, dataMap, curdatamapidx);
  out << "int unicodeDataBase_CompositionDAG[" << dagsize  << "] = {\n";
  outh << "extern int unicodeDataBase_CompositionDAG[" << dagsize << "];\n";
  for (vector<int>::iterator i=dataMap.begin(); i!=dataMap.end();)
    {
      out << *i;
      ++i;
      if (i != dataMap.end())
	out << ",\n";
      else
	out << "\n";
    }
  out << "};\n\n";


  out << "WChar unicodeDataBase_Code[" << data.size() << "] = {\n";
  outh << "extern WChar unicodeDataBase_Code[" << data.size() << "];\n";
  count = 0;
  for (list<UnicodeDataChar>::iterator i=data.begin(); i != data.end(); )
    {
      out << i->Code;
      if (++i != data.end())
	out << ",";
      out << " // " << count++ << "\n";
    }
  out << "};\n\n";

  out << "const char* unicodeDataBase_Name[" << data.size() << "] = {\n";
  outh << "extern const char* unicodeDataBase_Name[" << data.size() << "];\n";
  count = 0;
  for (list<UnicodeDataChar>::iterator i=data.begin(); i != data.end(); )
    {
      out << "\"" << i->Code << "\"";
      if (++i != data.end())
	out << ",";
      out << " // " << count++ << "\n";
    }
  out << "};\n\n";

  out << "UnicodeCategory unicodeDataBase_Category[" << data.size() << "] = {\n";
  outh << "extern UnicodeCategory unicodeDataBase_Category[" << data.size() << "];\n";
  count = 0;
  for (list<UnicodeDataChar>::iterator i=data.begin(); i != data.end(); )
    {
      out << "(UnicodeCategory)" << i->Category;
      if (++i != data.end())
	out << ",";
      out << " // " << count++ << "\n";
    }
  out << "};\n\n";

  out << "UnicodeSubCategory unicodeDataBase_SubCategory[" << data.size() << "] = {\n";
  outh << "extern UnicodeSubCategory unicodeDataBase_SubCategory[" << data.size() << "];\n";
  count = 0;
  for (list<UnicodeDataChar>::iterator i=data.begin(); i != data.end(); )
    {
      out << "(UnicodeSubCategory)" << i->Category;
      if (++i != data.end())
	out << ",";
      out << " // " << count++ << "\n";
    }
  out << "};\n\n";

  out << "int unicodeDataBase_CombiningClasses[" << data.size() << "] = {\n";
  outh << "extern int unicodeDataBase_CombiningClasses[" << data.size() << "];\n";
  count = 0;
  for (list<UnicodeDataChar>::iterator i=data.begin(); i != data.end(); )
    {
      out << i->CombiningClasses;
      if (++i != data.end())
	out << ",";
      out << " // " << count++ << "\n";
    }
  out << "};\n\n";

  out << "UnicodeBidirectionalCategory unicodeDataBase_Bidi[" << data.size() << "] = {\n";
  outh << "extern UnicodeBidirectionalCategory unicodeDataBase_Bidi[" << data.size() << "];\n";
  count = 0;
  for (list<UnicodeDataChar>::iterator i=data.begin(); i != data.end(); )
    {
      out << "(UnicodeBidirectionalCategory)" << i->Bidi;
      if (++i != data.end())
	out << ",";
      out << " // " << count++ << "\n";
    }
  out << "};\n\n";

  out << "UnicodeDecompositionCategory unicodeDataBase_DecompCategory[" << data.size() << "] = {\n";
  outh << "extern UnicodeDecompositionCategory unicodeDataBase_DecompCategory[" << data.size() << "];\n";
  count = 0;
  for (list<UnicodeDataChar>::iterator i=data.begin(); i != data.end(); )
    {
      out << "(UnicodeDecompositionCategory)" << i->DecompCategory;
      if (++i != data.end())
	out << ",";
      out  << " // " << count++ << "\n";
    }
  out << "};\n\n";


  list<int> indexToDecompValIndex;

  out << "WChar unicodeDataBase_DecompValues[" << /*data.size() <<*/ "] = {\n";
  outh << "extern WChar unicodeDataBase_DecompValues[" << /*data.size() <<*/ "];\n";
  int dviidx = 0;
  vector<string> fillit;
  for (list<UnicodeDataChar>::iterator i=data.begin(); i != data.end(); i++)
    {
      fillit.erase(fillit.begin(), fillit.end());
      fillVector(i->DecompValues, fillit);

      if (fillit.size()>0)
	{
	  indexToDecompValIndex.push_back(dviidx);
	  out << "/* " << dviidx << " */ " << fillit.size() << ", ";
	  dviidx++;
	  for (vector<string>::iterator vsi = fillit.begin(); vsi != fillit.end(); )
	    {
	      int val = strtol(vsi->c_str(), NULL, 16);
	      out << val;
	      ++vsi;
	      ++dviidx;
	      if (vsi == fillit.end())
		out << ",\n";
	      else out << ", ";
	    }
	}
      else
	{
	  indexToDecompValIndex.push_back(-1);
	}
    }
  out << "};\n\n";

  out << "int unicodeDataBase_DecompValuesIndex[" << data.size() << "] = {\n";
  outh << "extern int unicodeDataBase_DecompValuesIndex[" << data.size() << "];\n";
  count = 0;
  for (list<int>::iterator i=indexToDecompValIndex.begin(); i != indexToDecompValIndex.end(); )
    {
      out << *i;
      i++;      
      if (i != indexToDecompValIndex.end())
	out << ", // " << count++<< "\n";
    }
  out << "};\n\n";
  
  out << "int unicodeDataBase_DecimalValue[" << data.size() << "] = {\n";
  outh << "extern int unicodeDataBase_DecimalValue[" << data.size() << "];\n";
  count = 0;
  for (list<UnicodeDataChar>::iterator i=data.begin(); i != data.end(); )
    {
      out << i->DecimalValue;
      if (++i != data.end())
	out << ",";
      out << "\n";
    }
  out << "};\n\n";  

  out << "int unicodeDataBase_DigitValue[" << data.size() << "] = {\n";
  outh << "extern int unicodeDataBase_DigitValue[" << data.size() << "];\n";
  for (list<UnicodeDataChar>::iterator i=data.begin(); i != data.end(); )
    {
      out << i->DigitValue;
      if (++i != data.end())
	out << ",";
      out << " // " << count++ << "\n";
    }
  out << "};\n\n";  

  out << "int unicodeDataBase_NumericValue[" << data.size() << "] = {\n";
  outh << "extern int unicodeDataBase_NumericValue[" << data.size() << "];\n";
  for (list<UnicodeDataChar>::iterator i=data.begin(); i != data.end(); )
    {
      out << i->NumericValue;
      if (++i != data.end())
	out << ",";
      out << " // " << count++  << "\n";
    }
  out << "};\n\n";  

  out << "bool unicodeDataBase_Mirrored[" << data.size() << "] = {\n";
  outh << "extern bool unicodeDataBase_Mirrored[" << data.size() << "];\n";
  for (list<UnicodeDataChar>::iterator i=data.begin(); i != data.end(); )
    {
      out << "\"" << (i->Mirrored?"true":"false") << "\"";
      if (++i != data.end())
	out << ",";
      out << " // " << count++  << "\n";
    }
  out << "};\n\n";  

  out << "int unicodeDataBase_UpperCase[" << data.size() << "] = {\n";
  outh << "extern int unicodeDataBase_UpperCase[" << data.size() << "];\n";
  for (list<UnicodeDataChar>::iterator i=data.begin(); i != data.end(); )
    {
      out << i->UpperCase;
      if (++i != data.end())
	out << ",";
      out << " // " << count++  << "\n";
    }
  out << "};\n\n";  

  out << "int unicodeDataBase_LowerCase[" << data.size() << "] = {\n";
  outh << "extern int unicodeDataBase_LowerCase[" << data.size() << "];\n";
  for (list<UnicodeDataChar>::iterator i=data.begin(); i != data.end(); )
    {
      out << i->LowerCase;
      if (++i != data.end())
	out << ",";
      out << " // " << count++  << "\n";
    }
  out << "};\n\n";  

  out << "int unicodeDataBase_TitleCase[" << data.size() << "] = {\n";
  outh << "extern int unicodeDataBase_TitleCase[" << data.size() << "];\n";
  for (list<UnicodeDataChar>::iterator i=data.begin(); i != data.end(); )
    {
      out << i->TitleCase;
      if (++i != data.end())
	out << ",";
      out << " // " << count++  << "\n";
    }
  out << "};\n\n";  

  out << "}\n";
  outh << "}\n";

  outh << "#endif\n";
}

void writeOutput(list<UnicodeDataChar>& data, ostream& out)
{
  out << "#include \"UnicodeData.h\"\n";
  out << "struct UnicodeDataChar unicodedatabase[" << data.size() << "] = {\n";
  for (list<UnicodeDataChar>::iterator i=data.begin(); i != data.end(); )
    {
      UnicodeDataChar& udc = *i;

      out << "{ ";
      out << udc.Code << ", ";
      out << "(char*)0, ";
      //      out << "\"" << udc.Name << "\", ";
      out << "(UnicodeCategory)" << udc.Category << ", ";
      out << "(UnicodeSubCategory)" << udc.Subcategory << ", ";
      out << udc.CombiningClasses << ", ";
      out << "(UnicodeBidirectionalCategory)" << udc.Bidi << ", ";
      out << "(UnicodeDecompositionCategory)" << udc.DecompCategory << ", ";
      out << "\"" << udc.DecompValues << "\", ";
      out << udc.DecimalValue << ", ";
      out << udc.DigitValue << ", ";
      out << udc.NumericValue << ", ";
      out << ((udc.Mirrored)?"true":"false") << ", ";
      out << udc.UpperCase << ", ";
      out << udc.LowerCase << ", ";
      out << udc.TitleCase << " ";
      out << " }";

      i++;

      if (i != data.end())
	out << ",";
      out << "\n";
    }
  out << "};" << endl;
}

void setIntValueIfExists(const string& value, int& num, int def=-1)
{
  if (value.length() == 0)
    num = def;
  else
    {
      num = strtol(value.c_str(), NULL, 16);
    }
}

void build(char* filename, ostream& outcpp, ostream& outh)
{
  ifstream in(filename, ios::in);

  char buffer[1024];
  string slots[15];

  list<UnicodeDataChar> Data;

  UnicodeDataChar curdata;

  while (in.getline(buffer, 1024))
    {
      tokenizeLine(slots, buffer);

      setIntValueIfExists(slots[0], curdata.Code);

      curdata.Name = slots[1].c_str();

      bool foundcat = false;
      for (unsigned int i=0; !foundcat; i++)
	{
	  if (catmapping[i].val == 0)
	    {
	      for (unsigned j=0; !foundcat; j++)
		{
		  if (catmapping[j].val == 0)
		    foundcat = true;
		  else if (slots[2][0] == catmapping[j].val[0])
		    {
		      foundcat = true;
		      curdata.Category = catmapping[j].cat;
		      curdata.Subcategory = UNICODE_UNKOWN_SUBCATEGORY;
		    }
		}
	      
	      foundcat = true;
	      curdata.Category = UNICODE_UNKOWN_CATEGORY;
	      curdata.Subcategory = UNICODE_UNKOWN_SUBCATEGORY;
	    }
	  else if (slots[2] == catmapping[i].val)
	    {
	      foundcat = true;
	      curdata.Category = catmapping[i].cat;
	      curdata.Subcategory = catmapping[i].subcat;
	    }
	}

      setIntValueIfExists(slots[3], curdata.CombiningClasses);

      foundcat = false;
      for (unsigned int i=0; !foundcat; i++)
	{
	  if (bidimapping[i].val == 0)
	    {
	      foundcat = true,
		curdata.Bidi = UNICODE_BIDI_UNKNOWN;
	    }
	  else if (slots[5] == bidimapping[i].val)
	    {
	      foundcat = true;
	      curdata.Bidi = bidimapping[i].cat;
	    }
	}

      foundcat = false;

      if (slots[5].length() == 0)
	{
	  curdata.DecompCategory = UNICODE_DECOMP_NONE;
	}
      else
	{
	  string decompcat;
	  string decompvals;
	  unsigned int pos = slots[5].find(' ');
	  if (pos == slots[5].npos)
	    decompcat = slots[5];
	  else if (slots[5][0] == '<')
	    {
	      decompcat = slots[5].substr(0, pos);
	      decompvals = slots[5].substr(pos+1);
	    }
	  else 
	    {
	      decompcat = "";
	      decompvals = slots[5];
	    }
	  
	  curdata.DecompValues = decompvals;
      
	  for (unsigned int i=0; !foundcat; i++)
	    {
	      if (decompmapping[i].val == 0)
		{
		  foundcat = true;
		  curdata.DecompCategory = UNICODE_DECOMP_CANONICAL;
		}
	      else if (decompcat == decompmapping[i].val)
		{
		  foundcat = true;
		  curdata.DecompCategory = decompmapping[i].cat;
		}
	    }
	}

      setIntValueIfExists(slots[6], curdata.DecimalValue);
      setIntValueIfExists(slots[7], curdata.DigitValue);
      setIntValueIfExists(slots[8], curdata.NumericValue);

      if ((slots[9] == "y") || (slots[9] == "Y"))
	curdata.Mirrored = true;
      else
	curdata.Mirrored = false;

      setIntValueIfExists(slots[12], curdata.UpperCase);
      setIntValueIfExists(slots[13], curdata.LowerCase);
      setIntValueIfExists(slots[14], curdata.TitleCase);


      Data.push_back(curdata);
    }

  writeOutput2(Data, outcpp, outh);
  
}

int main(int argc, char** argv)
{
  if (argc != 2)
    cerr << "Usage: " << argv[0] << " <unicodedata.txt>" << endl;

  ofstream outcpp("unicodedata-gen.cc");
  ofstream outh("unicodedata-gen.h");
  build(argv[1], outcpp, outh);
}
