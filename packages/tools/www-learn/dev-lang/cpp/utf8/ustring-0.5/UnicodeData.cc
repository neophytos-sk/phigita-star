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

#include "UnicodeData.h"
#include "unicodedata-gen.h"

namespace ustring {

  UnicodeDataBase* UnicodeDataBase::m_singleton = 0;
  
  UnicodeDataBase::UnicodeDataBase()
  {  
    init();
  }
  
  UnicodeDataBase::UnicodeDataBase(UnicodeDataBase& udb)
  { 
    throw string(); // private, can't get there 
  }
  
  UnicodeDataBase& UnicodeDataBase::operator=(const UnicodeDataBase& udb)
  {
    throw string(); // private, can't get there 
  }

  int UnicodeDataBase::getInternalIndex(const WChar& wc) throw(UnknownUnicodeChar)
  {
    map<WChar, unsigned int>::iterator idxfound = m_charIndex.find(wc);

    if (idxfound == m_charIndex.end())
      throw UnknownUnicodeChar();
      
    int index = idxfound->second;
    if (index < 0)
      throw UnknownUnicodeChar();

    return index;
  }

  UnicodeDataBase& UnicodeDataBase::getInstance()
  {
    if (m_singleton == 0)
      {
	m_singleton = new UnicodeDataBase();
      }

    return *m_singleton;
  }

  void UnicodeDataBase::init()
  {
    for (int i=0; i<unicodeDataBase_Size; i++)
      {
	WChar wc = unicodeDataBase_Code[i];
	m_charIndex[wc] = i;
      }

    int next = unicodeDataBase_CompositionDAG[0] + 1;
    int count = unicodeDataBase_CompositionDAG[next];
    int idx = next+1;
    for (int i=0; i<count; i++)
      {
	int key = unicodeDataBase_CompositionDAG[idx++];
	int val = unicodeDataBase_CompositionDAG[idx++];
	m_firstMap[key] = val;
      }
  }

  WChar UnicodeDataBase::getUpperCase(const WChar& wc) throw(UnknownUnicodeChar)
  {
    int result = unicodeDataBase_UpperCase[getInternalIndex(wc)];

    if (result == -1)
      throw UnknownUnicodeChar();

    return result;
  }

  WChar UnicodeDataBase::getLowerCase(const WChar& wc) throw(UnknownUnicodeChar)
  {
    int result = unicodeDataBase_LowerCase[getInternalIndex(wc)];

    if (result == -1)
      throw UnknownUnicodeChar();

    return result;
  }


  WChar UnicodeDataBase::getTitleCase(const WChar& wc) throw(UnknownUnicodeChar)
  {
    int result = unicodeDataBase_TitleCase[getInternalIndex(wc)];

    if (result == -1)
      throw UnknownUnicodeChar();

    return result;
  }

  UnicodeCategory UnicodeDataBase::getCategory(const WChar& wc) throw(UnknownUnicodeChar)
  {
    return unicodeDataBase_Category[getInternalIndex(wc)];
  }

  UnicodeSubCategory UnicodeDataBase::getSubCategory(const WChar& wc) throw(UnknownUnicodeChar)
  {
    return unicodeDataBase_SubCategory[getInternalIndex(wc)];
  }

  UnicodeDecompositionCategory UnicodeDataBase::getDecompositionCategory(const WChar& wc) throw(UnknownUnicodeChar)
  {
    return unicodeDataBase_DecompCategory[getInternalIndex(wc)];
  }

  void UnicodeDataBase::getDecompositionValues(const WChar& wc, list<WChar>& values) throw(UnknownUnicodeChar)
  {
    values.erase(values.begin(), values.end());

    int index = getInternalIndex(wc);
    int decompindex = unicodeDataBase_DecompValuesIndex[index];
    int count = unicodeDataBase_DecompValues[decompindex];

    for (int i=0; i<count; i++)
      {
	values.push_back(unicodeDataBase_DecompValues[decompindex+1+i]);
      }
  }

  string UnicodeDataBase::getName(const WChar& wc) throw(UnknownUnicodeChar)
  {
    return string(unicodeDataBase_Name[getInternalIndex(wc)]);
  }

  int UnicodeDataBase::getDecimalValue(const WChar& wc) throw(UnknownUnicodeChar)
  {
    return unicodeDataBase_DecimalValue[getInternalIndex(wc)];
  }

  int UnicodeDataBase::getDigitValue(const WChar& wc) throw(UnknownUnicodeChar)
  {
    return unicodeDataBase_DigitValue[getInternalIndex(wc)];
  }

  int UnicodeDataBase::getNumericValue(const WChar& wc) throw(UnknownUnicodeChar)
  {
    return unicodeDataBase_NumericValue[getInternalIndex(wc)];
  }

  bool UnicodeDataBase::getMirrored(const WChar& wc) throw(UnknownUnicodeChar)
  {
    return unicodeDataBase_Mirrored[getInternalIndex(wc)];
  }

  int UnicodeDataBase::getCombiningClass(const WChar& wc) throw(UnknownUnicodeChar)
  {
    return unicodeDataBase_CombiningClasses[getInternalIndex(wc)];
  }

  void UnicodeDataBase::canonicalComposition(list<WChar> lst, list<WChar>& result)
  {
    result.erase(result.begin(), result.end());

    while (lst.begin() != lst.end())
      {
	list<WChar>::iterator i = lst.begin();
	map<int,int>::iterator found = m_firstMap.find((int)*i);
	if (found != m_firstMap.end())
	  {
	    list<WChar>::iterator ni = i;
	    ++ni;
	    int res = consumeRecompositionList(lst, ni, found->second);

	    if (res == -1)
	      {
		result.push_back(*i);
		lst.erase(i);
	      }
	    else
	      {
		lst.erase(i);
		result.push_back(res);
	      }
	  }
	else
	  {
	    result.push_back(*i);
	    lst.erase(i);
	  }
      }
  }

  int UnicodeDataBase::findRecompositionElement(int slot, WChar wc)
  {
    int next = unicodeDataBase_CompositionDAG[slot] + slot + 1;
    int count = unicodeDataBase_CompositionDAG[next];
    int idx = next +1;
    for (int i=0; i<count; i++)
      {
	WChar cwc = (WChar) unicodeDataBase_CompositionDAG[idx++];
	int offset = unicodeDataBase_CompositionDAG[idx++];
	if (cwc == wc)
	  return offset;
      }
    return -1;
  }

  void UnicodeDataBase::sortCombiningClasses(list<WChar>& lst)
  {
    list<WChar>::iterator i = lst.begin();
    int lastCombiningClass = getCombiningClass(*i);
    list<WChar>::iterator lastStarter = i;
    ++i;
    for (; i!=lst.end(); )
      {
	int curcc = getCombiningClass(*i);

	if (curcc == 0)
	  ++i;
	else if (curcc < lastCombiningClass)
	  {
	    list<WChar>::iterator place = i;
	    --place;
	    while ((place != lastStarter) 
		   && (curcc < getCombiningClass(*place)))
	      --place;
		
	    if (place != lastStarter)
	      {
		lst.insert(place, *i);
	      }
	    else
	      {
		++place;
		lst.insert(place, *i);
	      }
	    list<WChar>::iterator torem = i;
	    ++i;
	    lst.erase(torem);

	  }
	else
	  ++i;

	lastCombiningClass = curcc;
      }
  }

  int UnicodeDataBase::consumeRecompositionList(list<WChar>& seq, list<WChar>::iterator& cur, int start)
  {
    int resultcount = unicodeDataBase_CompositionDAG[start];
    WChar wc = *cur;
	
    if (getCombiningClass(wc) != 0)
      {
	int findnext = findRecompositionElement(start, wc);
	if (findnext == -1)
	  {
	    list<WChar>::iterator i=cur;
	    ++i;
	    return consumeRecompositionList(seq, i, start);
	  }
	else
	  {
	    list<WChar>::iterator ni = cur;
	    ++ni;
	    int result = consumeRecompositionList(seq, ni, findnext);
	    if (result > 0)
	      {
		seq.erase(cur);
		return result;
	      }
	    else if ((result == -1) && (resultcount > 0))
	      {
		seq.erase(cur);
		return unicodeDataBase_CompositionDAG[resultcount+1];
	      }
	    else return -1;
	  }
      }
    else
      {
	if (resultcount > 0)
	  return unicodeDataBase_CompositionDAG[start + 1];
	return -1;
      }
  }

  bool UnicodeDataBase::isAssigned(const WChar& wc)
  {
    try {
      getInternalIndex(wc);
      return true;
    } catch (UnknownUnicodeChar uuc)
      {
	return false;
      }
  }

}




