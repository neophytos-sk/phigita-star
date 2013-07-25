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

namespace ustring {

  /**
     The WSData members
  */

  WSData::WSData(const list<WChar>& data)
  {
    References = 0;
    Data = 0;
    allocate(data.size());
    list<WChar>::const_iterator lit = data.begin();
    for (int i=0; i<Length; ++i, ++lit)
      {
	Data[i] = HOSTTOINTERNAL(*lit);
      }
  }

  WSData::WSData(const WSData& data)
  {
    References = 0;
    Length = data.Length;
    Data = new WChar[Length];
    for (int i=0; i<Length; i++)
      {
	Data[i] = data.Data[i];
      }
  }

  WSData::WSData()
  {
    References = 0;
    Length = 0;
    Data = 0;
  }

  WSData::~WSData()
  {
    //      cerr << "delete WSData " << this << endl;
    delete[] Data;
  }

  WSData& WSData::operator=(const WSData& data)
  {
    References = 0;
    Data = 0;
    allocate(data.Length);

    References = 0;
    allocate(data.Length);
    WChar* in = &data.Data[0];
    WChar* out = &Data[0];
    for (int i=0; i<Length; ++i)
      {
	*out++ = *in++;
      }
    return *this;
  }

  WSData& WSData::operator+=(const WSData& data)
  {
    if ((Data == 0) || (Length == 0))
      return operator=(data);

    int totalLength = Length + data.Length;
    WChar* result = new WChar[totalLength];
    WChar* writer = &result[0];
    WChar* reader = &Data[0];
    int loopi = 0;
    for (; loopi<Length; loopi++)
      {
	*writer++ = *reader++;
      }
    reader = &data.Data[0];
    for (; loopi<totalLength; loopi++)
      {
	*writer++ = *reader++;
      }
    
    delete[] Data;
    Length = totalLength;
    Data = result;

    return *this;
  }

  void WSData::allocate(int size)
  {
    delete[] Data;

    Length = size;
    Data = new WChar[size];
  }

  void WSData::clear()
  {
    References = 0;
    Length = 0;
    delete[] Data;
    Data = 0;
  }

  void WSData::clearData()
  {
    Length = 0;
    delete[] Data;
    Data = 0;
  }

  string WSData::toString()
  {
    string result = "";
    result += "{";
    char buffer[128];
    for (int i=0; i<Length; i++)
      {
	sprintf(buffer,"%04x", INTERNALTOHOST(Data[i]));
	result += buffer;
	if ((i+1) < Length)
	  result += ", ";
      }
    result += "}";
    return result;
  }


  /**
     WCharProxy members
  */


  WString::WCharProxy::WCharProxy(const WString&wstr, int index) : m_wstr(wstr), m_index(index) { }
  WString::WCharProxy::WCharProxy(const WCharProxy&data) : m_wstr(data.m_wstr), m_index(data.m_index) { }
	  
  WString::WCharProxy& WString::WCharProxy::operator=(const WChar& wc)
  {
    m_wstr.forkData();
    m_wstr.m_sdata->Data[m_index] = HOSTTOINTERNAL(wc);
    return *this;
  }
  WString::WCharProxy& WString::WCharProxy::operator=(const WCharProxy& dp)
  {
    m_wstr.forkData();
    m_wstr.m_sdata->Data[m_index] = HOSTTOINTERNAL(dp.m_wstr.getAt(dp.m_index));
    return *this;
  }
  WString::WCharProxy::operator WChar() const
  {
    return m_wstr.getAt(m_index);
  }

  bool WString::WCharProxy::operator==(const WCharProxy& prox) const
  {
    return m_wstr.getAt(m_index) == prox.m_wstr.getAt(prox.m_index);
  }
  bool WString::WCharProxy::operator==(const WChar& wc) const
  {
    return m_wstr.getAt(m_index) == wc;
  }

  bool WString::WCharProxy::operator!=(const WCharProxy& prox) const
  {
    return m_wstr.getAt(m_index) != prox.m_wstr.getAt(prox.m_index);
  }
  bool WString::WCharProxy::operator!=(const WChar& wc) const
  {
    return m_wstr.getAt(m_index) != wc;
  }

  bool WString::WCharProxy::operator<(const WCharProxy& prox) const
  {
    return m_wstr.getAt(m_index) < prox.m_wstr.getAt(prox.m_index);
  }
  bool WString::WCharProxy::operator<(const WChar& wc) const
  {
    return m_wstr.getAt(m_index) < wc;
  }

  bool WString::WCharProxy::operator>(const WCharProxy& prox) const
  {
    return m_wstr.getAt(m_index) > prox.m_wstr.getAt(prox.m_index);
  }
  bool WString::WCharProxy::operator>(const WChar& wc) const
  {
    return m_wstr.getAt(m_index) > wc;
  }

  /**
     The const_iterator members
  */

  WString::const_iterator& WString::const_iterator::operator=(const const_iterator& iter)
  {
    m_wstr = iter.m_wstr;
    m_index = iter.m_index;
    return *this;
  }
  
  WString::const_iterator WString::const_iterator::operator+(int offset)
  {
    const_iterator resit(*this);
    resit.m_index += offset;
    return resit;
  }
  
  WString::const_iterator WString::const_iterator::operator-(int offset)
  {
    const_iterator resit(*this);
    resit.m_index -= offset;
    return resit;
  }

  bool WString::const_iterator::operator==(const const_iterator& iter) const
  {
    return ( ((m_wstr)==((iter.m_wstr))) && (m_index == iter.m_index) );
  }
  bool WString::const_iterator::operator!=(const const_iterator& iter) const
  {
    return !( ((m_wstr)==((iter.m_wstr))) && (m_index == iter.m_index) );
  }

  WString::const_iterator& WString::const_iterator::operator++()
  {
    m_index++;
    return *this;
  }

  WString::const_iterator& WString::const_iterator::operator++(int)
  {
    m_index++;
    return *this;
  }

  WString::const_iterator& WString::const_iterator::operator--()
  {
    m_index--;
    return *this;
  }

  WString::const_iterator& WString::const_iterator::operator--(int)
  {
    m_index--;
    return *this;
  }

  WString::const_iterator& WString::const_iterator::operator+=(int i) 
  {
    m_index+=i;
    return *this; 
  }

  WString::const_iterator& WString::const_iterator::operator-=(int i)
  {
    m_index-=i;
    return *this; 
  }

  const WString::WCharProxy WString::const_iterator::operator[](int i)
  {
    return WCharProxy(*m_wstr, m_index+i);
  }
	  
  const WString::WCharProxy WString::const_iterator::operator*()
  {
    return WCharProxy(*m_wstr,m_index);
  }


  /**
     the iterator members
  */

  WString::iterator WString::iterator::operator+(int offset)
  {
    iterator resit(*this);
    resit.m_index += offset;
    return resit;
  }

  WString::iterator WString::iterator::operator-(int offset)
  {
    iterator resit(*this);
    resit.m_index -= offset;
    return resit;
  }

  WString::iterator& WString::iterator::operator++()
  {
    m_index++;
    return *this;
  }
  WString::iterator& WString::iterator::operator++(int)
  {
    return operator++();
  }

  WString::iterator& WString::iterator::operator--()
  {
    m_index--;
    return *this;
  }

  WString::iterator& WString::iterator::operator--(int)
  {
    return operator--();
  }

  WString::iterator& WString::iterator::operator+=(int i) 
  {
    m_index+=i;
    return *this; 
  }

  WString::iterator& WString::iterator::operator-=(int i) 
  {
    m_index-=i;
    return *this; 
  }

  WString::WCharProxy WString::iterator::operator[](int i)
  {
    return WCharProxy(*m_wstr, m_index+i);
  }
	  
  WString::WCharProxy WString::iterator::operator*()
  {
    return WCharProxy(*m_wstr,m_index);
  }


  /**
     The WString members
  */


  void WString::convert(WSData& fillit, const char* encoding, const char* data) const throw(UnknownCharsetException, CharsetConversionException, WStringException)
{
  fillit.clearData();

  iconv_t enc = iconv_open(WSTRING_INTERNAL_CHARSET, encoding);
  if (enc == (iconv_t)-1)
    throw UnknownCharsetException();

  fillit.allocate(strlen(data));

  char* outpconv = (char*)fillit.Data;
  size_t length = fillit.Length * sizeof(WChar);

  size_t datalength = strlen(data);

  size_t res = iconv(enc, &data, &datalength, &outpconv, &length);

  cerr << "WString datalength = " << datalength << endl;
      
  if (res == (size_t)-1)
    {
      iconv_close(enc);
      fillit.clear();
	  
      if (errno == EINVAL)
	throw CharsetConversionException();

      throw WStringException();
    }

  if (datalength != 0) // SHOULD *NEVER* BE TRUE !
    {
      WSData moreData;
      moreData.allocate(fillit.Length * sizeof(WChar));

      while (datalength != 0)
	{
	  outpconv = (char*)moreData.Data;
	  length = fillit.Length * sizeof(WChar);
	    
	  res = iconv(enc, &data, &datalength, &outpconv, &length);

	  if (res == (size_t)-1)
	    {
	      iconv_close(enc);
	      fillit.clear();
	  
	      if (errno == EINVAL)
		throw CharsetConversionException();

	      throw WStringException();
	    }
	  moreData.Length = (fillit.Length * sizeof(WChar)) - length;
	  fillit += moreData;
	}

      fillit = moreData;
    }
      
  iconv_close(enc); 

}

  void WString::forkData() const // const, as it changes nothing from
    // the point of view of the user.
  {
    if (m_sdata->References > 1)
      {
	WString& mutablewstr = const_cast<WString&>(*this);
	WSData*old = mutablewstr.m_sdata;
	mutablewstr.m_sdata = new WSData(*old);
	mutablewstr.m_sdata->References = 1;
	old->References--;
      }
  }

  WString::WString(WSData* data)
  {
    m_sdata = data;
    m_sdata->References += 1;
  }

  WString::WString()
  {
    m_sdata = new WSData();
    m_sdata->References += 1;
  }

  WString::WString(const WString& wstr)
  {
    m_sdata = wstr.m_sdata;
    m_sdata->References += 1;
  }
  
  WString::WString(const char* encoding, const char* data) throw(UnknownCharsetException, CharsetConversionException, WStringException)
  {
    m_sdata = new WSData();
    convert(*m_sdata, encoding, data);
    m_sdata->References++;
  }

  WString::WString(const string& encoding, const string& data) throw(UnknownCharsetException, CharsetConversionException, WStringException)
  {
    m_sdata = new WSData();
    convert(*m_sdata, encoding.c_str(), data.c_str());
    m_sdata->References++;
  }

  WString::WString(const list<WChar>& data)
  {
    m_sdata = new WSData(data);
    m_sdata->References++;
  }

  WString::~WString()
  {
    m_sdata->References--;
    if (m_sdata->References == 0)
      delete m_sdata;
  }

  const WString& WString::operator=(const WString& wstr)
  {
    if (&wstr == this)
      return wstr;

    m_sdata->References--;
    if (m_sdata->References == 0)
      delete m_sdata;

    m_sdata = wstr.m_sdata;
    m_sdata->References++;
    return *this;
  }

  string WString::debugString()
  {
    return m_sdata->toString();
  }

  string WString::toString(const string& encoding) const throw(CharsetConversionException)
  {
    string result;
    if (m_sdata->Length == 0)
      return result;

    int BUFLEN = m_sdata->Length+1;
    if (BUFLEN<32)
      BUFLEN = 32;

    iconv_t enc = iconv_open(encoding.c_str(), WSTRING_INTERNAL_CHARSET);
      
    char* orgbuffer = new char[BUFLEN+1];
    char* buffer = orgbuffer;
    buffer[BUFLEN] = '\0';
    size_t bufferlen = BUFLEN;
    const char* wsc = (char*)m_sdata->Data;
    size_t wsclen = (m_sdata->Length * sizeof(WChar));

    do {
	
      int res = iconv(enc, &wsc, &wsclen, &buffer, &bufferlen);

      if (res < 0)
	{
	  if (errno == E2BIG)
	    {
	      orgbuffer[BUFLEN-bufferlen] = 0;
	      result += orgbuffer;
	      buffer = orgbuffer;
	      bufferlen = BUFLEN;
	    }
	  else 
	    {
	      if (errno == EILSEQ)
		cerr << "EILSEQ" << endl;
	      else if (errno == EINVAL)
		cerr << "EINVAL" << endl;
	      else if (errno == EBADF)
		cerr << "EBADF" << endl;

	      delete[] orgbuffer;
	      iconv_close(enc);

	      throw CharsetConversionException();
	    }
	}
      else
	{
	  if (bufferlen>0)
	    *buffer = 0;

	  result += orgbuffer;
	}

    } while (wsclen > 0);

    delete[] orgbuffer;
    iconv_close(enc);

    return result;
  }

  WString WString::operator+(const WString& str) const
  {
    WString result;
    WSData& data = *(result.m_sdata);
      
    data.allocate(m_sdata->Length + str.m_sdata->Length);

    for (int i=0; i<m_sdata->Length; i++)
      {
	data.Data[i] = m_sdata->Data[i];
      }

    for (int i=m_sdata->Length, j=0; j<str.m_sdata->Length; i++,j++)
      {
	data.Data[i] = str.m_sdata->Data[j];
      }

    return result;
  }

  bool WString::operator==(const WString& wstr) const
  {
    if (wstr.m_sdata == m_sdata)
      return true;

    if (wstr.m_sdata->Length != m_sdata->Length)
      return false;

    for (int i=0; i<m_sdata->Length; i++)
      {
	if (m_sdata->Data[i] != wstr.m_sdata->Data[i])
	  return false;
      }

    return true;
  }

  bool WString::operator<(const WString& wstr) const
  {
    bool lssmaller = (m_sdata->Length < wstr.m_sdata->Length);
    int max = lssmaller?m_sdata->Length:wstr.m_sdata->Length;

    for (int i=0; i<max; i++)
      {
	WChar ls = getAt(i); 
	WChar rs = wstr.getAt(i);
	if (ls < rs)
	  return true;
	else if (ls > rs)
	  return false;
      }
    return lssmaller;      
  }

  bool WString::equalsIgnoreMarks(const WString& other) const
  {
    int curidx = 0;
    int otheridx = 0;
    int curmax = length();
    int othermax = other.length();

    UnicodeDataBase &database = UnicodeDataBase::getInstance();

    while ((curidx<curmax) && (database.getCategory(getAt(curidx)) == UNICODE_MARK))
      ++curidx;

    while ((otheridx<othermax) && (database.getCategory(other.getAt(otheridx)) == UNICODE_MARK))
      ++otheridx;

    while ((curidx<curmax)&&(otheridx<othermax))
      {
	if (other.getAt(otheridx) != getAt(curidx))
	  return false;

	++curidx;
	++otheridx;

	while ((curidx<curmax) && (database.getCategory(getAt(curidx)) == UNICODE_MARK))
	  ++curidx;

	while ((otheridx<othermax) && (database.getCategory(other.getAt(otheridx)) == UNICODE_MARK))
	  ++otheridx;
      }

    if (otheridx < othermax)
      return false;

    if (curidx < curmax)
      return false;

    return true;
  }

  WString WString::getUpperCase() const
  {
    list<WChar> fdata;
    UnicodeDataBase::getInstance().upperCase(begin(), end(), fdata);
    WSData* data = new WSData(fdata);
    return WString(data);
  }

  WString WString::getLowerCase() const
  {
    list<WChar> fdata;
    UnicodeDataBase::getInstance().lowerCase(begin(), end(), fdata);
    WSData* data = new WSData(fdata);
    return WString(data);
  }

  WString WString::getCanonicalDecomposition() const
  {
    list<WChar> fdata;

    UnicodeDataBase::getInstance().canonicalDecomposition(begin(), end(), fdata);

    WSData* data = new WSData(fdata);
    return WString(data);
  }

  WString WString::getCompatibilityDecomposition() const
  {
    list<WChar> fdata;

    UnicodeDataBase::getInstance().compatibilityDecomposition(begin(), end(), fdata);

    WSData* data = new WSData(fdata);
    return WString(data);
  }

  WString WString::getCanonicalComposition() const
  {
    list<WChar> in;
    getData(in);
    list<WChar> fdata;

    UnicodeDataBase::getInstance().canonicalComposition(in, fdata);

    WSData* data = new WSData(fdata);
    return WString(data);
  }

  WString WString::getNormalizationFormC() const
  {
    list<WChar> fdata;
    UnicodeDataBase& db = UnicodeDataBase::getInstance();

    db.canonicalDecomposition(begin(), end(), fdata);
    list<WChar> res;
    db.canonicalComposition(fdata, res);

    WSData* data = new WSData(res);
    return WString(data);
  }
  
  WString WString::getNormalizationFormD() const
  {
    list<WChar> fdata;
    UnicodeDataBase& db = UnicodeDataBase::getInstance();

    db.canonicalDecomposition(begin(), end(), fdata);

    WSData* data = new WSData(fdata);
    return WString(data);
  }
  
  WString WString::getNormalizationFormKC() const
  {
    list<WChar> fdata;
    UnicodeDataBase& db = UnicodeDataBase::getInstance();

    db.compatibilityDecomposition(begin(), end(), fdata);
    list<WChar> res;
    db.canonicalComposition(fdata, res);

    WSData* data = new WSData(res);
    return WString(data);    
  }

  WString WString::getNormalizationFormKD() const
  {
    list<WChar> fdata;
    UnicodeDataBase& db = UnicodeDataBase::getInstance();

    db.compatibilityDecomposition(begin(), end(), fdata);

    WSData* data = new WSData(fdata);
    return WString(data);
  }

  WString WString::getCanonicalDecompositionNoMark() const
  {
    list<WChar> in;
    getData(in);
    list<WChar> fdata;

    UnicodeDataBase& db = UnicodeDataBase::getInstance();

    db.canonicalDecomposition(begin(), end(), fdata);

    for (list<WChar>::iterator i = fdata.begin(); i != fdata.end(); )
      {
	if (db.getCategory(*i) == UNICODE_MARK)
	  {
	    list<WChar>::iterator rem = i;
	    ++i;
	    fdata.erase(rem);
	  }
	else
	  ++i;
      }

    WSData* data = new WSData(fdata);
    return WString(data);    
  }

  WString WString::reverse() const
  {
    list<WChar> fdata;
    for (WString::const_iterator i=begin(); i!=end(); i++)
      {
	fdata.push_front(*i);
      }
    WSData* data = new WSData(fdata);
    return WString(data);    
  }


}
