/* ==========================================================================
 * libmime/src/mime.c - Streaming Event MIME Message Parser in C
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
 * Core MIME message state machine, I/O interfaces.
 *
 * All other source files are #include'd and mime.c is the single compilable
 * unit. This allows for internal routines to be declared static without
 * using fancy-shmancy non-portable compilation and linking directives.
 * ==========================================================================
 */
#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include <stdio.h>		/* BUFSIZ vsnprintf(3) */
#include <stdlib.h>		/* NULL ssize_t malloc(3) free(3) */
#include <stdint.h>		/* int32_t */
#include <stdbool.h>		/* true false */
#include <stddef.h>		/* offsetof */
#include <stdarg.h>		/* va_list va_start va_arg va_end */

#include <sys/types.h>		/* ssize_t */
#include <sys/param.h>		/* MAX */
#include <sys/queue.h>
#include <sys/tree.h>

#include <unistd.h>		/* read(2) close(2) */

#include <fcntl.h>		/* open(2) */

#include <string.h>		/* strlen(3) strlcpy(3) strlcat(3)
				 * strerror(3) memcmp(3) memcpy(3) memchr(3)
				 */

#include <ctype.h>		/* isascii(3) isspace(3) iscntrl(3) */

#include <errno.h>

#include <assert.h>		/* assert() */

#include <unicode/utypes.h>	/* UChar UErrorCode u_errorName() */

#include <unicode/uloc.h>	/* uloc_canonicalize() uloc_getISO3Language()
				 * uloc_getISO3Country()
				 */

#include <unicode/ucnv.h>	/* ucnv_getAlias() */

#include <zlib.h>		/* uLong */

#include <extra/string.h>	/* STRINGIFY strntolower() */
#include <extra/arena.h>	/* arena_open() arena_close() */
#include <extra/pool.h>		/* pool_open() pool_get() */

#include "mime.h"


#include "error.c"
#include "parse.c"
#include "script.c"
#include "decode.c"
#include "edit.c"
#include "header.c"
#include "entity.c"


const struct mime_options mime_defaults = {
	.locale		= STRINGIFY(MIME_DEFAULT_LOCALE),
	.encoding	= STRINGIFY(MIME_DEFAULT_ENCODING),
	.libpath	= STRINGIFY(MIME_DEFAULT_LIBPATH),
	.linebreak	= STRINGIFY(MIME_DEFAULT_LINEBREAK),
	.arenasiz	= MIME_DEFAULT_ARNBUFSIZ,
};


static enum mime_errno mime_options_locale_add(struct mime_options *opts, const char *locale, struct mime *m) {
	char loc[ULOC_FULLNAME_CAPACITY];
	int32_t len;
	UErrorCode err	= U_ZERO_ERROR;

	len	= uloc_canonicalize(locale,loc,sizeof loc,&err);

	if (U_FAILURE(err))
		return mime_seterror(m,MIME_EUNICODE,err,"%s",locale);

	if (!uloc_getISO3Language(loc)
	||  !uloc_getISO3Country(loc))
		return mime_seterror(m,MIME_ELOCALE,"%s",locale);

	if (*opts->locale)
		(void)strlcat(opts->locale,":",sizeof opts->locale);

	(void)strlcat(opts->locale,locale,sizeof opts->locale);

	return MIME_ESUCCESS;
} /* mime_options_locale_add() */


static enum mime_errno mime_options_locale_set(struct mime_options *opts, const char *locale, struct mime *m) {
	char oldloc[sizeof opts->locale];
	enum mime_errno err;

	(void)strlcpy(oldloc,opts->locale,sizeof oldloc);

	*opts->locale	= '\0';

	err	= mime_options_locale_add(opts,locale,m);

	if (MIME_FAILURE(err))
		(void)strlcpy(opts->locale,oldloc,sizeof opts->locale);

	return err;
} /* mime_options_locale_set() */


static enum mime_errno mime_options_encoding_add(struct mime_options *opts, const char *encoding, struct mime *m) {
	const char *enc;
	UErrorCode err	= U_ZERO_ERROR;

	enc	= ucnv_getAlias(encoding,0,&err);
	
	if (U_FAILURE(err))
		return mime_seterror(m,MIME_EUNICODE,err,"%s",encoding);

	if (!enc)
		return mime_seterror(m,MIME_EENCODING,"%s",encoding);

	if (*opts->encoding)
		(void)strlcat(opts->encoding,":",sizeof opts->encoding);

	(void)strlcat(opts->encoding,encoding,sizeof opts->encoding);

	return MIME_ESUCCESS;
} /* mime_options_encoding_add() */


static enum mime_errno mime_options_encoding_set(struct mime_options *opts, const char *encoding, struct mime *m) {
	char oldenc[sizeof opts->encoding];
	enum mime_errno err;

	(void)strlcpy(oldenc,opts->encoding,sizeof oldenc);

	*opts->encoding	= '\0';

	err	= mime_options_encoding_add(opts,encoding,m);

	if (MIME_FAILURE(err))
		(void)strlcpy(opts->encoding,oldenc,sizeof opts->encoding);

	return err;
} /* mime_options_encoding_set() */


enum mime_errno mime_locale_add(struct mime *m, const char *locale) {
	return mime_options_locale_add(&m->options,locale,m);
} /* mime_locale_add() */


enum mime_errno mime_locale_set(struct mime *m, const char *locale) {
	return mime_options_locale_set(&m->options,locale,m);
} /* mime_locale_set() */


enum mime_errno mime_encoding_add(struct mime *m, const char *encoding) {
	return mime_options_encoding_add(&m->options,encoding,m);
} /* mime_encoding_add() */


enum mime_errno mime_encoding_set(struct mime *m, const char *encoding) {
	return mime_options_encoding_set(&m->options,encoding,m);
} /* mime_encoding_set() */


static void mime_parse_text_entity(struct mime_entity *ent, struct mime_offset *pos, void *arg) {
	struct mime *m	= arg;

	m->text.state	= 0;

	return /* void */;
} /* mime_parse_text_entity() */


static void mime_parse_text_body(struct mime_entity *ent, const char *line, size_t len, struct mime_offset *pos, void *arg) {
	struct mime *m	= arg;
	struct mime_event *ev;
	char *buf, *nul;
	size_t buflen;

	if (!(buf = pool_get(mime_bufs,len + 4))) {
		(void)mime_seterror(m,MIME_ESYSTEM,errno,MIME_NOSTRERROR);

		goto done;
	}

	if (!ent->hints.ctype_istext) {
		goto done;
	} else if (ent->hints.ctenc_isbase64) {
		buflen	= mime_decode_base64(buf,pool_sizeof(mime_bufs,buf),(char *)line,len,&nul,NULL,0,&m->text.state);
	} else if (ent->hints.ctenc_isquoted) {
		buflen	= mime_decode_quoted(buf,pool_sizeof(mime_bufs,buf),(char *)line,len,&nul,NULL,0,&m->text.state);
	} else {
		(void)memcpy(buf,line,len);
		buflen		= len;
	}

	assert(buflen < pool_sizeof(mime_bufs,buf));

	buf[buflen]	= '\0';

	LIST_FOREACH(ev,&m->events,le) {
		if (ev->type.name.text)
			ev->cb.text(ent,buf,buflen,pos,ev->arg);
	}

done:
	pool_put(mime_bufs,buf);

	return /* void */;
} /* mime_parse_text_body() */


static void mime_parse_text_eoe(struct mime_entity *ent, struct mime_offset *pos, void *arg) {
	struct mime *m	= arg;
	struct mime_event *ev;
	char buf[4], *nul;
	size_t buflen;

	m->text.state	|= MIME_DECODE_FLUSH;

	if (!ent->hints.ctype_istext) {
		return /* void */;
	} else if (ent->hints.ctenc_isbase64) {
		buflen	= mime_decode_base64(buf,sizeof buf,NULL,0,&nul,NULL,0,&m->text.state);
	} else if (ent->hints.ctenc_isquoted) {
		buflen	= mime_decode_quoted(buf,sizeof buf,NULL,0,&nul,NULL,0,&m->text.state);
	} else
		return /* void */;

	assert(buflen < sizeof buf);

	buf[buflen]	= '\0';

	if (buflen) {
		LIST_FOREACH(ev,&m->events,le) {
			if (ev->type.name.text)
				ev->cb.text(ent,buf,buflen,pos,ev->arg);
		}
	}

	return /* void */;
} /* mime_parse_text_eoe() */


static enum mime_errno mime_parse(struct mime *m, const char *line, size_t len) {
	struct mime_event *ev;
	struct mime_header *last_header, *next_header, *this_header;
	struct mime_entity *break_entity	= NULL;
	int break_isfinal, break_isnested;
	struct mime_entity *next_entity;


	switch (m->state.exec) {
mime_parse_ini:
	case mime_parse_ini:

/*
 * Do this in mime_open() so you can add headers before parsing begins.
 */
#if 0
		m->last_entity	= mime_entity_add(m,NULL);

		if (!m->last_entity)
			return mime_errno(m);
#endif

		LIST_FOREACH(ev,&m->events,le) {
			if (ev->type.name.entity)
				ev->cb.entity(m->last_entity,&m->last_entity->position,(void *)ev->arg);
		}

		goto mime_parse_boh;

mime_parse_boe:
	m->state.exec	= mime_parse_boe;

	case mime_parse_boe:
		next_entity	= mime_entity_add(m,m->last_entity);

		if (!next_entity)
			return mime_errno(m);

		m->last_entity	= next_entity;

		LIST_FOREACH(ev,&m->events,le) {
			if (ev->type.name.entity)
				ev->cb.entity(m->last_entity,&m->last_entity->position,(void *)ev->arg);
		}

		/* FALL THROUGH */

mime_parse_boh:
	m->state.exec	= mime_parse_boh;

	if (m->lineno != 0 && mime_parse_isseparator(line,len))
		break;	/* Discard iseparator (should've been reported
			 * for parent by body parsing code).
			 */

	case mime_parse_boh:
		last_header	= NULL;

		/*
		 * Find last unfinished header, skipping any edits.  (Edits
		 * are always finalized on creation so any unfixed header
		 * could not be an edit.)
		 */
		CIRCLEQ_FOREACH_REVERSE(this_header,&m->last_entity->headers,cqe) {
			if (!this_header->fixed)
				last_header	= this_header;
		}

		if (mime_parse_isheader(line,len)) {
			if (last_header) {
				if (MIME_FAILURE(mime_header_finalize(m,m->last_entity,last_header)))
					return mime_errno(m);

				LIST_FOREACH(ev,&m->events,le) {
					if (ev->type.name.header)
						ev->cb.header(m->last_entity,last_header,&last_header->position,(void *)ev->arg);
				}
			}

			next_header	= mime_header_add(m,m->last_entity,line,len,NULL);

			if (!next_header)
				return mime_errno(m);
		} else if (mime_parse_isfold(line,len) && last_header && !mime_parse_isfrom(last_header->raw,last_header->rawlen)) {
			void *tmp;

			tmp	= arena_realloc(m->arena,last_header->raw,last_header->rawlen + 1,last_header->rawlen + len + 1);

			if (!tmp)
				return mime_seterror(m,MIME_ESYSTEM,errno,"arena_realloc(%lu)",(unsigned long)last_header->rawlen + len + 1);

			last_header->raw			= tmp;
			(void)memcpy(last_header->raw + last_header->rawlen,line,len);
			last_header->rawlen			+= len;
			last_header->raw[last_header->rawlen]	= '\0';
		} else if (mime_parse_isfrom(line,len) && m->lineno == 0) {
			LIST_FOREACH(ev,&m->events,le) {
				if (ev->type.name.unixfrom)
					ev->cb.unixfrom(m->last_entity,line,len,&(struct mime_offset){.lineno = 0, .nspan = 1, .offset = 0, .nbytes = len, .unixno = 0, .nunix = mime_parse_line_nunix(line,len,m->eol,m->eolen)},(void *)ev->arg);
			}
		} else {
			if (last_header) {
				if (MIME_FAILURE(mime_header_finalize(m,m->last_entity,last_header)))
					return mime_errno(m);

				LIST_FOREACH(ev,&m->events,le) {
					if (ev->type.name.header)
						ev->cb.header(m->last_entity,last_header,&last_header->position,(void *)ev->arg);
				}
			}

			goto mime_parse_eoh;
		}

		break;

mime_parse_eoh:
	m->state.exec	= mime_parse_eoh;

	case mime_parse_eoh:
		if (MIME_FAILURE(mime_entity_finalize(m,m->last_entity)))
			return mime_errno(m);

		LIST_FOREACH(ev,&m->events,le) {
			if (ev->type.name.eoh)
				ev->cb.eoh(m->last_entity,&(struct mime_offset){ .lineno = m->lineno, .nspan = 1, .offset = m->offset, .nbytes = len, .unixno = m->lineno, .nunix = mime_parse_line_nunix(line,len,m->eol,m->eolen) },(void *)ev->arg);
		}

		/* FALL THROUGH */

mime_parse_bod:
	m->state.exec	= mime_parse_bod;

	case mime_parse_bod:
		if (!len || mime_parse_isseparator(line,len)) {
			/*fprintf(stderr,"looks like separator: %.*s",(int)len,line);*/

			break_entity	= mime_entity_find(m,&break_isfinal,line,len);

			/*fprintf(stderr,"break: %p\n",(void *)break_entity);*/

			if (break_entity && break_entity == m->last_entity) {
				if (len > 0) {
					LIST_FOREACH(ev,&m->events,le) {
						if (ev->type.name.boundary)
							ev->cb.boundary(m->last_entity,line,len,&(struct mime_offset){ .lineno = m->lineno, .nspan = 1, .offset = m->offset, .nbytes = len, .unixno = m->lineno, .nunix = mime_parse_line_nunix(line,len,m->eol,m->eolen) },(void *)ev->arg);
					}
				}

				/*
				 * TODO: Keep track of whether any embedded
				 * entries have already been parsed. If we
				 * get an opening boundary after a previous
				 * close boundary (possible which came after
				 * an open boundary) do we ignore?
				 */

				if (!break_isfinal)
					goto mime_parse_boe;
				else if (len == 0)
					goto mime_parse_eoe;
					/* Special case EOF */
				else
					break;	/* Maintain body state so we
						 * can print any epilogue.
						 */
			} else if (break_entity && mime_entity_isdescendentof(m,m->last_entity,break_entity,MIME_EDIT_BASE)) {
				break_isfinal	= 1;

				goto mime_parse_eoe;
			} /* else ignore boundary */
		} /* if looks like separator */

		LIST_FOREACH(ev,&m->events,le) {
			if (ev->type.name.body)
				ev->cb.body(m->last_entity,line,len,&(struct mime_offset){.lineno = m->lineno, .nspan = 1, .offset = m->offset, .nbytes = len},(void *)ev->arg);
		}

		break;

mime_parse_eoe:
	m->state.exec	= mime_parse_eoe;

	/*
	 * This state expects break_entity and break_isfinal to be properly
	 * set and break_entity to be an ancestor.
	 */
	case mime_parse_eoe:
		if (!break_entity)
			goto bad_assert;

		if (break_entity != m->last_entity)
			break_isnested	= 1;
		else
			break_isnested	= 0;

		m->last_entity->position.nspan	= m->lineno - m->last_entity->position.lineno;
		m->last_entity->position.nbytes	= m->offset - m->last_entity->position.offset;

		LIST_FOREACH(ev,&m->events,le) {
			if (ev->type.name.eoe)
				ev->cb.eoe(m->last_entity,&(struct mime_offset){.lineno = m->lineno, .nspan = 1, .offset = m->offset, .nbytes = len},(void *)ev->arg);
		}

		if (m->last_entity->intree) {
			LIST_REMOVE(m->last_entity,le);

			if (m->last_entity->dupof == m->last_entity) {
				if (LIST_FIRST(&m->last_entity->duplicates))
					goto bad_assert;

				if (m->last_entity != RB_REMOVE(mime_bounds,&m->boundaries,m->last_entity))
					goto bad_assert;
			}
		}

		m->last_entity	= m->last_entity->parent;

		if (m->last_entity) {
			if (break_isfinal)
				goto mime_parse_bod;
			else
				goto mime_parse_boe;
		}

		/* FALL THROUGH */

mime_parse_fin:
	m->state.exec	= mime_parse_fin;
	
	case mime_parse_fin:

		break;

bad_assert:
	default:
		assert(0);
		return mime_seterror(m,MIME_EASSERTION,"m->state.exec:0x%.*llx",(int)sizeof(typeof(m->state.exec))*2,(unsigned long long)m->state.exec);
	} /* switch(m->state) */

	return MIME_ESUCCESS;
} /* mime_parse() */


enum mime_errno mime_writeln(struct mime *m, const char *line, size_t len) {
	enum mime_errno err	= MIME_ESUCCESS;
	const char *pos, *end;

	err	= mime_parse(m,line,len);

	m->offset	+= len;
	m->lineno++;

	for (pos = line, end = line + len; pos < end && (pos = memchr(pos,'\n',end - pos)); pos++)
		m->unixno++;

	return err;
} /* mime_writeln() */


enum mime_errno mime_write(struct mime *m, const char *buf, size_t len) {
	int last	= (len == 0);
	char *pos, *nxt, *end;
	enum mime_errno err;

	if (m->bufsiz - m->buflen < len) {
		size_t siz	= m->bufsiz + len;
		char *tmp;

		if (siz < m->bufsiz)	/* Overflow! */
			return mime_seterror(m,MIME_ESYSTEM,EOVERFLOW,"buffer:%lu + chunk:%lu",(unsigned long)m->bufsiz,(unsigned long)len);

		tmp	= realloc(m->buffer,siz);

		if (!tmp)
			return mime_seterror(m,MIME_ESYSTEM,errno,"realloc(%p,%lu)",(void *)m->buffer,(unsigned long)siz);

		m->buffer	= tmp;
		m->bufsiz	= siz;
	}

	(void)memcpy(m->buffer + m->buflen,buf,len);
	m->buflen	+= len;

	nxt	= m->buffer;
	end	= m->buffer + m->buflen;

nextline:
	pos	= nxt;
	nxt	= memmem(pos,end - pos,m->eol,m->eolen);

	if (!nxt) {	/* No Match */
		if (!last)
			goto cleanup;
		
		nxt	= end;
	} else
		nxt	+= m->eolen;

	err	= mime_writeln(m,pos,nxt - pos);

	if (MIME_FAILURE(err))
		return err;

	if (!last)
		goto nextline;

	if (nxt - pos > 0) {
		err	= mime_writeln(m,NULL,0);
		/* Do a zero write to signal EOF */

		if (MIME_FAILURE(err))
			return err;
	}

cleanup:
	(void)memmove(m->buffer,pos,end - pos);
	m->buflen	= end - pos;

	return MIME_ESUCCESS;
} /* mime_write() */


enum mime_errno mime_readfd(struct mime *m, int fd) {
	char buf[BUFSIZ];
	ssize_t num;
	enum mime_errno err;

	while (0 <= (num = read(fd,buf,sizeof buf))) {
		err	= mime_write(m,buf,num);

		if (MIME_FAILURE(err))
			return err;

		if (num == 0)
			break;
	}

	if (num)
		return mime_seterror(m,MIME_ESYSTEM,errno,"read(%d)",fd);
	else
		return MIME_ESUCCESS;
} /* mime_readfd() */


enum mime_errno mime_readfile(struct mime *m, const char *path) {
	int fd;
	enum mime_errno err;

	fd	= open(path,O_RDONLY);

	if (fd == -1)
		return mime_seterror(m,MIME_ESYSTEM,errno,"open(%s)",path);

	err	= mime_readfd(m,fd);

	(void)close(fd);
	
	return err;
} /* mime_readfile() */


enum mime_errno mime_event_add(struct mime *m, struct mime_event *ev) {
	LIST_INSERT_HEAD(&m->events,ev,le);

	m->nevents++;

	return MIME_ESUCCESS;
} /* mime_event_add() */


enum mime_errno mime_event_del(struct mime *m, struct mime_event *ev) {
	assert(m->nevents > 0);

	LIST_REMOVE(ev,le);

	m->nevents--;

	return MIME_ESUCCESS;
} /* mime_event_del() */


static int mime_init(void) {
	if (!mime_bufs && !(mime_bufs = pool_open(&pool_defaults)))
		return -1;
	else
		return 0;
} /* mime_init() */


struct mime *mime_open(const struct mime_options *opts) {
	struct arena *a	= NULL;
	struct mime *m	= NULL;

	if (0 != mime_init())
		return NULL;

	if (!opts)
		opts	= &mime_defaults;

	a	= arena_open(opts->arenasiz);

	if (!a) {
		(void)mime_seterror(NULL,MIME_ESYSTEM,errno,"arena_open");
		goto fail;
	}

	m	= arena_malloc(a,sizeof *m);

	if (!m) {
		(void)mime_seterror(NULL,MIME_ESYSTEM,errno,"arena_malloc(%lu)",(unsigned long)sizeof *m);
		goto fail;
	}

	MIME_INIT(m);

	m->options	= *opts;
	m->arena	= a;

	/* Copy over for easy access. */
	assert(m->eol   = m->options.linebreak);
	assert(m->eolen	= strlen(m->options.linebreak));

/*
 * This used to be done in the ini state in mime_parse(), but try it here so
 * headers can be added before actualy parsing of input begins.
 */
#if 1
	m->last_entity	= mime_entity_add(m,NULL);

	if (!m->last_entity)
		goto fail;
#endif

	mime_event_set(&m->text.entity,MIME_EV_ENTITY,mime_parse_text_entity,m);
	mime_event_add(m,&m->text.entity);

	mime_event_set(&m->text.body,MIME_EV_BODY,mime_parse_text_body,m);
	mime_event_add(m,&m->text.body);

	mime_event_set(&m->text.eoe,MIME_EV_EOE,mime_parse_text_eoe,m);
	mime_event_add(m,&m->text.eoe);

	return m;
fail:
	if (m)
		(void)mime_close(m);
	else if (a)
		arena_close(a);

	return NULL;
} /* mime_open() */


enum mime_errno mime_close(struct mime *m) {
	if (!m)
		return mime_seterror(NULL,MIME_ESYSTEM,EINVAL,"mime_close(NULL)");

	free(m->buffer), m->buffer = NULL;

	mime_script_deinit(m);

	arena_close(m->arena);

	return MIME_ESUCCESS;
} /* mime_close() */


