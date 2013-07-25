/* ==========================================================================
 * libmime/src/decode.c - Streaming Event MIME Message Parser in C
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
 * In increasing level of abstraction, decode Base64 text, Quoted-Printable
 * text, non-UTF-8 characters (to UTF-8 characters), MIME encoded words and
 * MIME headers.
 * ==========================================================================
 */

static const unsigned char base64_value[256] = {
        /*
         0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
         */
/* 0 */ 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
/* 1 */ 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
/* 2 */ 255,255,255,255,255,255,255,255,255,255,255, 62,255,255,255, 63,
/* 3 */ 52, 53, 54, 55, 56, 57, 58, 59, 60, 61,255,255,255,255,255,255, 
/* 4 */ 255,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
/* 5 */  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,255,255,255,255,255,
/* 6 */ 255, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
/* 7 */  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51,255,255,255,255,255,
/* 8 */ 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
/* 9 */ 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
/* A */ 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
/* B */ 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
/* C */ 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
/* D */ 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
/* E */ 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
/* F */ 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
};


size_t mime_decode_base64(char *buf, size_t buflen, char *str, size_t strlen, char **end, const char *stop, size_t nstop, unsigned long *state) {
	unsigned long group	= *state & 0x00ffffff;
	int nchar		= (*state >> 24) & 0x07;
	int flush		= *state & MIME_DECODE_FLUSH;
	int strict		= *state & MIME_DECODE_STRICT;
	unsigned char ch;
	
	struct {
		char *pos;
		char *end;
	} buffer	= { buf, buf + buflen };
	struct {
		unsigned char *pos;
		unsigned char *end;
	} string	= { (unsigned char *)str, (unsigned char *)str + strlen };

	for (; string.pos < string.end; string.pos++) {
		if (memchr(stop,*string.pos,nstop))
			break;

		ch	= base64_value[*string.pos];

		if (255 != ch) {
			group	= (group << 6) | ch;

			if (++nchar == 4) {
				if (buffer.pos + 2 < buffer.end) {
					buffer.pos[0]	= group >> 16;
					buffer.pos[1]	= group >> 8;
					buffer.pos[2]	= group;
				}

				buffer.pos	+= 3;
				nchar		= 0;
			}			
		} else if (strict)
			break;
	} /* for (string.pos < string.end) */

	if (flush) {
		switch (nchar) {
		case 1:
			group <<= 6;
			/* FALL THROUGH */
		case 2:
			group <<= 6;
			/* FALL THROUGH */
		case 3:
			group <<= 6;
			/* FALL THROUGH */
		case 0:
			/* FALL THROUGH */
		default:
			break;
		}

		if (nchar == 3) {
			if (buffer.pos + 1 < buffer.end) {
				buffer.pos[0]	= group >> 16;
				buffer.pos[1]	= group >> 8;
			}

			buffer.pos	+= 2;
		} else if (nchar == 2) {
			if (buffer.pos < buffer.end)
				buffer.pos[0]	= group >> 16;

			buffer.pos++;			
		} /* else the last 6 bits are lost */

		nchar		= 0;
	} /* if (flush) */

	*state	&= ~0x07ffffff;			/* Keep flags */
	*state	|= (nchar & 0x07) << 24;	/* Update input count */
	*state	|= (group & 0x00ffffff);	/* Update group bits */

	*end	= (char *)string.pos;

	return buffer.pos - buf;
} /* mime_decode_base64() */


size_t mime_decode_quoted(char *buf, size_t buflen, char *str, size_t strlen, char **end, const char *stop, size_t nstop, unsigned long *state) {
	unsigned long group	= *state & 0x00ffffff;
	int nchar		= (*state >> 24) & 0x07;
	int flush		= *state & MIME_DECODE_FLUSH;
	unsigned char ch;

	struct {
		char *pos;
		char *end;
	} buffer	= { buf, buf + buflen };
	struct {
		unsigned char *pos;
		unsigned char *end;
	} string	= { (unsigned char *)str, (unsigned char *)str + strlen };

	for (; string.pos < string.end; string.pos++) {
		if (memchr(stop,*string.pos,nstop))
			break;

		if (nchar == 3) {
			if (mime_parse_isquoted_printable((const char []){0xff & (group >> (2 * CHAR_BIT)),0xff & (group >> CHAR_BIT),0xff & group},3)) {
				char high, low;

				low	= toupper(0xff & group);
				low	= 0x0f & (low >= 'A')? low - 'A' + 10 : low - '0';

				high	= toupper(0xff & (group >> CHAR_BIT));
				high	= 0x0f & (high >= 'A')? high - 'A' + 10 : high - '0';
				high	<<= 4;

				if (buffer.pos < buffer.end)
					*buffer.pos	= high | low;

				buffer.pos++;

				group	= 0;
				nchar	= 0;
			} else if ((0xff & (group >> (2 * CHAR_BIT))) == '_') {
				if (buffer.pos < buffer.end)
					*buffer.pos	= ' ';

				buffer.pos++;
				
				nchar	= 2;
			} else if (mime_parse_isquoted_softbreak((const char []){0xff & (group >> (2 * CHAR_BIT)),0xff & (group >> CHAR_BIT),0xff & group},3)) {
				/*
				 * We have either a Unix =LF or canonical
				 * MIME =CRLF softbreak. Drop the softbreak,
				 * which is all three bytes for =CRLF or two
				 * bytes for Unix =LF.
				 */
				if ((0xff & (group >> CHAR_BIT)) == '\n')
					nchar	= 1;
				else
					nchar	= 0;
			} else {
				if (buffer.pos < buffer.end)
					*buffer.pos	= 0xff & (group >> (2 * CHAR_BIT));

				buffer.pos++;
				
				nchar	= 2;
			}
		}

		group	<<= CHAR_BIT;

		group	|= 0xff & *string.pos;

		nchar++;
	} /* for (string.pos < string.end) */

	if (flush) {
		if (nchar == 3 && mime_parse_isquoted_printable((const char []){0xff & (group >> (2 * CHAR_BIT)),0xff & (group >> CHAR_BIT),0xff & group},3)) {
			char high, low;

			low	= toupper(0xff & group);
			low	= 0x0f & (low >= 'A')? low - 'A' + 10 : low - '0';

			high	= toupper(0xff & (group >> CHAR_BIT));
			high	= 0x0f & (high >= 'A')? high - 'A' + 10 : high - '0';
			high	<<= 4;

			if (buffer.pos < buffer.end)
				*buffer.pos	= high | low;

			buffer.pos++;
		} else  {
			if ((nchar == 3 && mime_parse_isquoted_softbreak((const char []){0xff & (group >> (2 * CHAR_BIT)),0xff & (group >> CHAR_BIT),0xff & group},3))
			||  (nchar == 2 && mime_parse_isquoted_softbreak((const char []){0xff & (group >> CHAR_BIT),0xff & group},2))) {
				/*
				 * We have either a Unix =LF or canonical
				 * MIME =CRLF softbreak. Drop the softbreak,
				 * which is all three bytes for =CRLF or two
				 * bytes for Unix =LF.
				 */
				if (((0xff & (group >> CHAR_BIT)) == '=')
				||  ((0xff & (group >> CHAR_BIT)) == '\n'))
					nchar	-= 2;
				else
					nchar	-= 3;
			}

			switch (nchar) {
			case 3:
				ch	= 0xff & (group >> (2 * CHAR_BIT));

				if (buffer.pos < buffer.end)
					*buffer.pos	= (ch == '_')? ' ' : ch;

				buffer.pos++;

				/* FALL THROUGH */
			case 2:
				ch	= 0xff & (group >> CHAR_BIT);

				if (buffer.pos < buffer.end)
					*buffer.pos	= (ch == '_')? ' ' : ch;

				buffer.pos++;

				/* FALL THROUGH */
			case 1:
				ch	= 0xff & group;

				if (buffer.pos < buffer.end)
					*buffer.pos	= (ch == '_')? ' ' : ch;

				buffer.pos++;

				/* FALL THROUGH */
			case 0:
				break;
			default:
				assert(0);
			} /* switch (nchar) */
		}

		group	= 0;
		nchar	= 0;
	} /* if (flush) */

	*state	&= ~0x07ffffff;			/* Keep flags */
	*state	|= (nchar & 0x07) << 24;	/* Update input count */
	*state	|= (group & 0x00ffffff);	/* Update group bits */

	*end	= (char *)string.pos;

	return buffer.pos - buf;
} /* mime_decode_quoted() */


size_t mime_decode_script(char *buf, size_t buflen, char *text, size_t textlen, const char *hint, size_t hintlen, int noguess, int is8bit, struct mime *m, unsigned long *state, enum mime_errno *err) {
	static __thread struct {
		UChar *buf;
		int32_t bufsiz;
		int32_t buflen;
	} tmp;
	struct {
		unsigned char *pos;
		unsigned char *end;
		UConverter *cnv;
	} in;
	struct {
		char *pos;
		char *end;
		UConverter *cnv;
	} out;
	char bestnam[UCNV_MAX_CONVERTER_NAME_LENGTH]	= "ISO-8859-1";
	int32_t bestnum					= 0;
	char charset[UCNV_MAX_CONVERTER_NAME_LENGTH];
	int lasttry;
	int32_t len;
	size_t want;
	UChar *p;
	UErrorCode uerr;

	/*
	 * TODO: Support stateful (i.e. streaming) decoding!
	 */
	tmp.buflen	= 0;

	in.pos		= (unsigned char *)text,
	in.end		= in.pos + textlen;
	in.cnv		= NULL;

	out.pos		= buf;
	out.end		= out.pos + buflen;
	out.cnv		= NULL;

	uerr	= U_ZERO_ERROR;

	out.cnv	= ucnv_open("UTF8",&uerr);

	if (!U_SUCCESS(uerr) || !out.cnv) {
		*err = mime_seterror(m,MIME_EUNICODE,uerr,"ucnv_open(UTF8)");
		goto finish;
	}

nexthint:
	/*
	 * Find the next character set encoding hint.
	 */
	if (!hint || !hintlen) {
		hint	= m->options.encoding;
		hintlen	= strcspn(hint,":");
	} else if (hint >= m->options.encoding && hint < m->options.encoding + sizeof m->options.encoding) {
		if (hint[hintlen] == ':' && hint[hintlen + 1] != '\0') {
			hint	+= hintlen + 1;
			hintlen	= strcspn(hint,":");
		} else {
			hint	= NULL;
			hintlen	= 0;
		}
	}

	lasttry	= (hint && hintlen)? 0 : 1;

	if (lasttry)
		(void)strlcpy(charset,bestnam,sizeof charset);
	else
		(void)snprintf(charset,sizeof charset,"%.*s",(int)hintlen,hint);

	/*fprintf(stderr,"trying charset %s for %.*s\n",charset,(int)(in.end - in.pos),in.pos);*/

	if (in.cnv)
		ucnv_close(in.cnv);

	uerr	= U_ZERO_ERROR;

	in.cnv	= ucnv_open(charset,&uerr);

	if (U_SUCCESS(uerr)) {
restart:
		if (!lasttry) {
			uerr	= U_ZERO_ERROR;

			if (noguess)
				ucnv_setToUCallBack(in.cnv,UCNV_TO_U_CALLBACK_SKIP,NULL,NULL,NULL,&uerr);
			else
				ucnv_setToUCallBack(in.cnv,UCNV_TO_U_CALLBACK_STOP,NULL,NULL,NULL,&uerr);

			if (!U_SUCCESS(uerr)) {
				*err = mime_seterror(m,MIME_EUNICODE,uerr,"ucnv_setToUCallBack(UCNV_FROM_U_CALLBACK_STOP)");
				goto finish;
			}
		}

		uerr	= U_ZERO_ERROR;

		len	= ucnv_toUChars(in.cnv,tmp.buf,tmp.bufsiz,(char *)in.pos,in.end - in.pos,&uerr);

		switch (uerr) {
		case U_STRING_NOT_TERMINATED_WARNING:
		case U_BUFFER_OVERFLOW_ERROR:
			want	= (len + 1) * sizeof *tmp.buf;
			
			p	= realloc(tmp.buf,want);

			if (!p) {
				*err		= mime_seterror(m,MIME_ESYSTEM,errno,"realloc(%p,%lu)",(void *)tmp.buf,(unsigned long)want);
				goto finish;
			}

			tmp.buf		= p;
			tmp.bufsiz	= want / sizeof *tmp.buf;
			goto restart;

			/* NOT REACHED */
		default:
			if (lasttry)
				*err	= mime_seterror(m,MIME_WUNICODE,uerr,"ucnv_toUChars(%s)",charset);

			/* FALL THROUGH */
		case U_ZERO_ERROR:
			if (len > bestnum) {
				(void)strlcpy(bestnam,charset,sizeof bestnam);
				bestnum	= len;
			}
			
			tmp.buflen	= len;

			if (uerr == U_ZERO_ERROR)
				goto finish;
		} /* switch (uerr) */
	} else
		*err	= mime_seterror(m,(lasttry)? MIME_EUNICODE : MIME_WUNICODE,uerr,"ucnv_open(%s)",charset);

	if (!lasttry && !noguess) {
		if (!(hint >= m->options.encoding && hint < m->options.encoding + sizeof m->options.encoding))
			hint = NULL, hintlen = 0;

		goto nexthint;
	}

finish:
	if (out.cnv) {
		uerr	= U_ZERO_ERROR;

		len	= ucnv_fromUChars(out.cnv,out.pos,out.end - out.pos,tmp.buf,tmp.buflen,&uerr);

		switch (uerr) {
		case U_STRING_NOT_TERMINATED_WARNING:
		case U_BUFFER_OVERFLOW_ERROR:
		case U_ZERO_ERROR:
			break;
			/* NOT REACHED */
		default:
			*err	= mime_seterror(m,MIME_EUNICODE,uerr,"ucnv_fromUChars(UTF8)");
		} /* switch (uerr) */

		out.pos	+= MAX(0,len);
		
		ucnv_close(out.cnv);

		(void)strlcpy(m->last_decode_script,charset,sizeof m->last_decode_script);
	}

	if (in.cnv)
		ucnv_close(in.cnv);


	return out.pos - buf;
} /* mime_decode_script() */


size_t mime_decode_header(char *buf, size_t buflen, char *txt, size_t txtlen, struct mime *m, enum mime_errno *err) {
	static __thread struct {
		char *buf;
		size_t bufsiz;
	} tmp;
	struct {
		char *prv;
		char *pos;
		char *end;
	} out;
	struct {
		unsigned char *pos;
		unsigned char *nxt;
		unsigned char *end;
	} in;
	bool is8bit, isencoded, wasencoded, isspace, wasspace, iseol;
	char *charset, *language, *encoding, *word;
	size_t charlen, langlen, enclen, wordlen, convlen;


	out.prv	= buf;
	out.pos	= buf;
	out.end	= buf + buflen;

	if (!txtlen) {
		if (out.pos < out.end)
			*out.pos	= '\0';

		return 0;
	}

	in.pos	= (unsigned char *)txt;
	in.nxt	= in.pos;
	in.end	= in.pos + txtlen;

	/*
	 * Decoding Base64 and QP is reductive, so make our tmp buffer at
	 * least as big as the input length.
	 */
	if (in.end - in.pos > (ptrdiff_t)tmp.bufsiz) {
		char *p;

		p	= realloc(tmp.buf,in.end - in.pos);

		if (!p)
			return *err = mime_seterror(m,MIME_ESYSTEM,errno,"realloc"), (size_t)0;

		tmp.buf		= p;
		tmp.bufsiz	= in.end - in.pos;
	}

	isencoded	= wasencoded
			= false;
	isspace		= false;

nextspan:
	wasencoded	= (isspace)? wasencoded : isencoded;
	/* Maintain wasencoded until non-space encountered */

	isencoded	= false;

	wasspace	= isspace;
	/* Keep wasspace so we can use wasencoded properly (i.e., if we have
	 * adjacent encoded words w/o any space in-between we don't want to
	 * erase the previous encoded word just because wasencoded was still
	 * set.
	 */

	isspace		= false;
	is8bit		= false;

restart:
	iseol		= false;

	for (in.pos = in.nxt; in.nxt < in.end; in.nxt++) {
		/*
		 * Break on EOL
		 */
		if (mime_parse_islinebreak((char *)in.nxt,in.end - in.nxt,m->eol,m->eolen)) {
			if (in.nxt == in.pos)
				iseol	= true;
			break;
		}

		/*
		 * Break on any encoded word boundary
		 */
		if (mime_parse_isencoded_word((char *)in.nxt,in.end - in.nxt)) {
			if (in.nxt == in.pos)
				isencoded	= true;
			break;
		}

		/*
		 * Break on non-space -> space boundary
		 */
		if (*in.nxt == ' ' || *in.nxt == '\t') {
			if (!isspace && in.nxt != in.pos)
				break;

			isspace	= true;

			continue;		
		}

		/*
		 * Break on space -> non-space boundary
		 */
		if (isspace)
			break;

		/*
		 * Detect 8-bit characters (> 127) including 7-bit control
		 * characters. ISO-2022 uses decimal 27 (ESC) to switch
		 * character sets, which is caught by iscntrl().
		 */
		if (*in.nxt > 127 || iscntrl(*in.nxt))
			is8bit	= true;
	} /* for (in.nxt++) */

	if (iseol) {	/* Skip linebreaks */
		in.nxt	+= m->eolen;
		goto restart;
	}

	charset		= language
			= NULL;

	charlen		= langlen
			= 0;

	word		= (char *)in.pos;
	wordlen		= in.nxt - in.pos;

	if (isencoded) {
		char *nxt, *end;
		size_t len;
		unsigned long state;

		nxt	= mime_parse_encoded_word(&charset,&charlen,&language,&langlen,&encoding,&enclen,&word,&wordlen,(char *)in.nxt,in.end - in.nxt,m->eol,m->eolen);
		/*
		 * We pass in.nxt instead of in.pos because there could
		 * be leading whitespace.
		 */

		if (nxt && charlen > 0 && enclen > 0 && word) {
			in.nxt	= (unsigned char *)nxt;
#if 0
			fprintf(stderr,"charset: [%d:%.*s]\n",(int)charlen,(int)charlen,charset);
			fprintf(stderr,"encoding: [%d:%.*s]\n",(int)enclen,(int)enclen,encoding);
			fprintf(stderr,"word: [%d:%.*s]\n",(int)wordlen,(int)wordlen,word);
#endif
			switch (*encoding) {
			case 'b':
			case 'B':
				state	= MIME_DECODE_FLUSH;
				len	= mime_decode_base64(tmp.buf,tmp.bufsiz,word,wordlen,&end,NULL,0,&state);

				break;
			case 'q':
			case 'Q':
				state	= MIME_DECODE_FLUSH;
				len	= mime_decode_quoted(tmp.buf,tmp.bufsiz,word,wordlen,&end,NULL,0,&state);

				break;
			default:
				len	= 0;
				break;
			}

			word	= tmp.buf;
			wordlen	= len;

			if (wasencoded && wasspace) /* erase previous space */
				out.pos	= out.prv;

			is8bit	= 1;
		} else {
			/* Eat that first '=' */
			in.nxt++;

			isencoded	= false;
			wasencoded	= false;

			word	= (char *)in.pos;
			wordlen	= in.nxt - in.pos;
		}
	} /* isencoded */

	if (is8bit) {
		unsigned long state	= MIME_DECODE_FLUSH;

		convlen	= mime_decode_script(out.pos,(out.pos < out.end)? out.end - out.pos : 0,word,wordlen,charset,charlen,(charset && charlen),is8bit,m,&state,err);
	} else {
		if (out.pos < out.end)
			(void)memcpy(out.pos,word,MIN((size_t)(out.end - out.pos),wordlen));

		convlen	= wordlen;
	}

	out.prv	= out.pos;
	out.pos	+= convlen;

	if (in.pos < in.end && in.nxt > in.pos)
		goto nextspan;

	return out.pos - buf;
} /* mime_decode_header() */

