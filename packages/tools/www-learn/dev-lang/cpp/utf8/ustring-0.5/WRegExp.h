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

#ifndef _WREGEXP_H_
#define _WREGEXP_H_

#include "WString.h"
#include <set>
#include <list>

namespace ustring {
  
  class WRegExp
    {

      class SingleWChar
	{
	  WChar m_char;
	public:
	  SingleWChar(WChar wc) : m_char(wc) { }
	  bool match(WChar wc)
	    {
	      return m_char == wc;
	    }
	  void print(ostream&out)
	    {
	      char buf[3];
	      sprintf(buf,"%c", (int)m_char);
	      out << m_char << " = " << buf << endl;
	    }
	};

      class UCharCategory
	{
	public:
	  typedef enum {
	    ALL, ASSIGNED, UNASSIGNED
	  } ExtendedCategory;

	  typedef enum {
	    CATONLY, CATSUBCAT, EXTENDED
	  } TYPE;

	private:
	  TYPE m_type;
	  UnicodeCategory m_cat;
	  UnicodeSubCategory m_subcat;
	  ExtendedCategory m_extcat;
	public:
	  UCharCategory() { }
	  UCharCategory(UnicodeCategory cat, UnicodeSubCategory subcat) : m_type(CATSUBCAT), m_cat(cat), m_subcat(subcat)
	    { }
	  UCharCategory(UnicodeCategory cat) : m_type(CATONLY), m_cat(cat)
	    { }
	  UCharCategory(ExtendedCategory ecat) : m_type(EXTENDED), m_extcat(ecat)
	    { }
	  UCharCategory(const UCharCategory& ucc) : m_type(ucc.m_type), m_cat(ucc.m_cat), m_subcat(ucc.m_subcat), m_extcat(ucc.m_extcat)
	    { }
	  bool match(WChar wc)
	    {
	      try {
	      switch(m_type)
		{
		case CATONLY:
		  {
		    UnicodeDataBase& db = UnicodeDataBase::getInstance();
		    return db.getCategory(wc) == m_cat;
		  }
		case CATSUBCAT:
		  {
		    UnicodeDataBase& db = UnicodeDataBase::getInstance();
		    return ((db.getCategory(wc) == m_cat) && (db.getSubCategory(wc) == m_subcat));
		  }
		case EXTENDED:
		  {
		    switch (m_extcat)
		      {
		      case ALL:
			  return true;
		      case ASSIGNED:
			{
			  UnicodeDataBase& db = UnicodeDataBase::getInstance();
			  return db.isAssigned(wc);
			}
		      case UNASSIGNED:
			{
			  UnicodeDataBase& db = UnicodeDataBase::getInstance();
			  return !(db.isAssigned(wc));
			}
		      }
		  }
		}
	      } catch (...)
		{
		}
	      return false;
	    }
	};

      class RangeWChar
	{
	  set<pair<WChar,WChar> > m_wcharrange;
	  set<int> m_typerange;
	  set<RangeWChar*> m_negrange;
	public:
	  void addRange(WChar begin, WChar end)
	    {
	      m_wcharrange.insert(make_pair(begin, end));
	    }
	  void addRange(int type)
	    {
	      m_typerange.insert(type);
	    }
	  void addNegativeRange(RangeWChar* neg)
	    {
	      m_negrange.insert(neg);
	    }
	  bool match(WChar wc)
	    {
	      bool found = false;
	      for(set<pair<WChar,WChar> >::iterator i=m_wcharrange.begin(); (i!=m_wcharrange.end()) && (!found); i++)
		{
		  if ((wc >= i->first) && (wc <= i->second))
		    found = true;
		}
	      // TODO: ALSO SHOULD CHECK TYPES RANGE
	      if (found == false)
		return false;
	      
	      for (set<RangeWChar*>::iterator i=m_negrange.begin(); i!=m_negrange.end(); i++)
		{
		  if ( (*i)->match(wc) == true)
		    return false;
		}
	      return true;
	    }	  
	  void print(ostream&out)
	    {
	      for(set<pair<WChar,WChar> >::iterator i=m_wcharrange.begin(); (i!=m_wcharrange.end()); i++)
		{
		  out << "(" << i->first << "," << i->second << ")";
		}
	    }
	};

      typedef enum  {
	NODE_NOP, NODE_WCHAR, NODE_RANGE, NODE_CAT
      } NType;

      struct Node
	{
	  list<Node*> Next;
	  NType Type;
	  int ID;
	  Node(NType type, int id) : Type(type), ID(id)
	  { }
	  void addNode(Node*n)
	  {
	    Next.push_back(n);
	  }
	  list<Node*>::iterator nextBegin() { return Next.begin(); }
	  list<Node*>::iterator nextEnd() { return Next.end(); }
	  void print(ostream&out, WRegExp& wre,  int indent, set<Node*>& beenthere)
	  {
	    if (beenthere.find(this) != beenthere.end())
	      return;

	    beenthere.insert(this);

	    switch(Type)
	      {
	      case NODE_NOP:
		for (int i=0;i<indent;i++) out << "  ";
		out << " - NOP\n";
		break;
	      case NODE_RANGE:
		for (int i=0;i<indent;i++) out << "  ";
		out << " - RANGE : ";
		wre.m_ranges[ID]->print(out);
		out << "\n";
		break;
	      case NODE_WCHAR:
		for (int i=0;i<indent;i++) out << "  ";
		out << " - WCHAR : ";
		wre.m_singlewchars[ID]->print(out);
		out << "\n";
		break;
	      case NODE_CAT:
		out << " - CAT\n";
		break;
	      }
	    for (list<Node*>::iterator i=Next.begin(); i!=Next.end(); i++)
	      {
		(*i)->print(out, wre, indent+1, beenthere);
	      }
	  }
	};
      friend class Node;

      map<int, SingleWChar*> m_singlewchars;
      map<int, RangeWChar*> m_ranges;
      map<int, UCharCategory*> m_categories;

      Node *m_initial;
      Node *m_final;

    public:

      char upCase(char c) const
	{
	  if ((c>='a')&&(c<='z'))
	    return c-32;
	  return c;
	}

      bool equalsNoCase(const string&a, const string& b) const
	{
	  if (a.length() != b.length())
	    return false;
	  for (unsigned int i=0; i<a.length(); i++)
	    {
	      if (upCase(a[i]) != upCase(b[i]))
		return false;
	    }
	  return true;
	}

      void printDebug(ostream&out)
	{
	  set<Node*> bt;
	  m_initial->print(out,*this,0, bt);
	}

      void setExpression(const string& exp, int result);
      bool match(const WString& wstr);
      
    private:

      bool internalCheck(Node* node, WString::const_iterator& cur, const WString::const_iterator& end);

      enum TokType 
      {
	ERR=0, TOK_OR, STAR, DASH, PLUS, OPT, SINGLEWCHAR, WCHARCATEGORY, GROUPOPEN, GROUPCLOSE, RANGEOPEN, RANGECLOSE, LISTSEP, NEG, ENDOFSTRING
      };

      WChar m_internalTokWChar;
      UCharCategory m_internalcat;

      TokType internalTokenizer(const string& str, unsigned int& index);
      pair<Node*,Node*> createNode(const string& str, unsigned int& index);
      RangeWChar* createNodeRange(const string& str, unsigned int& index);
      pair<Node*,Node*> createNodeGroup(const string& str, unsigned int& index);

      bool nextTokenIsAnOperator(const string& str, unsigned int index);

      int hexaToInt(char c)
	{
	  if ((c>='0') && (c<='9'))
	    return c - '0';
	  switch(c)
	    {
	    case 'a': case 'A':
	      return 10;
	    case 'b': case 'B':
	      return 11;
	    case 'c': case 'C':
	      return 12;
	    case 'd': case 'D':
	      return 13;
	    case 'e': case 'E':
	      return 14;
	    case 'f': case 'F':
	      return 15;
	    }
	  return -1;
	}

      WChar hexaToWChar(int h1, int h2, int h3, int h4)
	{
	  return (hexaToInt(h1)<<12) | (hexaToInt(h2)<<8) | (hexaToInt(h3)<<4) | hexaToInt(h4);
	}

    };
}

#endif






