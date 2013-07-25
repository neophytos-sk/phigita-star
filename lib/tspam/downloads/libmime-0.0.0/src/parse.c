/* ==========================================================================
 * libmime/src/parse.c - Streaming Event MIME Message Parser in C
 * --------------------------------------------------------------------------
 * Copyright (c) 2004, 2005, 2006  Barracuda Networks, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to permit
 * persons to whom the Software is furnished to do so, subject to the
 * following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
 * NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
 * USE OR OTHER DEALINGS IN THE SOFTWARE.
 * --------------------------------------------------------------------------
 * History
 *
 * 2006-02-01 (william@25thandClement.com)
 * 	Published by Barracuda Networks, originally authored by
 * 	employee William Ahern (wahern@barracudanetworks.com).
 * --------------------------------------------------------------------------
 * Description
 *
 * Various MIME parsing routines.
 * ==========================================================================
 */

/* mime_parse_header
 *
 * Split a header into 3 parts: field name, colon separator and field body. 
 * Strips trailing field name space, and prefixed field body space.
 *
 * See mime_parse_isheader for more info.
 */

static bool mime_parse_header(char **name, size_t *namelen, char **colon, size_t *colonlen, char **body, size_t *bodylen, char *line, size_t len) {
	char *pos, *end;

	*name		= NULL;
	*namelen	= 0;
	*colon		= NULL;
	*colonlen	= 0;
	*body		= NULL;
	*bodylen	= 0;

	if (len < 2)
		return false;

	pos	= line;
	end	= line + len;

	if (pos[0] == '-' && pos[1] == '-')
		return false;	/* Differentiate from MIME separator() */

	for (; pos < end && *pos > ' ' && *pos != ':' && *pos != '\0'; pos++)
		;;

	if (pos == line)
		return false;

	*name		= line;
	*namelen	= pos - *name;

	for (; pos < end && isascii(*pos) && isspace(*pos); pos++)
		;;

	if (pos >= end || *pos != ':')
		return false;

	*colon		= pos;
	*colonlen	= 1;

	for (pos++; pos < end && isascii(*pos) && isspace(*pos); pos++)
		;;

	if (pos >= end)
		return true;

#if 0	/* XXX: Screws with header continuation copying in mime_parse() */
	for (end--; end > pos && isascii(*pos) && isspace(*pos); pos--)
		;;
	end++;
#endif

	*body		= pos;
	*bodylen	= end - pos;

	return true;
} /* mime_parse_header() */


static inline bool mime_parse_islinebreak(const char *str, size_t slen, const char *brk, size_t blen) {
	return (blen > 0 && slen >= blen && 0 == memcmp(str,brk,blen));
} /* mime_parse_islinebreak() */


/* mime_parse_header_body()
 *
 * Iteratively parses a tokenizable header body. See
 * http://cr.yp.to/immhf/token.html
 *
 * NOTES:
 * 	* Only whole headers should be passed in initially.
 * 
 * 	* Unterminated quoted strings and comments aren't rewound and
 * 	  reparsed. In essance, EOL is equivalent " and ]. This seems to be
 * 	  the behavior of Sendmail and Evolution; tested, in fact.
 */
size_t mime_parse_header_body(char **token, char **space, char **comment, char *buf, size_t buflen, const char **line, size_t len, const char *linebreak, size_t linebreaklen, const char *punct, const char *nopunct) {
	const char *nxt, *eol;
	char *pos, *end;
	int quoted, commented, bracketed;

	*token		= NULL;
	*space		= NULL;
	*comment	= NULL;

	nxt	= *line;
	eol	= *line + len;

	pos	= buf;
	end	= buf + buflen;

	quoted		= 0;
	commented	= 0;
	bracketed	= 0;

	while (nxt < eol) {
		if (mime_parse_islinebreak(nxt,eol - nxt,linebreak,linebreaklen)) {
			nxt	+= linebreaklen;
			continue;
		}

		switch (*nxt) {
		case '\\':
			if (++nxt >= eol)
				nxt--;	/* Backslash before EOL is literal */

			goto literal;

		case '"':
			if (commented || bracketed)
				goto literal;

			if (quoted) {	/* Finish */
				if (pos < end)
					*pos	= *nxt;

				nxt++;
				/* Don't pos++ */

				goto last;
			}

			if (*token || *space || *comment)
				goto last;

			quoted	= 1;

			nxt++;

			break;

		case '(':
			if (quoted || bracketed)
				goto literal;

			if (!commented && (*space || *token))
				goto last;

			commented++;

			goto literal;
		case ')':
			if (commented) {
				commented--;

				if (!commented) {
					if (pos < end)
						*pos	= *nxt;

					nxt++;
					pos++;

					goto last;
				} else
					goto literal;
			}

			goto punctuation;
		case '[':
			if (quoted || commented)
				goto literal;

			if (bracketed) {
				nxt	-= nxt - *line;	/* Rewind to [ */
				pos	-= pos - buf;

				if (pos < end)
					*pos	= *nxt;
				
				nxt++;
				pos++;
				
				goto last;
			}

			if (*token || *space || *comment)
				goto last;

			bracketed	= 1;
			
			goto literal;

		case ']':
			if (bracketed) {
				if (pos < end)
					*pos	= *nxt;

				nxt++;
				pos++;
				
				goto last;
			}

			/* FALL THROUGH */
		case '<':
		case '>':
		case ',':
		case ';':
		case ':':
		case '@':
		case '.':
punctuation:
			if (quoted || commented || bracketed)
				goto literal;

			if (nopunct && strchr(nopunct,*nxt))
				goto literal;

			if (*space || *token)
				goto last;

			*token	= pos;

			if (pos < end)
				*pos	= *nxt;

			nxt++;
			pos++;

			goto last;
		case ' ':
		case '\t':
			if (quoted || commented || bracketed)
				goto literal;

			if (*space || *token)
				goto last;

			*space	= pos;

			if (pos < end)
				*pos	= *nxt;

			nxt++;
			pos++;
				
			goto last;

		default:
			if (punct && strchr(punct,*nxt))
				goto punctuation;

			if (*space)
				goto last;

			/* FALL THROUGH */
literal:
			if (!*token && !*comment && !*space) {
				if (commented)
					*comment	= pos;
				else
					*token		= pos;
			}

			if (pos < end)
				*pos	= *nxt;

			nxt++;
			pos++;
			
			break;
		} /* switch(*nxt) */
	} /* while(nxt < eol) */

last:
	*line	= nxt;

	return pos - buf;
} /* mime_parse_header_body() */


/* mime_parse_isheader
 * 
 * Returns whether a line looks like a header or not. Heavily influenced by
 * sendmail:headers.c:isheader().
 */
static bool mime_parse_isheader(const char *line, size_t len) {
	const char *pos, *end;

	if (len < 2)
		return false;

	pos	= line;
	end	= line + len;

	if (pos[0] == '-' && pos[1] == '-')
		return false;	/* Differentiate from MIME separator */

	for (; pos < end && *pos > ' ' && *pos != ':' && *pos != '\0'; pos++)
		;;

	if (pos == line)
		return false;

	for (; pos < end && isascii(*pos) && isspace(*pos); pos++)
		;;

	return (pos < end && *pos == ':');
} /* mime_parse_isheader() */

static bool mime_parse_isfold(const char *line, size_t len) {
	return (len && (*line == ' ' || *line == '\t'));
} /* mime_parse_isfold() */

static bool mime_parse_isfrom(const char *line, size_t len) {
	return (len >= sizeof "From " - 1 && 0 == strncmp(line,"From ",sizeof "From " - 1));
} /* mime_parse_isfrom() */

static bool mime_parse_isseparator(const char *line, size_t len) {
	if (len < 2 || line[0] != '-' || line[1] != '-')
		return false;

	return true;
} /* mime_parse_isseparator() */

static bool mime_parse_isencoded_word(const char *line, size_t len) {
	/* Minimum: =??x??= */

	if (len < 7 || line[0] != '=' || line[1] != '?')
		return false;

	return true;
} /* mime_parse_isencoded_word() */

static bool mime_parse_isquoted_printable(const char *str, size_t len) {
	if (len < 3 || str[0] != '=' || !isxdigit((unsigned char)str[1]) || !isxdigit((unsigned char)str[2]))
		return false;

	return true;
} /* mime_parse_isquoted_printable() */


static bool mime_parse_isquoted_softbreak(const char *str, size_t len) {
	if (len < 2)
		return false;
	else if (str[0] != '=')
		return false;
	else if (str[1] == '\n')			/* Unix softbreak. */
		return true;
	else if (len < 3)
		return false;
	else if (str[1] == '\r' && str[2] == '\n')	/* MIME softbreak. */
		return true;
	else
		return false;
} /* mime_parse_isquoted_softbreak() */


static char *mime_parse_encoded_word(char **charset, size_t *charlen, char **language, size_t *langlen, char **encoding, size_t *enclen, char **word, size_t *wrdlen, char *str, size_t strlen, const char *linebreak, size_t breaklen) {
	char *pos, *nxt, *end;

	pos	= str;
	end	= pos + strlen;

	*charset	= NULL;
	*charlen	= 0;
	*language	= NULL;
	*langlen	= 0;
	*encoding	= NULL;
	*enclen		= 0;
	*word		= NULL;
	*wrdlen		= 0;

	if (pos >= end)
		return pos;
		
	if (*pos != '=')
		return pos;

	pos++;	/* Skip over '=' */

	if (pos >= end)
		return --pos;

	if (*pos != '?')
		return pos;
	
	pos++;	/* Skip over '?' */

	*charset	= pos;

	for (nxt = pos; nxt < end; nxt++) {
		if (*nxt == '?')
			break;
		else if (mime_parse_islinebreak(nxt,end-nxt,linebreak,breaklen))
			break;
	}

	if (nxt >= end || *nxt != '?')
		return *charset = NULL, pos;

	pos		= nxt;
	*charlen	= pos - *charset;

	pos++; 	/* Skip over '?' */

	if (pos >= end)
		return --pos;

	*encoding	= pos;

	/* Go off on a short diversion looking for a specified language */
	for (pos = *charset; pos < *encoding && *pos != '*'; pos++)
		;;

	if (pos < *encoding && *pos == '*') {
		*charlen	= pos - *charset;

		if (++pos < *encoding - 1) {	/* *pos < '?' '[encoding]' */
			*language	= pos;
			*langlen	= *encoding - 1 - *language;
		}
	}

	pos	= *encoding;

	for (nxt = pos; nxt < end; nxt++) {
		if (*nxt == '?')
			break;
		else if (mime_parse_islinebreak(nxt,end-nxt,linebreak,breaklen))
			break;
	}

	if (nxt >= end || *nxt != '?')
		return *encoding = NULL, pos;

	pos	= nxt;
	*enclen	= pos - *encoding;

	pos++;	/* Skip over '?' */

	if (pos >= end)
		return --pos;

	*word	= pos;

	for (nxt = pos; nxt < end; nxt++) {
		if (*nxt == '?' && nxt + 1 < end && nxt[1] == '=')
			break;
		else if (mime_parse_islinebreak(nxt,end-nxt,linebreak,breaklen))
			break;
	}

	if (nxt >= end || *nxt != '?' || nxt + 1 >= end || nxt[1] != '=')
		return *word = NULL, pos;

	pos	= nxt;
	*wrdlen	= pos - *word;

	pos	+= 2;

	return pos;
} /* mime_parse_encoded_word() */


static size_t mime_parse_text_nunix(const char *line, size_t len) {
	const char *end	= line + len;
	size_t num	= 0;

	for (; line < end && (line = memchr(line,'\n',end - line)); line++)
		num++;

	return num;
} /* mime_parse_text_nunix() */


static size_t mime_parse_line_nunix(const char *line, size_t len, const char *eol, size_t eolen) {
	if (eolen == 1 && *eol == '\n')
		return 1;
	else
		return mime_parse_text_nunix(line,len);
} /* mime_parse_line_nunix() */

