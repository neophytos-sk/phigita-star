/* ==========================================================================
 * libmime/src/edit.c - Streaming Event MIME Message Parser in C
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
 * Provide per-context "diff" edits of a MIME message.
 * ==========================================================================
 */


struct mime_edit *mime_edit_base	= (void *)(intptr_t)0;
struct mime_edit *mime_edit_all		= (void *)(intptr_t)1;


static inline enum mime_errno mime_edit_header_growmap(struct mime *m, struct mime_header *h, struct mime_edit *to) {
	size_t cursiz	= roundup(howmany(h->edit_max + 1,NBBY),NBBY);
	size_t newsiz	= roundup(howmany((intptr_t)to + 1,NBBY),NBBY);
	intptr_t edit_max;
	unsigned char *deletedby, *createdby;

	if (cursiz >= newsiz)
		return MIME_ESUCCESS;

	edit_max	= (newsiz * NBBY) - 1;
	/*
	 * INFO: Descriptors are indexed from zero so we need to adjust
	 * between "maximum allowable descriptor number" and "maximum number
	 * of descriptors".
	 */

	if (edit_max < h->edit_max)
		return mime_seterror(m,MIME_ESYSTEM,EOVERFLOW,"edit bitmap overflow");

	deletedby	= arena_malloc(m->arena,newsiz);

	if (!deletedby)
		return mime_seterror(m,MIME_ESYSTEM,errno,"arena_malloc");

	createdby	= arena_malloc(m->arena,newsiz);
	
	if (!createdby)
		return mime_seterror(m,MIME_ESYSTEM,errno,"arena_malloc");

	(void)memcpy(deletedby,h->deletedby,cursiz);
	(void)memcpy(createdby,h->createdby,cursiz);

	(void)memset(&deletedby[cursiz],'\0',newsiz - cursiz);
	(void)memset(&createdby[cursiz],'\0',newsiz - cursiz);

	h->deletedby	= deletedby;
	h->createdby	= createdby;

	h->edit_max	= edit_max;

	return MIME_ESUCCESS;
} /* mime_edit_header_growmap() */


static inline bool mime_edit_header_isset_createdby(struct mime_header *h, struct mime_edit *e) {
	return (h->edit_max >= (intptr_t)e && isset(h->createdby,(intptr_t)e));
} /* mime_edit_header_isset_createdby() */


static inline bool mime_edit_header_isset_deletedby(struct mime_header *h, struct mime_edit *e) {
	return (h->edit_max >= (intptr_t)e && isset(h->deletedby,(intptr_t)e));
} /* mime_edit_header_isset_deletedby() */


static inline bool mime_edit_hasheader_inline(struct mime *m, struct mime_edit *e, struct mime_header *h) {
	if (mime_edit_header_isset_deletedby(h,mime_edit_base))
		return false;

	if (e != mime_edit_base && mime_edit_header_isset_deletedby(h,mime_edit_all))
		return false;

	if (mime_edit_header_isset_deletedby(h,e))
		return false;

	if (mime_edit_header_isset_createdby(h,e))
		return true;

	if (mime_edit_header_isset_createdby(h,mime_edit_base))
		return true;

	return false;
} /* mime_edit_hasheader_inline() */


static inline enum mime_errno mime_edit_header_set_createdby(struct mime *m, struct mime_edit *e, struct mime_header *h) {
	enum mime_errno err	= mime_edit_header_growmap(m,h,e);

	if (MIME_FAILURE(err))
		return err;

	setbit(h->createdby,(intptr_t)e);
	
	return MIME_ESUCCESS;
} /* mime_edit_header_set_createdby() */


static inline void mime_edit_header_unset_createdby(struct mime *m, struct mime_edit *e, struct mime_header *h) {
	if ((intptr_t)e <= h->edit_max)
		clrbit(h->createdby,(intptr_t)e);
	
	return /* void */;
} /* mime_edit_header_unset_createdby() */


static inline enum mime_errno mime_edit_header_set_deletedby(struct mime *m, struct mime_edit *e, struct mime_header *h) {
	enum mime_errno err	= mime_edit_header_growmap(m,h,e);

	if (MIME_FAILURE(err))
		return err;

	setbit(h->deletedby,(intptr_t)e);
	
	return MIME_ESUCCESS;
} /* mime_edit_header_set_deletedby() */


static inline void mime_edit_header_unset_deletedby(struct mime *m, struct mime_edit *e, struct mime_header *h) {
	if ((intptr_t)e <= h->edit_max)
		clrbit(h->deletedby,(intptr_t)e);
	
	return /* void */;
} /* mime_edit_header_unset_deletedby() */


struct mime_edit *mime_edit_open(struct mime *m) {
	while (m->edit_nexti == (intptr_t)mime_edit_base || m->edit_nexti == (intptr_t)mime_edit_all)
		m->edit_nexti++;

	return (void *)m->edit_nexti;
} /* mime_edit_open() */


void mime_edit_close(struct mime *m, struct mime_edit *e) {
	return /* void */;
} /* mime_edit_close() */


bool mime_edit_hasheader(struct mime *m, struct mime_edit *e, struct mime_header *h) {
	return mime_edit_hasheader_inline(m,e,h);
} /* mime_edit_hasheader() */


struct mime_header *mime_edit_addheader(struct mime *m, struct mime_entity *ent, const char *txt, size_t txtlen, struct mime_header *before, struct mime_edit *e) {
	struct mime_header *hdr;
	enum mime_errno err;
	const char *pos, *end;

	hdr	= mime_header_add(m,ent,txt,txtlen,before);

	if (!hdr)
		return NULL;

	/*
	 * Normalize the end-of-line marker.
	 */
	if (hdr->rawlen < m->eolen
	||  0 != memcmp(m->eol,&hdr->raw[hdr->rawlen - m->eolen],m->eolen)) {
		off_t copyto		= hdr->rawlen;
		char *p;

		/*
		 * Discard anything which occurs in the EOL string. This
		 * handles the case where the EOL is "\r\n" but there's one
		 * or more trailing "\n" or "\r" characters without having
		 * to know which is which, though it really only works for
		 * that specific case.
		 */
		while (copyto && memchr(m->eol,hdr->raw[copyto - 1],m->eolen))
			copyto--;

		p	= arena_realloc(m->arena,hdr->raw,hdr->rawlen + 1,copyto + m->eolen + 1);

		if (!p) {
			(void)mime_seterror(m,MIME_ESYSTEM,errno,"arena_realloc");
			(void)mime_header_del(m,hdr);

			return NULL;
		}

		memcpy(p + copyto,m->eol,m->eolen);

		hdr->raw		= p;
		hdr->rawlen		= copyto + m->eolen;
		hdr->raw[hdr->rawlen]	= '\0';
	} /* if (memcmp(&hdr->raw[hdr->rawlen - m->eolen],m->eol,m->eolen) */

	err	= mime_header_finalize(m,ent,hdr);

	if (MIME_FAILURE(err)) {
		(void)mime_header_del(m,hdr);

		return NULL;
	}

	hdr->position.nspan	= 0;

	pos	= hdr->raw;
	end	= pos + hdr->rawlen;

	while (pos < end && (pos = memmem(pos,end - pos,m->eol,m->eolen))) {
		hdr->position.nspan++;
		pos	+= m->eolen;
	}

	hdr->position.nbytes	= txtlen;
	hdr->position.nunix	= mime_parse_text_nunix(hdr->raw,hdr->rawlen);

	if (e != mime_edit_base) {
		mime_edit_header_unset_createdby(m,mime_edit_base,hdr);
		mime_edit_header_set_createdby(m,e,hdr);
	}

	return hdr;
} /* mime_edit_addheader() */


enum mime_errno mime_edit_delheader(struct mime *m, struct mime_header *h, struct mime_edit *e) {
	return mime_edit_header_set_deletedby(m,e,h);
} /* mime_edit_delheader() */


enum mime_errno mime_edit_saveto(struct mime *m, struct mime_edit *e, FILE *fp) {
	/*size_t unixno, nadded, ndeleted;*/
	unsigned long srcpos, dstpos;
	signed long dstoff;
	unsigned long srcno, dstno, nsrc, ndst;
	struct mime_entity *ent;
	struct mime_header *hdr;
	const char *pos, *nxt, *end;
	int n;

	srcpos		= 0;
	dstpos		= 0;
	dstoff		= 0;

	TAILQ_FOREACH(ent,&m->entities,tqe0) {
		CIRCLEQ_FOREACH(hdr,&ent->headers,cqe) {
			if (mime_edit_header_isset_createdby(hdr,mime_edit_base)) {
				srcpos	= 1 + hdr->position.unixno;
				dstpos	= 1 + hdr->position.unixno;
			}

			if (mime_edit_header_isset_deletedby(hdr,e)
			||  mime_edit_header_isset_deletedby(hdr,mime_edit_all)
			||  mime_edit_header_isset_deletedby(hdr,mime_edit_base)) {
				if (!mime_edit_header_isset_createdby(hdr,mime_edit_base))
					continue;

				srcno	= srcpos;
				nsrc	= hdr->position.nunix;

				dstno	= dstpos + dstoff;
				ndst	= 0;

				n	= fprintf(fp,"@@ -%lu,%lu +%lu,%lu @@\n",srcno,nsrc,dstno,ndst);

				if (n == -1)
					goto fail;

				pos	= hdr->raw;
				end	= pos + hdr->rawlen;

				while (pos < end && (nxt = memchr(pos,'\n',end - pos))) {
					nxt++;

					n	= fwrite("-",1,sizeof "-" - 1,fp);

					if (n == -1)
						goto fail;

					n	= fwrite(pos,1,nxt - pos,fp);

					if (n == -1)
						goto fail;

					pos	= nxt;
				}

				/*
				 * XXX: Will outputting scraps break the diff?
				 */
				if (pos < end) {
					n	= fwrite("-",1,sizeof "-" - 1,fp);

					if (n == -1)
						goto fail;

					n	= fwrite(pos,1,end - pos,fp);

					if (n == -1)
						goto fail;
				}

				srcpos	+= hdr->position.nunix;
				dstpos	+= hdr->position.nunix;
				dstoff	-= hdr->position.nunix;

				continue;
			} /* mime_edit_header_isset_deletedby() */

			if (mime_edit_header_isset_createdby(hdr,e)
			||  mime_edit_header_isset_createdby(hdr,mime_edit_all)) {
				srcno	= srcpos - 1;
				nsrc	= 0;

				dstno	= dstpos + dstoff;
				ndst	= hdr->position.nunix;

				n	= fprintf(fp,"@@ -%lu,%lu +%lu,%lu @@\n",srcno,nsrc,dstno,ndst);

				if (n == -1)
					goto fail;

				pos	= hdr->raw;
				end	= pos + hdr->rawlen;

				while (pos < end && (nxt = memchr(pos,'\n',end - pos))) {
					nxt++;

					n	= fwrite("+",1,sizeof "+" - 1,fp);

					if (n == -1)
						goto fail;

					n	= fwrite(pos,1,nxt - pos,fp);

					if (n == -1)
						goto fail;

					pos	= nxt;
				}

				if (pos < end) {
					n	= fwrite("+",1,sizeof "+" - 1,fp);

					if (n == -1)
						goto fail;

					n	= fwrite(pos,1,end - pos,fp);

					if (n == -1)
						goto fail;
				}

				dstoff	+= ndst;

				continue;
			} /* mime_edit_header_isset_createdby() */

			if (mime_edit_header_isset_createdby(hdr,mime_edit_base)) {
				srcpos	+= hdr->position.nunix;
				dstpos	+= hdr->position.nunix;
			}
		} /* CIRCLEQ_FOREACH(&ent->headers) */
	} /* TAILQ_FOREACH(&m->entities) */

	return MIME_ESUCCESS;
fail:
	return mime_seterror(m,MIME_ESYSTEM,errno,"fwrite");
} /* mime_edit_saveto() */
