/* ==========================================================================
 * libmime/src/header.c - Streaming Event MIME Message Parser in C
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
 * MIME header parsing and accessor routines.
 * ==========================================================================
 */

/* mime_header_parse_ctype()
 *
 * Simple MIME Content-Type parser to locate type/subtype, charset, and
 * boundary marker.
 */
static struct mime_header *mime_header_parse_ctype(struct mime *m, struct mime_entity *ent, struct mime_header *hdr) {
	static __thread char *buf;
	static __thread size_t bufsiz;
	const char *pos, *end, *params;
	char *token, *space, *comment;
	size_t len;
	char *fwdslash;

	hdr->ctype.type		= NULL;
	hdr->ctype.typelen	= 0;

	hdr->ctype.charset	= NULL;
	hdr->ctype.charsetlen	= 0;

	hdr->ctype.boundary	= NULL;
	hdr->ctype.boundarylen	= 0;

	if (!hdr->bodylen)
		return hdr;

	if (bufsiz < hdr->bodylen) {
		char *tmp;

		tmp	= realloc(buf,hdr->bodylen);

		if (!tmp)
			return mime_seterror(m,MIME_ESYSTEM,errno,"realloc(%p,%lu)",(void *)buf,(unsigned long)hdr->bodylen), (void *)0;

		buf	= tmp;
		bufsiz	= hdr->bodylen;
	}

	pos	= hdr->body;
	end	= hdr->body + hdr->bodylen;

	/*
	 * Step 1: Find the type: text/plain, multipart/alternative, etc.
	 *
	 * 2005-06-09 (William Ahern): Ignore periods (.'s) for illegal
	 * types like Microsoft's `application/vnd.ms-excel'.
	 */
	do {
		len	= mime_parse_header_body(&token,&space,&comment,buf,bufsiz,&pos,end-pos,m->eol,m->eolen,NULL,".");
	} while (len && !token);

	if (!token)
		return hdr;

	fwdslash	= memchr(token,'/',len);

	if (!fwdslash)
		return hdr;

	hdr->ctype.type		= arena_strndup(m->arena,strntolower(token,len),len);
	hdr->ctype.typelen	= len;

	if (!hdr->ctype.type)
		goto sysfail;

	/*
	 * Step 2: Find a delimiting semicolon.
	 */
	do {
		len	= mime_parse_header_body(&token,&space,&comment,buf,bufsiz,&pos,end-pos,m->eol,m->eolen,NULL,NULL);
	} while (len && !token);

	if (!token || *token != ';' || len != 1)	/* Disallow quoted? */
		return hdr;

	params	= pos;	/* Store the beginning of the parameters */

	/*
	 * Step 3: Find charset.
	 */
	do {
		len	= mime_parse_header_body(&token,&space,&comment,buf,bufsiz,&pos,end-pos,m->eol,m->eolen,"=",NULL);

		if (len == sizeof "charset" - 1 && 0 == strncasecmp(token,"charset",len)) {
			char *bufpos	= buf;
			char *charset	= NULL;

			do {
				len	= mime_parse_header_body(&token,&space,&comment,buf,bufsiz,&pos,end-pos,m->eol,m->eolen,"=",NULL);
			} while (len && !token);

			if (!token || *token != '=' || len > 1)
				break;

			/* Append comments as well for broken generators
			 * which don't quote comment delimiters properly. */
			do {
				len	= mime_parse_header_body(&token,&space,&comment,bufpos,bufsiz - (bufpos - buf),&pos,end-pos,m->eol,m->eolen,NULL,NULL);

				if (space) {
					if (charset)
						break;
					else
						continue;
				}

				if ((token && *token == ';' && len == 1)
				|| (comment && *comment == ';' && len == 1))
					break;	/* FIXME: What if the single
						 * semicolon was quoted?
						 */

				if (!charset)
					charset	= bufpos;

				bufpos	+= len;
			} while(len);

			len	= (charset)? bufpos - charset : 0;

			if (len) {
				hdr->ctype.charset	= arena_strndup(m->arena,strntolower(charset,len),len);
				hdr->ctype.charsetlen	= len;

				if (!hdr->ctype.charset)
					goto sysfail;
			}
		} /* if (charset) */
	} while (len);


	/*
	 * Step 4: Find boundary.
	 */
	pos	= params;

	do {
		len	= mime_parse_header_body(&token,&space,&comment,buf,bufsiz,&pos,end-pos,m->eol,m->eolen,"=",NULL);

		if (len == sizeof "boundary" - 1 && 0 == strncasecmp(token,"boundary",len)) {
			char *bufpos	= buf;
			char *boundary	= NULL;

			do {
				len	= mime_parse_header_body(&token,&space,&comment,buf,bufsiz,&pos,end-pos,m->eol,m->eolen,"=",NULL);
			} while (len && !token);

			if (!token || *token != '=' || len > 1)
				break;

			/* Append comments as well for broken generators
			 * which don't quote properly. */
			do {
				len	= mime_parse_header_body(&token,&space,&comment,bufpos,bufsiz - (bufpos - buf),&pos,end-pos,m->eol,m->eolen,NULL,NULL);

				if (space) {
					if (boundary)
						break;
					else
						continue;
				}

				if ((token && *token == ';' && len == 1)
				|| (comment && *comment == ';' && len == 1))
					break;	/* FIXME: What if the single
						 * semicolon was quoted?
						 */

				if (!boundary)
					boundary	= bufpos;

				bufpos	+= len;
			} while(len);

			len	= (boundary)? bufpos - boundary : 0;

			if (len) {
				hdr->ctype.boundary	= arena_strndup(m->arena,strntolower(boundary,len),len);
				hdr->ctype.boundarylen	= len;

				if (!hdr->ctype.boundary)
					goto sysfail;
			}
		} /* if (boundary) */
	} while (len);

	return hdr;
sysfail:
	/*
	 * Cleanup so we don't have any bad string lengths.
	 */
	hdr->ctype.type		= NULL;
	hdr->ctype.typelen	= 0;

	hdr->ctype.charset	= NULL;
	hdr->ctype.charsetlen	= 0;

	hdr->ctype.boundary	= NULL;
	hdr->ctype.boundarylen	= 0;

	(void)mime_seterror(m,MIME_ESYSTEM,errno,MIME_NOSTRERROR);

	return NULL;
} /* mime_header_parse_ctype() */


/* mime_header_parse_ctenc()
 *
 * Simple MIME Content-Transfer-Encoding parser. Typically the header
 * should have the form
 *
 * 	"Content-Transfer-Encoding:" [base64|quoted-printable|7bit|8bit]
 *
 * I've yet to see anything else.
 *
 */
static struct mime_header *mime_header_parse_ctenc(struct mime *m, struct mime_entity *ent, struct mime_header *hdr) {
	static __thread char *buf;
	static __thread size_t bufsiz;
	const char *pos, *end;
	char *token, *space, *comment;
	size_t len;

	hdr->ctenc.encoding	= NULL;
	hdr->ctenc.encodinglen	= 0;

	if (bufsiz < hdr->bodylen) {
		char *tmp;

		tmp	= realloc(buf,hdr->bodylen);

		if (!tmp)
			return mime_seterror(m,MIME_ESYSTEM,errno,"realloc(%p,%lu)",(void *)buf,(unsigned long)hdr->bodylen), (void *)0;

		buf	= tmp;
		bufsiz	= hdr->bodylen;
	}

	pos	= hdr->body;
	end	= hdr->body + hdr->bodylen;

	do {
		len	= mime_parse_header_body(&token,&space,&comment,buf,bufsiz,&pos,end-pos,m->eol,m->eolen,NULL,NULL);
	} while (len && !token);

	if (!token)
		return hdr;

	hdr->ctenc.encoding	= arena_strndup(m->arena,strntolower(token,len),len);
	hdr->ctenc.encodinglen	= len;

	if (!hdr->ctenc.encoding)
		goto sysfail;

	return hdr;	
sysfail:
	hdr->ctenc.encoding	= NULL;
	hdr->ctenc.encodinglen	= 0;

	(void)mime_seterror(m,MIME_ESYSTEM,errno,MIME_NOSTRERROR);

	return NULL;
} /* mime_header_parse_ctenc() */


#if 0
static struct mime_header *mime_header_add(struct mime *m, struct mime_entity *ent, const char *line, size_t len) {
	struct mime_header *hdr;
	size_t bufsiz	= MAX(len,MIME_DEFAULT_HDRBUFSIZ);

	hdr	= malloc(offsetof(typeof(*hdr),buffer) + bufsiz);

	if (!hdr)
		return mime_seterror(m,MIME_ESYSTEM,errno,"malloc(%lu)",(unsigned long)offsetof(typeof(*hdr),buffer) + bufsiz), (void *)0;

	hdr->bufpos	= hdr->buffer;
	hdr->bufsiz	= bufsiz;

	hdr->raw	= memcpy(hdr->bufpos,line,len);
	hdr->rawlen	= len;
	hdr->bufpos	+= len;

	hdr->name	= hdr->colon
			= hdr->body
			= hdr->u8body
			= NULL;

	hdr->u16body	= NULL;

	hdr->namelen	= hdr->colonlen
			= hdr->bodylen
			= hdr->u8bodylen
			= hdr->u16bodylen
			= 0;

	hdr->position	= mime_offset_initializer;

	hdr->position.lineno	= m->lineno;
	hdr->position.offset	= m->offset;

	if (!mime_parse_header(&hdr->name,&hdr->namelen,&hdr->colon,&hdr->colonlen,&hdr->body,&hdr->bodylen,hdr->raw,hdr->rawlen)) {
		(void)mime_seterror(m,MIME_ESYSTEM,errno,"mime_parse_header(%.*s)",(int)len,line);
		free(hdr);
		return NULL;
	}

	CIRCLEQ_INSERT_TAIL(&ent->headers,hdr,cqe);

	return hdr;
} /* mime_header_add() */
#endif /* 0 */


static struct mime_header *mime_header_add(struct mime *m, struct mime_entity *ent, const char *line, size_t len, struct mime_header *before) {
	struct mime_header *hdr;
	enum mime_errno err;

	hdr	= arena_malloc(m->arena,sizeof *hdr);

	if (!hdr)
		return mime_seterror(m,MIME_ESYSTEM,errno,"arena_malloc(%lu)",(unsigned long)sizeof *hdr), (void *)0;

	*hdr		= mime_header_initializer;

	hdr->raw	= arena_strndup(m->arena,line,len);

	if (!hdr->raw)
		return mime_seterror(m,MIME_ESYSTEM,errno,"arena_strndup"), (void *)0;

	hdr->rawlen	= len;

	hdr->position.lineno	= m->lineno;
	hdr->position.offset	= m->offset;
	hdr->position.unixno	= m->unixno;

	err	= mime_edit_header_set_createdby(m,mime_edit_base,hdr);

	if (MIME_FAILURE(err))
		return arena_free(m->arena,hdr->raw), arena_free(m->arena,hdr), (void *)0;

	hdr->parent	= ent;

	if (before)
		CIRCLEQ_INSERT_BEFORE(&ent->headers,before,hdr,cqe);
	else
		CIRCLEQ_INSERT_TAIL(&ent->headers,hdr,cqe);

	return hdr;
} /* mime_header_add() */


static enum mime_errno mime_header_del(struct mime *m,struct mime_header *hdr) {
	struct mime_entity *ent	= NULL;

	if (hdr)
		ent	= hdr->parent;

	if (!m || !hdr || !ent)	
		return mime_seterror(m,MIME_ESYSTEM,EINVAL,"mime_header_del(struct mime *: %p,struct mime_header *: %p,(struct mime_header *)->parent: %p)",(void *)m,(void *)hdr,(void *)ent);

	CIRCLEQ_REMOVE(&ent->headers,hdr,cqe);

	return MIME_ESUCCESS;
} /* mime_header_del() */


/* mime_header_finalize()
 *
 * Finalize a header.
 */
static enum mime_errno mime_header_finalize(struct mime *m, struct mime_entity *ent, struct mime_header *hdr) {
	hdr->position.nspan	= m->lineno - hdr->position.lineno;
	hdr->position.nbytes	= m->offset - hdr->position.offset;
	hdr->position.nunix	= m->unixno - hdr->position.unixno;

	if (!mime_parse_header(&hdr->name,&hdr->namelen,&hdr->colon,&hdr->colonlen,&hdr->body,&hdr->bodylen,hdr->raw,hdr->rawlen))
		return mime_seterror(m,MIME_ESYNTAX,"%.*s",(int)MIN(16,hdr->rawlen),hdr->raw);

	if (0 == strlcasecmp(hdr->name,hdr->namelen,"content-type",sizeof "content-type" - 1)) {
		hdr	= mime_header_parse_ctype(m,ent,hdr);

		if (!hdr)
			return mime_errno(m);
	} else if (0 == strlcasecmp(hdr->name,hdr->namelen,"content-transfer-encoding",sizeof "content-transfer-encoding" - 1)) {
		hdr	= mime_header_parse_ctenc(m,ent,hdr);

		if (!hdr)
			return mime_errno(m);
	}

	hdr->fixed	= 1;

	return MIME_ESUCCESS;
} /* mime_header_finalize() */


size_t mime_header_decode(struct mime *m, char *buf, size_t buflen, const struct mime_header *hdr, enum mime_errno *err) {
	return mime_decode_header(buf,buflen,hdr->body,hdr->bodylen,m,err);
} /* mime_header_decode() */


struct mime_entity *mime_header_parent(struct mime *m, struct mime_header *hdr) {
	return hdr->parent;
} /* mime_header_parent() */


struct mime_header *mime_header_first(struct mime *m, struct mime_entity *ent, struct mime_edit *e) {
	struct mime_header *hdr;

	CIRCLEQ_FOREACH(hdr,&ent->headers,cqe) {
		if (hdr->fixed && mime_edit_hasheader_inline(m,e,hdr))
			return hdr;
	}

	return NULL;
} /* mime_header_first() */


struct mime_header *mime_header_last(struct mime *m, struct mime_entity *ent, struct mime_edit *e) {
	struct mime_header *hdr;

	CIRCLEQ_FOREACH_REVERSE(hdr,&ent->headers,cqe) {
		if (hdr->fixed && mime_edit_hasheader_inline(m,e,hdr))
			return hdr;
	}

	return NULL;
} /* mime_header_last() */


struct mime_header *mime_header_next(struct mime *m, struct mime_header *hdr, struct mime_edit *e) {
	struct mime_header *nxt	= hdr;

	while ((nxt = CIRCLEQ_NEXT(nxt,cqe)) != CIRCLEQ_END(&hdr->parent->headers)) {
		if (nxt->fixed && mime_edit_hasheader_inline(m,e,nxt))
			return nxt;
	}

	return NULL;
} /* mime_header_next() */


struct mime_header *mime_header_prev(struct mime *m, struct mime_header *hdr, struct mime_edit *e) {
	struct mime_header *prv	= hdr;

	while ((prv = CIRCLEQ_PREV(prv,cqe)) != CIRCLEQ_END(&hdr->parent->headers)) {
		if (prv->fixed && mime_edit_hasheader_inline(m,e,prv))
			return prv;
	}

	return NULL;
} /* mime_header_prev() */

/*
 * TODO: It would be preferable to keep headers sorted by name in a tree and
 * duplicates linked together directly. That way name lookup would take
 * significantly less than O(n). However, it's only important if a message
 * is maliciously trying to make things difficult. In all other cases
 * performance should be just fine.
 */

struct mime_header *mime_header_first_byname(struct mime *m, struct mime_entity *ent, const char *nam, size_t namlen, struct mime_edit *e) {
	struct mime_header *hdr;

	CIRCLEQ_FOREACH(hdr,&ent->headers,cqe) {
		if (hdr->fixed && namlen == hdr->namelen && 0 == strlcasecmp(nam,namlen,hdr->name,hdr->namelen) && mime_edit_hasheader_inline(m,e,hdr))
			return hdr;
	}

	return NULL;
} /* mime_header_first_byname() */


struct mime_header *mime_header_last_byname(struct mime *m, struct mime_entity *ent, const char *nam, size_t namlen, struct mime_edit *e) {
	struct mime_header *hdr;

	CIRCLEQ_FOREACH_REVERSE(hdr,&ent->headers,cqe) {
		if (hdr->fixed && namlen == hdr->namelen && 0 == strlcasecmp(nam,namlen,hdr->name,hdr->namelen) && mime_edit_hasheader_inline(m,e,hdr))
			return hdr;
	}

	return NULL;
} /* mime_header_first_byname() */


struct mime_header *mime_header_next_byname(struct mime *m, struct mime_header *hdr, struct mime_edit *e) {
	struct mime_header *nxt	= hdr;

	while ((nxt = CIRCLEQ_NEXT(nxt,cqe)) != CIRCLEQ_END(&hdr->parent->headers)) {
		if (nxt->fixed && hdr->namelen == nxt->namelen && 0 == strlcasecmp(nxt->name,nxt->namelen,hdr->name,hdr->namelen) && mime_edit_hasheader_inline(m,e,nxt))
			return nxt;
	}

	return NULL;
} /* mime_header_next_byname() */


struct mime_header *mime_header_prev_byname(struct mime *m, struct mime_header *hdr, struct mime_edit *e) {
	struct mime_header *prv	= hdr;

	while ((prv = CIRCLEQ_PREV(prv,cqe)) != CIRCLEQ_END(&hdr->parent->headers)) {
		if (prv->fixed && hdr->namelen == prv->namelen && 0 == strlcasecmp(prv->name,prv->namelen,hdr->name,hdr->namelen) && mime_edit_hasheader_inline(m,e,prv))
			return prv;
	}

	return NULL;
} /* mime_header_prev_byname() */

