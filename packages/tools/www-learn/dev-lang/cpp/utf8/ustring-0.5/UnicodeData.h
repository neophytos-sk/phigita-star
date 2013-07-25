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

#ifndef _UNICODEDATA_H_
#define _UNICODEDATA_H_

#include <string>
#include <map>
#include <list>
#include "WStringTypes.h"
#include <vector>
#include "unicodedata-gen.h"

namespace ustring {

  class UnknownUnicodeChar
    {
    };

  class UnicodeDataBase
    {
      map<WChar, unsigned int> m_charIndex;
      map<int,int> m_firstMap;
      static UnicodeDataBase* m_singleton;
    

    private:
  
      UnicodeDataBase();
      UnicodeDataBase(UnicodeDataBase& udb);  
      UnicodeDataBase& operator=(const UnicodeDataBase& udb);

      int getInternalIndex(const WChar& wc) throw(UnknownUnicodeChar);
      int consumeRecompositionList(list<WChar>& seq, list<WChar>::iterator& cur, int start);


    public:

      static UnicodeDataBase& getInstance();
      void init();

      int findRecompositionElement(int slot, WChar wc);

      /// sort combining classes between starters
      void sortCombiningClasses(list<WChar>& lst);
  

      /**
	 Chars informations
      */
      WChar getUpperCase(const WChar& wc) throw(UnknownUnicodeChar);
      WChar getLowerCase(const WChar& wc) throw(UnknownUnicodeChar);
      WChar getTitleCase(const WChar& wc) throw(UnknownUnicodeChar);

      UnicodeCategory getCategory(const WChar& wc) throw(UnknownUnicodeChar);
      UnicodeSubCategory getSubCategory(const WChar& wc) throw(UnknownUnicodeChar);

      UnicodeDecompositionCategory getDecompositionCategory(const WChar& wc) throw(UnknownUnicodeChar);
      void getDecompositionValues(const WChar& wc, list<WChar>& values) throw(UnknownUnicodeChar);

      string getName(const WChar& wc) throw(UnknownUnicodeChar);

      int getDecimalValue(const WChar& wc) throw(UnknownUnicodeChar);
      int getDigitValue(const WChar& wc) throw(UnknownUnicodeChar);
      int getNumericValue(const WChar& wc) throw(UnknownUnicodeChar);

      int getCombiningClass(const WChar& wc) throw(UnknownUnicodeChar);

      bool getMirrored(const WChar& wc) throw(UnknownUnicodeChar);

      bool isAssigned(const WChar& wc);

      /**
	 sequence processings
      */
      
      void canonicalComposition(list<WChar> lst, list<WChar>& result);

      /**
	 Recursive canonical decomposition
      */

      template<class Iterator> void canonicalDecomposition(Iterator first, Iterator last, list<WChar>& out)
	{
	  list<WChar> decomps;
	  for (; first != last; ++first)
	    {
	      WChar c = *first;
	      if (c != 0)
		{
		  if (getDecompositionCategory(c) == UNICODE_DECOMP_CANONICAL)
		    {
		      getDecompositionValues(c, decomps);
		      canonicalDecomposition(decomps.begin(), decomps.end(), out);
		    }
		  else
		    {
		      out.push_back(c);
		    }
		}
	    }
	}


      /**
	 Recursive canonical decomposition
       */
      template<class Iterator> void compatibilityDecomposition(Iterator first, Iterator last, list<WChar>& out)
	{
	  list<WChar> decomps;
	  for (; first != last; ++first)
	    {
	      WChar c = *first;
	      if (c != 0)
		{
		  if (getDecompositionCategory(c) != UNICODE_DECOMP_NONE)
		    {
		      getDecompositionValues(c, decomps);
		      if (decomps.size() != 0)
			compatibilityDecomposition(decomps.begin(), decomps.end(), out);
		      else
			out.push_back(c);
		    }
		  else
		    {
		      out.push_back(c);
		    }
		}
	    }
	}


      template<class Iterator> void upperCase(Iterator first, Iterator last, list<WChar>& out)
	{
	  for (; first != last; ++first)
	    {
	      try {
		out.push_back(getUpperCase(*first));
	      }	catch (...)
		{
		  out.push_back(*first);
		}
	    }
	}  

      template<class Iterator> void lowerCase(Iterator first, Iterator last, list<WChar>& out) 
	{
	  for (; first != last; ++first)
	    {
	      try {
		out.push_back(getLowerCase(*first));
	      }	catch (...)
		{
		  out.push_back(*first);
		}
	    }
	}  

      template<class Iterator> void titleCase(Iterator first, Iterator last, list<WChar>& out)
	{
	  for (; first != last; ++first)
	    {
	      try {
		out.push_back(getLowerCase(*first));
	      }	catch (...)
		{
		  out.push_back(*first);
		}
	    }
	}  



    };

}

#endif


