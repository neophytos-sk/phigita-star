/* ==========================================================================
 * libmime/src/error.c - Streaming Event MIME Message Parser in C
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
 * libmime error handling and reporting.
 * ==========================================================================
 */

enum mime_errno mime_errno(struct mime *m) {
	return (m)? m->last_mime_errno : last_mime_errno; 
} /* mime_errno() */

static UErrorCode mime_icu_errno(struct mime *m) {
	return (m)? m->last_icu_errno : last_icu_errno; 
} /* mime_icu_errno() */

static int mime_sys_errno(struct mime *m) {
	return (m)? m->last_errno : last_errno; 
} /* mime_sys_errno() */


const char *mime_strerror(enum mime_errno e, struct mime *m) {
	static __thread char errstr[256];

	*errstr	= '\0';

	if (m && *m->last_error_descr) {
		(void)strlcpy(errstr,m->last_error_descr,sizeof errstr);
		(void)strlcat(errstr,": ",sizeof errstr);
	} else if (*last_error_descr) {
		(void)strlcpy(errstr,last_error_descr,sizeof errstr);
		(void)strlcat(errstr,": ",sizeof errstr);
	}

	switch (e) {
	case MIME_ESUCCESS:
		(void)strlcat(errstr,"Success",sizeof errstr);
		break;
	case MIME_ESYSTEM:
		(void)strlcat(errstr,strerror((m)? m->last_errno : last_errno),sizeof errstr);
		break;
	case MIME_EUNICODE:
	case MIME_WUNICODE:
	case MIME_MUNICODE:
		(void)strlcat(errstr,u_errorName((m)? m->last_icu_errno : last_icu_errno),sizeof errstr);
		break;
	case MIME_ELOCALE:
		(void)strlcat(errstr,"Unknown locale",sizeof errstr);
		break;
	case MIME_EENCODING:
		(void)strlcat(errstr,"Unknown encoding",sizeof errstr);
		break;
	case MIME_ESYNTAX:
		(void)strlcat(errstr,"Bad syntax",sizeof errstr);
		break;
	case MIME_EASSERTION:
		(void)strlcat(errstr,"Failed assertion",sizeof errstr);
		break;
	case MIME_WLOCALE:
		(void)strlcat(errstr,"Unknown locale",sizeof errstr);
		break;
	case MIME_WENCODING:
		(void)strlcat(errstr,"Unknown encoding",sizeof errstr);
		break;
	case MIME_WDUPLICATE_BOUNDARY:
		(void)strlcat(errstr,"Duplicate boundary marker",sizeof errstr);
		break;
	default:
		(void)strlcat(errstr,"Unknown error",sizeof errstr);
		break;
	}

	return errstr;
} /* mime_strerror() */


static enum mime_errno mime_seterror(struct mime *m, enum mime_errno e, ...) {
	va_list ap;
	const char *fmt;

	va_start(ap,e);

	*((m)?&m->last_mime_errno:&last_mime_errno)	= e;

	switch(e) {
	case MIME_ESYSTEM:
		*(int *)((m)?&m->last_errno:&last_errno)	= va_arg(ap,int);
		break;
	case MIME_EUNICODE:
	case MIME_WUNICODE:
	case MIME_MUNICODE:
		*(UErrorCode *)((m)?&m->last_icu_errno:&last_icu_errno)	= va_arg(ap,UErrorCode);
		break;
	default:
		break;
	}

	fmt	= (e == MIME_ESUCCESS)? "" : va_arg(ap,const char *);

	if (fmt) {
		if (m)
			(void)vsnprintf(m->last_error_descr,sizeof m->last_error_descr,fmt,ap);
		else
			(void)vsnprintf(last_error_descr,sizeof last_error_descr,fmt,ap);
	}
	/* NOTE: Don't erase strerror description on a NULL format
	 * specifier. This behavior is used in mime_options_loads().
	 */

	va_end(ap);
	
	return e;
} /* mime_seterror() */

