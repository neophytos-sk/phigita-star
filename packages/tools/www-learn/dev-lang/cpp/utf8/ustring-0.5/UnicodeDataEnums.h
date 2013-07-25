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

#ifndef _UNICODEDATAENUMS_H_
#define _UNICODEDATAENUMS_H_


enum UnicodeCategory {
  UNICODE_LETTER=1, UNICODE_MARK, UNICODE_NUMBER, UNICODE_SEPARATOR, 
  UNICODE_OTHER, UNICODE_PUNCTUATION, UNICODE_SYMBOL,
  UNICODE_UNKOWN_CATEGORY
};


enum UnicodeSubCategory {
  UNICODE_LETTER_UPPERCASE=1, UNICODE_LETTER_LOWERCASE, UNICODE_LETTER_TITLECASE, UNICODE_LETTER_MODIFIER, UNICODE_LETTER_OTHER,
  UNICODE_MARK_NONSPACING, UNICODE_MARK_SPACING, UNICODE_MARK_ENCLOSING,
  UNICODE_NUMBER_DECIMAL, UNICODE_NUMBER_LETTER, UNICODE_NUMBER_OTHER,
  UNICODE_SEPARATOR_SPACE, UNICODE_SEPARATOR_LINE, UNICODE_SEPARATOR_PARAGRAPH,
  UNICODE_OTHER_CONTROL, UNICODE_OTHER_FORMAT, UNICODE_OTHER_SURROGATE, UNICODE_OTHER_PRIVATE, UNICODE_OTHER_NOTASSIGNED,

  UNICODE_PUNCTUATION_CONNECTOR, UNICODE_PUNCTUATION_DASH, UNICODE_PUNCTUATION_OPEN, UNICODE_PUNCTUATION_CLOSE,
  UNICODE_PUNCTUATION_INITIALQUOTE, UNICODE_PUNCTUATION_FINALQUOTE, UNICODE_PUNCTUATION_OTHER,

  UNICODE_SYMBOL_MATH, UNICODE_SYMBOL_CURRENCY, UNICODE_SYMBOL_MODIFIER, UNICODE_SYMBOL_OTHER,

  UNICODE_UNKOWN_SUBCATEGORY
};


enum UnicodeBidirectionalCategory {
  UNICODE_BIDI_L = 1,  // Left-to-Right
  UNICODE_BIDI_LRE, // Left-to-Right Embedding
  UNICODE_BIDI_LRO, // Left-to-Right Override
  UNICODE_BIDI_R, // Right-to-Left
  UNICODE_BIDI_AL, // Right-to-Left Arabic
  UNICODE_BIDI_RLE,  // Right-to-Left Embedding
  UNICODE_BIDI_RLO,  // Right-to-Left Override
  UNICODE_BIDI_PDF, // Pop directionnal format
  UNICODE_BIDI_EN, // European Number
  UNICODE_BIDI_ES, // European Number separator
  UNICODE_BIDI_ET, // European Number terminator
  UNICODE_BIDI_AN, // Arabic Number
  UNICODE_BIDI_CS, // Common Number separator
  UNICODE_BIDI_NSM, // Non-spacing Mark
  UNICODE_BIDI_BN, // Boundary Neutral
  UNICODE_BIDI_B, // Paragraph Separator
  UNICODE_BIDI_S, // Segment Separator
  UNICODE_BIDI_WS, // Whitespace
  UNICODE_BIDI_ON, // Other neutrals

  UNICODE_BIDI_UNKNOWN, // Unknown
};

enum UnicodeDecompositionCategory {
  UNICODE_DECOMP_NONE = 1,
  UNICODE_DECOMP_CANONICAL,

  UNICODE_DECOMP_FONT,
  UNICODE_DECOMP_NOBREAK,
  UNICODE_DECOMP_INITIAL,
  UNICODE_DECOMP_MEDIAL,
  UNICODE_DECOMP_FINAL,
  UNICODE_DECOMP_ISOLATED,
  UNICODE_DECOMP_CIRCLE,
  UNICODE_DECOMP_SUPER,
  UNICODE_DECOMP_SUB,
  UNICODE_DECOMP_VERTICAL,
  UNICODE_DECOMP_WIDE,
  UNICODE_DECOMP_NARROW,
  UNICODE_DECOMP_SMALL,
  UNICODE_DECOMP_SQUARE,
  UNICODE_DECOMP_FRACTION,
  UNICODE_DECOMP_COMPAT
};

enum UnicodeCompositionAction {
  UNICODE_COMPO_TERMINAL,
  UNICODE_COMPO_FOLLOW
};

#endif
