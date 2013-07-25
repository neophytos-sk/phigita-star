/* ==========================================================================
 * libmime/src/script.c - Streaming Event MIME Message Parser in C
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
 * Characterset conversion routines which make best effort attempts at
 * transcoding text to UTF-8.
 * ==========================================================================
 */


/*
 * Map common script names to their ICU canonical converter names.
 * See http://www-950.ibm.com/software/globalization/icu/demo/converters.
 */
#define MIME_SCRIPT_CNAME_US_ASCII	"US-ASCII"
#define MIME_SCRIPT_CNAME_ISO_8859_1	"ISO-8859-1"
#define MIME_SCRIPT_CNAME_BIG5		"windows-950-2000"
#define MIME_SCRIPT_CNAME_GB2312	"ibm-1383_P110-1999"
#define MIME_SCRIPT_CNAME_EUC_KR	"ibm-970_P110-1995"
#define MIME_SCRIPT_CNAME_KOI8_R	"ibm-878_P100-1996"
#define MIME_SCRIPT_CNAME_ISO_2022_JP	"ISO_2022,locale=ja,version=0"
#define MIME_SCRIPT_CNAME_SHIFT_JIS	"ibm-943_P15A-2003"
#define MIME_SCRIPT_CNAME_EUC_JP	"ibm-33722_P12A-1999"


static inline int mime_script_cmp(struct mime_script *d1, struct mime_script *d2) {
	return strcasecmp(d1->name,d2->name);
} /* mime_script_cmp() */

RB_PROTOTYPE(mime_script_names,mime_script,rbe,mime_script_cmp)
RB_GENERATE(mime_script_names,mime_script,rbe,mime_script_cmp)


#define MIME_SCRIPT_HAS_8BIT		0x01
#define MIME_SCRIPT_HAS_CNTRL		0x02
#define MIME_SCRIPT_HAS_ISO_2022_MARKER	0x04
#define MIME_SCRIPT_HAS_HZ_MARKER	0x08
#define MIME_SCRIPT_HAS_NON_ASCII	(MIME_SCRIPT_HAS_8BIT | MIME_SCRIPT_HAS_CNTRL | MIME_SCRIPT_HAS_ISO_2022_MARKER | MIME_SCRIPT_HAS_HZ_MARKER)


void mime_script_analyze(const char *buf, size_t len, unsigned long *state) {
	const unsigned char *pos, *end;

	for (pos = (unsigned char *)buf, end = pos + len; pos < end; pos++) {
		if (*pos > 127)
			*state	|= MIME_SCRIPT_HAS_8BIT;

		if (iscntrl(*pos))
			*state	|= MIME_SCRIPT_HAS_CNTRL;
		
		if (*pos == 27) /* ASCII ESC */
			*state	|= MIME_SCRIPT_HAS_ISO_2022_MARKER;

		if (*pos == '~' && (pos + 1) < end && *(pos + 1) == '{')
			*state	|= MIME_SCRIPT_HAS_HZ_MARKER;
	}

	return /* void */;
} /* mime_script_analyze() */


static inline unsigned powerup (unsigned n) {
	unsigned i;

	for (i = n; n &= n - 1; i = n)
		;;

	return (i * 2);
} /* powerup() */



/*
 * Try to determine the character set encoding used in the given src buffer.
 * Return the best match from the list of scripts instantiated with the
 * MIME object.
 *
 * These interface is based off of the algorithm described at
 * http://www.mozilla.org/projects/intl/ChardetInterface.htm.
 *
 * The research is described in more detail at
 * http://www.mozilla.org/projects/intl/UniversalCharsetDetection.html.
 */
struct mime_script *mime_script_guess(struct mime *m, const char *src, size_t srclen, struct mime_script *hint, enum mime_errno *err) {
	SLIST_HEAD(,mime_script) guesses	= SLIST_HEAD_INITIALIZER(guesses);
	struct mime_script k, *s, *i;
	unsigned long info;
	const char *pos, *end;
	UErrorCode uerr;
	UChar32 uch;

	/*
	 * Initialize our scripts if necessary.
	 */
	if (LIST_EMPTY(&m->scripts))
		mime_script_init(m);

	/*
	 * Do some static analysis.
	 */
	info	= 0;
	mime_script_analyze(src,srclen,&info);

	/*
	 * Attempt to short-circuit on plain ASCII.
	 */
	if (!(info & MIME_SCRIPT_HAS_NON_ASCII)) {
		k.name	= MIME_SCRIPT_CNAME_US_ASCII;

		if ((s = RB_FIND(mime_script_names,&m->script_names,&k)))
			return s;

		k.name	= MIME_SCRIPT_CNAME_ISO_8859_1;

		if ((s = RB_FIND(mime_script_names,&m->script_names,&k)))
			return s;
	} /* ! MIME_SCRIPT_HAS_NON_ASCII */


	LIST_FOREACH(s,&m->scripts,le) {
		pos	= src;
		end	= src + srclen;
		uerr	= U_ZERO_ERROR;

		switch (ucnv_getType(s->ucnv)) {
		/*
		 * Just skip ASCII. Our static analysis should have
		 * short-ciruited already.
		 */
		case UCNV_US_ASCII:
			continue;
		/*
		 * UTF-8 converter should fail on anything not UTF-8. 
		 * Return immediately if successful.
		 */
		case UCNV_UTF8:
			ucnv_reset(s->ucnv);

			do {
				uch	= ucnv_getNextUChar(s->ucnv,&pos,end,&uerr);
			} while(pos < end && U_SUCCESS(uerr));

			if (pos >= end)
				return s;

			break;
		/*
		 * ISO-2022 and HZ converters should fail on anything not in
		 * those scripts, so if they convert okay return immediately.
		 */
		case UCNV_ISO_2022:
			/* FALL THROUGH */
		case UCNV_HZ:
			if (!(info & (MIME_SCRIPT_HAS_ISO_2022_MARKER | MIME_SCRIPT_HAS_HZ_MARKER)))
				continue;

			ucnv_reset(s->ucnv);

			do {
				uch	= ucnv_getNextUChar(s->ucnv,&pos,end,&uerr);
			} while(pos < end && U_SUCCESS(uerr));

			if (pos >= end)
				return s;

			break;
		/*
		 * Single-byte character sets.
		 */
		case UCNV_LATIN_1:
			/* FALL THROUGH */
		case UCNV_SBCS:
			ucnv_reset(s->ucnv);

			s->confidence	= 0.5;

			do {
				uch	= ucnv_getNextUChar(s->ucnv,&pos,end,&uerr);
			} while(pos < end && U_SUCCESS(uerr));

			if (pos < end)	/* Failed. */
				break;
		
			if (SLIST_EMPTY(&guesses) || s->confidence >= SLIST_FIRST(&guesses)->confidence) {
				SLIST_INSERT_HEAD(&guesses,s,sle);
			} else {
				SLIST_FOREACH(i,&guesses,sle) {
					if (s->confidence <= i->confidence) {
						SLIST_INSERT_AFTER(i,s,sle);
						break;
					}
				}
			}

			break;
		/*
		 * Multi-byte character sets.
		 */
		case UCNV_MBCS:
			/* FALL THROUGH */
		default:
			ucnv_reset(s->ucnv);

			do {
				uch	= ucnv_getNextUChar(s->ucnv,&pos,end,&uerr);
			} while(pos < end && U_SUCCESS(uerr));

			if (pos < end)	/* Failed. */
				break;

			s->confidence	= 0.5;

			SLIST_INSERT_HEAD(&guesses,s,sle);

			break;
		} /* switch(ucnv_getType()) */
	} /* LIST_FOREACH(&m->scripts) */

	return NULL;
} /* mime_script_guess() */


const char *mime_script_last_seen(struct mime *m) {
	return m->last_decode_script;
} /* mime_script_last_seen() */


enum mime_errno mime_script_init(struct mime *m) {
	char encoding[sizeof m->options.encoding];
	char *enc[64];
	int nenc;
	struct mime_script *s;
	UErrorCode uerr;
	const char *name;

	(void)memcpy(encoding,m->options.encoding,sizeof encoding);

	split(&nenc,enc,sizeof enc / sizeof *enc,encoding,":");

	if (!nenc)
		return mime_seterror(m,MIME_EASSERTION,"No encoding hints specified");

	/*
	 * Walk backwards through the array pushing new scripts, LIFO,
	 * onto the converter list.
	 */
	while(nenc--) {
		s	= arena_malloc(m->arena,sizeof *s);

		if (!s)
			return mime_seterror(m,MIME_ESYSTEM,errno,"arena_malloc(%lu)",(unsigned long)sizeof *s);

		*s	= mime_script_initializer;

		uerr	= U_ZERO_ERROR;

		s->ucnv	= ucnv_open(s->name,&uerr);

		if (!U_SUCCESS(uerr) || !s->ucnv)
			return mime_seterror(m,MIME_EUNICODE,uerr,"ucnv_open(%s)",s->name);

		/* Set defult behavior. */
		ucnv_setToUCallBack(s->ucnv,UCNV_TO_U_CALLBACK_STOP,NULL,NULL,NULL,&uerr);

		uerr	= U_ZERO_ERROR;

		name	= ucnv_getName(s->ucnv,&uerr);

		if (!U_SUCCESS(uerr) || !name) {
			ucnv_close(s->ucnv);

			return mime_seterror(m,MIME_EUNICODE,uerr,"ucnv_getName(%p)",s->ucnv);
		}

		s->name	= arena_strndup(m->arena,name,strlen(name));

		if (!s->name) {
			ucnv_close(s->ucnv);

			return mime_seterror(m,MIME_ESYSTEM,errno,"arena_strndup(%.*s)",(int)strlen(name),name);
		}

		LIST_INSERT_HEAD(&m->scripts,s,le);
	};

	return MIME_ESUCCESS;
} /* mime_script_init() */


void mime_script_deinit(struct mime *m) {
	struct mime_script *s;

	while ((s = LIST_FIRST(&m->scripts))) {
		if (s->ucnv)
			ucnv_close(s->ucnv);

		LIST_REMOVE(s,le);
	}

	return /* void */;
} /* mime_script_deinit() */

