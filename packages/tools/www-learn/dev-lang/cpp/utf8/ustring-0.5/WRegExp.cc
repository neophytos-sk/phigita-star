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


#include "WRegExp.h"

namespace ustring {

  void WRegExp::setExpression(const string& exp, int result)
  {
    Node* first = 0;
    Node* last = 0;
    Node* previouseqstart = 0;
    
    pair<Node*, Node*> p;
    unsigned int strindex = 0;
    do {
      p = createNode(exp, strindex);
      if (p.first != 0)
	{
	  if (first == 0)
	    {
	      first = p.first;
	      last = p.first;
	      previouseqstart = p.first;
	    }
	  else
	    {
	      last->addNode(p.first);
	      last = p.second;
	      previouseqstart = p.first;
	    }
	}
    } while ( (p.first != 0) || (p.second != 0));

    m_initial = first;
    m_final = last;
  }

  bool WRegExp::match(const WString& wstr)
  {
    WString::const_iterator i =wstr.begin();
    return internalCheck(m_initial, i, wstr.end());
  }

  bool WRegExp::internalCheck(Node* node, WString::const_iterator& cur, const WString::const_iterator& end)
  {
    if (cur == end)
      {
	if ((node->Type == NODE_NOP) && (node->Next.size() == 0))
	  return true;

	if (node == m_final)
	  return true;

	return false;
      }

    WString::const_iterator next;

    switch(node->Type)
      {
      case NODE_NOP:
	next = cur;
	break;
      case NODE_WCHAR:
	{
	  SingleWChar* swc = m_singlewchars[node->ID];
	  if (swc->match(*cur)==false)
	    return false;
	  next = cur+1;
	}
	break;

      case NODE_CAT:
	{
	  UCharCategory* ucc = m_categories[node->ID];
	  if (ucc->match(*cur) == false)
	    return false;
	  next = cur+1;
	}
	break;

      case NODE_RANGE:
	{
	  RangeWChar* rwc = m_ranges[node->ID];
	  if (rwc->match(*cur)==false)
	    return false;
	  next = cur+1;
	}
	break;
      }

    if (node->Next.size()==0)
      {
	if ((cur+1) == end)
	  return true;
	
	return false;
      }

    for (list<Node*>::iterator i=node->nextBegin(); i!=node->nextEnd(); i++)
      {
	if (internalCheck(*i, next, end))
	  return true;
      }

    return false;
  }
  

  WRegExp::TokType WRegExp::internalTokenizer(const string& str, unsigned int& index)
  {
    if (index >= str.length())
      return ENDOFSTRING;

    char c = str[index++];

    switch(c)
      {
      case '-':
	return DASH;
      case '+':
	return PLUS;
      case '*':
	return STAR;
      case '?':
	return OPT;
      case '(':
	return GROUPOPEN;
      case ')':
	return GROUPCLOSE;
      case '|':
	return TOK_OR;
      case '[':
	return RANGEOPEN;
      case ']':
	return RANGECLOSE;
      case '{':
	{
	  unsigned int start = index;
	  while ((index<str.length()) && (str[index]!='}'))
	      index++;
	  if (index>=str.length())
	    {
	      throw string("error");
	    }
	  if (index == start)
	    throw string("empty category not allowed");
	  
	  string ss = str.substr(start, index-start);
	  index++;
	  cerr << "CATEGORY {} = <" << ss << ">" << endl;

	  if (equalsNoCase(ss, "ALL"))
	    m_internalcat = UCharCategory(UCharCategory::ALL);
	  else if (equalsNoCase(ss, "ASSIGNED"))
	    m_internalcat = UCharCategory(UCharCategory::ASSIGNED);
	  else if (equalsNoCase(ss, "UNASSIGNED"))
	    m_internalcat = UCharCategory(UCharCategory::UNASSIGNED);

	  else if (equalsNoCase(ss,"L"))
	    m_internalcat = UCharCategory(UNICODE_LETTER);
	  else if (equalsNoCase(ss,"Lu"))
	    m_internalcat = UCharCategory(UNICODE_LETTER, UNICODE_LETTER_UPPERCASE);
	  else if (equalsNoCase(ss, "Ll"))
	    m_internalcat = UCharCategory(UNICODE_LETTER, UNICODE_LETTER_LOWERCASE);
	  else if (equalsNoCase(ss, "Lt"))
	    m_internalcat = UCharCategory(UNICODE_LETTER, UNICODE_LETTER_TITLECASE);
	  else if (equalsNoCase(ss, "Lm"))
	    m_internalcat = UCharCategory(UNICODE_LETTER, UNICODE_LETTER_MODIFIER);
	  else if (equalsNoCase(ss, "Lo"))
	    m_internalcat = UCharCategory(UNICODE_LETTER, UNICODE_LETTER_OTHER);

	  else if (equalsNoCase(ss, "M"))
	    m_internalcat = UCharCategory(UNICODE_MARK);
	  else if (equalsNoCase(ss, "Mn"))
	    m_internalcat = UCharCategory(UNICODE_MARK, UNICODE_MARK_NONSPACING);
	  else if (equalsNoCase(ss, "Mc"))
	    m_internalcat = UCharCategory(UNICODE_MARK, UNICODE_MARK_SPACING);
	  else if (equalsNoCase(ss, "Me"))
	    m_internalcat = UCharCategory(UNICODE_MARK, UNICODE_MARK_ENCLOSING);

	  else if (equalsNoCase(ss, "N"))
	    m_internalcat = UCharCategory(UNICODE_NUMBER);
	  else if (equalsNoCase(ss, "Nd"))
	    m_internalcat = UCharCategory(UNICODE_NUMBER, UNICODE_NUMBER_DECIMAL);
	  else if (equalsNoCase(ss, "Nl"))
	    m_internalcat = UCharCategory(UNICODE_NUMBER, UNICODE_NUMBER_LETTER);
	  else if (equalsNoCase(ss, "No"))
	    m_internalcat = UCharCategory(UNICODE_NUMBER, UNICODE_NUMBER_OTHER);

	  else if (equalsNoCase(ss, "Z"))
	    m_internalcat = UCharCategory(UNICODE_SEPARATOR);
	  else if (equalsNoCase(ss, "Zs"))
	    m_internalcat = UCharCategory(UNICODE_SEPARATOR, UNICODE_SEPARATOR_SPACE);
	  else if (equalsNoCase(ss, "Zl"))
	    m_internalcat = UCharCategory(UNICODE_SEPARATOR, UNICODE_SEPARATOR_LINE);
	  else if (equalsNoCase(ss, "Zp"))
	    m_internalcat = UCharCategory(UNICODE_SEPARATOR, UNICODE_SEPARATOR_PARAGRAPH);

	  else if (equalsNoCase(ss, "C"))
	    m_internalcat = UCharCategory(UNICODE_OTHER);
	  else if (equalsNoCase(ss, "Cc"))
	    m_internalcat = UCharCategory(UNICODE_OTHER, UNICODE_OTHER_CONTROL);
	  else if (equalsNoCase(ss, "Cf"))
	    m_internalcat = UCharCategory(UNICODE_OTHER, UNICODE_OTHER_FORMAT);
	  else if (equalsNoCase(ss, "Cs"))
	    m_internalcat = UCharCategory(UNICODE_OTHER, UNICODE_OTHER_SURROGATE);
	  else if (equalsNoCase(ss, "Co"))
	    m_internalcat = UCharCategory(UNICODE_OTHER, UNICODE_OTHER_PRIVATE);
	  else if (equalsNoCase(ss, "Cn"))
	    m_internalcat = UCharCategory(UNICODE_OTHER, UNICODE_OTHER_NOTASSIGNED);

	  else if (equalsNoCase(ss, "P"))
	    m_internalcat = UCharCategory(UNICODE_PUNCTUATION);
	  else if (equalsNoCase(ss, "Pc"))
	    m_internalcat = UCharCategory(UNICODE_PUNCTUATION, UNICODE_PUNCTUATION_CONNECTOR);
	  else if (equalsNoCase(ss, "Pd"))
	    m_internalcat = UCharCategory(UNICODE_PUNCTUATION, UNICODE_PUNCTUATION_DASH);
	  else if (equalsNoCase(ss, "Ps"))
	    m_internalcat = UCharCategory(UNICODE_PUNCTUATION, UNICODE_PUNCTUATION_OPEN);
	  else if (equalsNoCase(ss, "Pe"))
	    m_internalcat = UCharCategory(UNICODE_PUNCTUATION, UNICODE_PUNCTUATION_CLOSE);
	  else if (equalsNoCase(ss, "Pi"))
	    m_internalcat = UCharCategory(UNICODE_PUNCTUATION, UNICODE_PUNCTUATION_INITIALQUOTE);
	  else if (equalsNoCase(ss, "Pf"))
	    m_internalcat = UCharCategory(UNICODE_PUNCTUATION, UNICODE_PUNCTUATION_FINALQUOTE);
	  else if (equalsNoCase(ss, "Po"))
	    m_internalcat = UCharCategory(UNICODE_PUNCTUATION, UNICODE_PUNCTUATION_OTHER);

	  else if (equalsNoCase(ss, "S"))
	    m_internalcat = UCharCategory(UNICODE_SYMBOL);
	  else if (equalsNoCase(ss, "Sm"))
	    m_internalcat = UCharCategory(UNICODE_SYMBOL, UNICODE_SYMBOL_MATH);
	  else if (equalsNoCase(ss, "Sc"))
	    m_internalcat = UCharCategory(UNICODE_SYMBOL, UNICODE_SYMBOL_CURRENCY);
	  else if (equalsNoCase(ss, "Sk"))
	    m_internalcat = UCharCategory(UNICODE_SYMBOL, UNICODE_SYMBOL_MODIFIER);
	  else if (equalsNoCase(ss, "So"))
	    m_internalcat = UCharCategory(UNICODE_SYMBOL, UNICODE_SYMBOL_OTHER);
	  else
	    {
	      throw string("unkown cat");
	    }

	  return WCHARCATEGORY;
	}
	break;
      case '\\':
	{
	  c = str[index++];

	  switch(c)
	    {
	    case 'u':
	      m_internalTokWChar = hexaToWChar(str[index], str[index+1], str[index+2], str[index+3]);
	      index+=4;

	      return SINGLEWCHAR;

	    default:
	      if ((str[index]>=32) && (str[index]<127))
		{
		  m_internalTokWChar = str[index++];
		  return SINGLEWCHAR;
		}

	      return ERR;
	    }
	}
	
      default:
	m_internalTokWChar = c;
	if ((c>=32)&&(c<127))
	  {
	    return SINGLEWCHAR;
	  }
	return ERR;
      }
  }


  bool WRegExp::nextTokenIsAnOperator(const string& str, unsigned int index)
  {
    if (index >= str.length())
      return false;
    char c = str[index];
    if ((c=='*')||(c=='+')||(c=='?')||(c=='|'))
      return true;
    return false;
  }

  pair<WRegExp::Node*,WRegExp::Node*> WRegExp::createNode(const string& str, unsigned int& index)
  {
    TokType tt = internalTokenizer(str, index);
    pair<Node*,Node*> result;
    switch (tt)
      {
      case SINGLEWCHAR:
	{
	  SingleWChar* swc = new SingleWChar(m_internalTokWChar);
	  int swcindex = m_singlewchars.size();
	  m_singlewchars[swcindex] = swc;
	  Node* n1 = new Node(NODE_WCHAR, swcindex);
	  result = make_pair(n1, n1);
	}
	break;
      case WCHARCATEGORY:
	{
	  UCharCategory* ucc = new UCharCategory(m_internalcat);
	  int ici = m_categories.size();
	  m_categories[ici] = ucc;
	  Node* n1 = new Node(NODE_CAT, ici);
	  result = make_pair(n1,n1);
	}
	break;
      case RANGEOPEN:
	{
	  RangeWChar* range= createNodeRange(str, index);
	  int rangeidx = m_ranges.size();
	  m_ranges[rangeidx] = range;
	  Node* n1 = new Node(NODE_RANGE, rangeidx);
	  result =  make_pair(n1,n1);
	}
	break;

      case GROUPOPEN:
	{
	  result = createNodeGroup(str,index);
	}
	break;
	
      case GROUPCLOSE:
	return make_pair((Node*)0,(Node*)1);

      case ENDOFSTRING:
	return make_pair((Node*)0,(Node*)0);

      default:
	return make_pair((Node*)0,(Node*)0);
      }

    if (nextTokenIsAnOperator(str,index))
      {
	tt = internalTokenizer(str, index);
	switch(tt)
	  {
	  case OPT:
	    {
	      Node* last = new Node(NODE_NOP,0);
	      result.first->addNode(last);
	      result.second = last;
	    }
	    break;

	  case STAR:
	    {
	      Node* last = new Node(NODE_NOP,0);
	      result.first->addNode(last);
	      last->addNode(result.first);
	      result.second = last;
	    }
	    break;

	  case PLUS:
	    {
	      result.second->addNode(result.first);
	    }
	    break;
	    
	  case TOK_OR:
	    {
	      pair<Node*,Node*> result2 = createNode(str, index);
	      if ((result2.first == 0)||(result2.second==0))
		throw string("error");
	      Node* n1 = new Node(NODE_NOP, 0);
	      Node* n2 = new Node(NODE_NOP, 0);
	      n1->addNode(result.first);
	      n1->addNode(result2.first);
	      result.second->addNode(n2);
	      result2.second->addNode(n2);

	      result = make_pair(n1,n2);
	    }

	  default:
	    break;

	  }
      }

    return result;
  }
  
  WRegExp::RangeWChar* WRegExp::createNodeRange(const string& str, unsigned int& index)
  {
    RangeWChar* result = new RangeWChar();

    TokType tt = internalTokenizer(str,index);

    while (tt != RANGECLOSE)
      {
	if (tt == ENDOFSTRING)
	  return result; // ERROR

	if (tt == SINGLEWCHAR)
	  {
	    int car1 = m_internalTokWChar;
	    tt = internalTokenizer(str,index);
	    if (tt == DASH)
	      {
		tt = internalTokenizer(str,index);
		if (tt == SINGLEWCHAR) // found a standard range
		  {
		    result->addRange(car1, m_internalTokWChar);
		  }
		else if (tt == RANGEOPEN)
		  {
		    result->addRange(car1,car1);
		    RangeWChar* neg = createNodeRange(str,index);
		    result->addNegativeRange(neg);
		  }
		else
		  throw string("error"); // nothing else supported
	      }
	    else
	      {
		result->addRange(car1,car1);
	      }
	  }
	else if (tt == LISTSEP)
	  {
	    // nothing to do, just skip
	    tt = internalTokenizer(str,index);
	  }

      }
    return result;
  }

  pair<WRegExp::Node*,WRegExp::Node*> WRegExp::createNodeGroup(const string& str, unsigned int& index)
  {
    Node* first = new Node(NODE_NOP,0);
    Node* last = first;
    
    pair<Node*, Node*> p;

    do {
      p = createNode(str, index);
      
      if ((p.first == 0) && (p.second == (Node*)1))
	{
	  return make_pair(first,last);
	}
      last->addNode(p.first);
      last = p.second;

    } while ( (p.first != 0) || (p.second != 0));

    throw string("error");
  }

}
