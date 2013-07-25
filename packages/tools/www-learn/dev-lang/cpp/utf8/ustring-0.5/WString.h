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

#ifndef _WSTRING_H_
#define _WSTRING_H_

#include <stdio.h>
#include <vector>
#include <iconv.h>
#include <string>
#include <errno.h>

#include <netinet/in.h>
#include <list>
#include "UnicodeData.h"
#include "WStringTypes.h"

namespace ustring {

  class WStringException { };
  class UnknownCharsetException : public WStringException { };
  class CharsetConversionException : public WStringException { };

  /**
     WSData objets are used as the internal reference-counted
     representation of the data.
  */

  class WSData
    {
    public:
      int References;
      int Length;
      WChar* Data;

    public:

      WSData(const list<WChar>& data);
      WSData(const WSData& data);
      WSData();
      ~WSData();

      WSData& operator=(const WSData& data);
      WSData& operator+=(const WSData& data);

      void allocate(int size);
      void clear();
      void clearData();

      string toString();
    };


  /**
     This is the wide-char string class. The data are shared using
     reference-count, so that passing WString objects by values be as
     fast as possible.

     It is designed to be stl-compatible, with iterators and
     cons_iterator available, 

  */
  class WString
    {
      WSData* m_sdata;

      /// Converts the given `data' encoded using the `encoding'
      /// charset, filling the WSData object given as first argument.
      void convert(WSData& fillit, const char* encoding, const char* data) const 
	throw(UnknownCharsetException, CharsetConversionException, WStringException);

      /// Fork the WSData object : if the object is shared (more than
      /// 1 object has a reference on it), copies it, and makes the
      /// current WString object use this copy.
      void forkData() const;


      WString(WSData* data);

    public:

      /**
	 The WCharProxy is used as a replacement for WChar object
	 references. It has many advantages over a simple WChar
	 objects. Please read Scott Meyers' "More Effective C++" for a
	 compare&constrast of the technique.
      */
      class WCharProxy
	{
	  const WString& m_wstr;
	  int m_index;
	public:
	  WCharProxy(const WString&wstr, int index);
	  WCharProxy(const WCharProxy&data);
	  
	  WCharProxy& operator=(const WChar& wc);
	  WCharProxy& operator=(const WCharProxy& dp);
	  operator WChar() const;
	  bool operator==(const WCharProxy& prox) const;
	  bool operator==(const WChar& wc) const;
	  bool operator!=(const WCharProxy& prox) const;
	  bool operator!=(const WChar& wc) const;
	  bool operator<(const WCharProxy& prox) const;
	  bool operator<(const WChar& wc) const;
	  bool operator>(const WCharProxy& prox) const;
	  bool operator>(const WChar& wc) const;
	};
      friend class WCharProxy;
      

      /**
	 This iterator and const_iterator work as any other
	 random-access STL iterators.
      */

      class const_iterator
	{
	protected:
	  const WString* m_wstr;
	  int m_index;

	public:
	  const_iterator(const WString* wstr, int index=0) : m_wstr(wstr), m_index(index) { };
	  const_iterator(const const_iterator& iter) : m_wstr(iter.m_wstr), m_index(iter.m_index) { };
	  const_iterator() : m_wstr(0), m_index(0) { };

	  const_iterator& operator=(const const_iterator& iter);

	  const_iterator operator+(int offset);
	  const_iterator operator-(int offset);

	  bool operator==(const const_iterator& iter) const;
	  bool operator!=(const const_iterator& iter) const;

	  const_iterator& operator++();
	  const_iterator& operator++(int);

	  const_iterator& operator--();
	  const_iterator& operator--(int);

	  const_iterator& operator+=(int i);
	  const_iterator& operator-=(int i);

	  const WCharProxy operator[](int i);
	  const WCharProxy operator*();
	};


      class iterator : public const_iterator
	{
	public:
	  iterator(const WString* wstr, int index=0) : const_iterator(wstr,index) { };
	  iterator(const iterator& iter) : const_iterator(iter.m_wstr, iter.m_index) { };
	  iterator() : const_iterator() { };

	  iterator operator+(int offset);
	  iterator operator-(int offset);

	  iterator& operator++();
	  iterator& operator++(int);

	  iterator& operator--();
	  iterator& operator--(int);

	  iterator& operator+=(int i);
	  iterator& operator-=(int i);

	  WCharProxy operator[](int i);
	  WCharProxy operator*();
	};

    public:

      WString();
      WString(const WString& wstr);
      WString(const char* encoding, const char* data) 
	throw(UnknownCharsetException, CharsetConversionException, WStringException);
      WString(const string& encoding, const string& data) 
	throw(UnknownCharsetException, CharsetConversionException, WStringException);

      WString(const list<WChar>& data);
  
      ~WString();

      string debugString();
      string toString(const string& encoding) const throw(CharsetConversionException);

      const WString& operator=(const WString& wstr);
      WString operator+(const WString& str) const;
      bool operator==(const WString& wstr) const;
      bool operator<(const WString& wstr) const;
      inline bool operator>(const WString& wstr) const { return operator<(wstr)?false:true; }

      inline int length() const	{  return m_sdata->Length; }
      inline int size() const { return m_sdata->Length;	}

      inline void setAt(int index, WChar c) { forkData(); m_sdata->Data[index] = HOSTTOINTERNAL(c); }
      inline WChar getAt(int index) const { return INTERNALTOHOST(m_sdata->Data[index]); }
      inline WChar operator[](int i) const { return INTERNALTOHOST(m_sdata->Data[i]); }

      bool equalsIgnoreMarks(const WString& other) const;

      WString getUpperCase() const;
      WString getLowerCase() const;
      WString getCanonicalDecomposition() const;
      WString getCompatibilityDecomposition() const;
      WString getCanonicalComposition() const;

      WString getNormalizationFormC() const;
      WString getNormalizationFormD() const;
      WString getNormalizationFormKC() const;
      WString getNormalizationFormKD() const;

      WString getCanonicalDecompositionNoMark() const;

      WString reverse() const;

      list<WChar> getData() const
	{
	  list<WChar> result;
	  for (int i=0; i<m_sdata->Length; i++)
	    {
	      result.push_back(INTERNALTOHOST(m_sdata->Data[i]));
	    }
	  return result;
	}

      void getData(list<WChar>& result ) const
	{
	  result.erase(result.begin(), result.end());
	  for (int i=0; i<m_sdata->Length; i++)
	    {
	      result.push_back(INTERNALTOHOST(m_sdata->Data[i]));
	    }
	}


      const_iterator begin() const { return const_iterator(this, 0); }
      const_iterator end()   const { return const_iterator(this, length()); }
      iterator       begin()       { return iterator(this, 0); }
      iterator       end()         { return iterator(this, length()); }
   
    private:



    };

}

#endif
