/* ==========================================================================
 * libmime/src/entity.c - Streaming Event MIME Message Parser in C
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
 * MIME entity parsing and manipulation routines.
 * ==========================================================================
 */


#define MIME_ENTITY_IN_SORTED_TREE(e) ((e)->boundarylen)
/*
 * Determine whether MIME Entity (e) is in the Red-black sorted tree.
 */

static int mime_entity_cmp(struct mime_entity *e1, struct mime_entity *e2) {
	return (e1->key < e2->key)? -1 : (e1->key > e2->key)? 1 : 0;
} /* mime_entity_cmp() */

static int mime_entity_key(const char *str, size_t len) {
	char buf[len];

	(void)memcpy(buf,str,len);

	return crc32(0L,(Bytef *)strntolower(buf,len),len);
} /* mime_entity_key() */


RB_PROTOTYPE(mime_bounds,mime_entity,rbe,mime_entity_cmp)
RB_GENERATE(mime_bounds,mime_entity,rbe,mime_entity_cmp)

#if 0
/* mime_entity_grow()
 *
 * Interface to grow the variable length array buffer of an entitity so we
 * don't have a fixed maximum size for entity meta data. Handles all the
 * pointer redirection since realloc() can return a different address.
 */
static struct mime_entity *mime_entity_grow(struct mime *m, struct mime_entity *ent, size_t need) {
	const size_t bufsiz	= ent->bufsiz + need;
	struct mime_entity *old	= ent;
	struct mime_entity *dup, *dup0, *tmp, *nxt, *nxt0, *curent, *nxtent;
	TAILQ_HEAD(,mime_entity) entities
				= TAILQ_HEAD_INITIALIZER(entities);
	LIST_HEAD(,mime_entity)	duplicates
				= LIST_HEAD_INITIALIZER(duplicates);
	struct mime_header *hdr, *nxthdr;
	CIRCLEQ_HEAD(,mime_header) headers
				= CIRCLEQ_HEAD_INITIALIZER(headers);
	ptrdiff_t bufpos, name, type, charset, boundary, encoding;
	int isdupofself;
	int success	= 0;

	if (bufsiz < ent->bufsiz)	/* Overflow! */
		return mime_seterror(m,MIME_ESYSTEM,EOVERFLOW,"buffer:%lu chunk:%lu",(unsigned long)ent->bufsiz,(unsigned long)need), (void *)0;

	/*
	 * Remove from sibling lists because of indirect pointer addressing,
	 * especially in the queue(3) and tree(3) data structres. Store
	 * their neighbors so we can reinsert later. Neighbors are:
	 *
	 * 	nxt	Neighbor from in the locale entity list
	 * 	nxt0 	Neighbor from the global flat entity list
	 * 	dup0	Neighbor in the boundary duplicate list
	 */
	if (ent->parent) {
		nxt	= TAILQ_NEXT(ent,tqe);
		TAILQ_REMOVE(&ent->parent->entities,ent,tqe);
	} else
		nxt	= NULL;

	/*
	 * Remove from flat entity list.
	 */
	nxt0	= TAILQ_NEXT(ent,tqe0);
	TAILQ_REMOVE(&m->entities,ent,tqe0);

	/*
	 * Relocate children because some pointer into the TAILQ head
	 * structure.
	 */
	for (curent = TAILQ_FIRST(&ent->entities); curent != TAILQ_END(&ent->entities); curent = nxtent) {
		nxtent	= TAILQ_NEXT(curent,tqe);

		TAILQ_REMOVE(&ent->entities,curent,tqe);
		TAILQ_INSERT_HEAD(&entities,curent,tqe);
	}

	/*
	 * Relocate headers because some point into the CIRCLEQ head
	 * structure.
	 */
	for (hdr = CIRCLEQ_FIRST(&ent->headers); hdr != CIRCLEQ_END(&ent->headers); hdr = nxthdr) {
		nxthdr	= CIRCLEQ_NEXT(hdr,cqe);

		CIRCLEQ_REMOVE(&ent->headers,hdr,cqe);
		CIRCLEQ_INSERT_HEAD(&headers,hdr,cqe);
	}

	/*
	 * Remove from the boundary marker structures.
	 */
	dup		= NULL;	/* Silence GCC */
	dup0		= NULL;
	isdupofself	= 0;

	if (ent->intree) {
		isdupofself	= (ent->dupof == ent)? 0 : 1;

		if (isdupofself) {
			if (ent != RB_REMOVE(mime_bounds,&m->boundaries,ent)) {
				(void)mime_seterror(m,MIME_EASSERTION,"failed to remove entity from boundaries tree");
				goto recover;
			}
		}

		dup0	= LIST_NEXT(ent,le);	/* Store neighbor for
						 * in-place reinsertion
						 */

		for (dup = LIST_FIRST(&ent->dupof->duplicates); dup != LIST_END(&ent->dupof->duplicates); dup = tmp) {
			tmp	= LIST_NEXT(dup,le);

			LIST_REMOVE(dup,le);

			if (dup == ent)
				continue;

			LIST_INSERT_HEAD(&duplicates,dup,le);
		}
	} /* if (ent->intree) */


	bufpos		= ent->bufpos - ent->buffer;
	name		= (ent->name)? ent->name - ent->buffer : 0;
	type		= (ent->type)? ent->type - ent->buffer : 0;
	charset		= (ent->charset)? ent->charset - ent->buffer : 0;
	boundary	= (ent->boundary)? ent->boundary - ent->buffer : 0;
	encoding	= (ent->encoding)? ent->encoding - ent->buffer : 0;

	tmp	= realloc(ent,offsetof(typeof(*ent),buffer) + bufsiz);

	if (tmp) {
		success	= 1;

		ent	= tmp;

		ent->bufpos	= ent->buffer + bufpos;
		ent->bufsiz	= bufsiz;

		ent->name	= (ent->name)? ent->buffer + name : NULL;
		ent->type	= (ent->type)? ent->buffer + type : NULL;
		ent->charset	= (ent->charset)? ent->buffer + charset : NULL;
		ent->boundary	= (ent->boundary)? ent->buffer + boundary : NULL;
		ent->encoding	= (ent->encoding)? ent->buffer + encoding : NULL;
	} else
		(void)mime_seterror(m,MIME_ESYSTEM,errno,"realloc(%p,%lu)",(void *)ent,(unsigned long)offsetof(typeof(*ent),buffer) + bufsiz);


	/*
	 * Reinsert into boundary marker structures.
	 */
	if (ent->intree) {
		if (isdupofself) {
			if (NULL != RB_INSERT(mime_bounds,&m->boundaries,ent)) {
				/* Yikes! This should never happen! */
				(void)mime_seterror(m,MIME_EASSERTION,"failed to reinsert entity into boundaries tree");

				LIST_FOREACH(dup,&duplicates,le)
					dup->intree	= 0;
				/* Minimize damage */

				success	= 0;

				assert(0);
			}
		}

		if (ent->dupof == old)
			ent->dupof	= ent;

		LIST_INIT(&ent->duplicates);

		if (!dup0)
			LIST_INSERT_HEAD(&ent->dupof->duplicates,dup,le);

		for (dup = LIST_FIRST(&duplicates); dup != LIST_END(&duplicates); dup = tmp) {
			tmp	= LIST_NEXT(dup,le);

			LIST_REMOVE(dup,le);

			LIST_INSERT_HEAD(&ent->dupof->duplicates,dup,le);

			if (dup->dupof == old)
				dup->dupof	= ent;
		}

		if (dup0)
			LIST_INSERT_BEFORE(dup0,ent,le);
	} /* if (ent->intree) */

recover:
	/*
	 * Re-Relocate headers.
	 */
	CIRCLEQ_INIT(&ent->headers);

	for (hdr = CIRCLEQ_FIRST(&headers); hdr != CIRCLEQ_END(&headers); hdr = nxthdr) {
		nxthdr	= CIRCLEQ_NEXT(hdr,cqe);

		CIRCLEQ_REMOVE(&headers,hdr,cqe);
		CIRCLEQ_INSERT_HEAD(&ent->headers,hdr,cqe);
	}

	/*
	 * Re-Relocate children.
	 */
	TAILQ_INIT(&ent->entities);

	for (curent = TAILQ_FIRST(&entities); curent != TAILQ_END(&entities); curent = nxtent) {
		nxtent	= TAILQ_NEXT(curent,tqe);

		TAILQ_REMOVE(&entities,curent,tqe);
		TAILQ_INSERT_HEAD(&ent->entities,curent,tqe);

		if (curent->parent == old)
			curent->parent	= ent;
	}

	/*
	 * Reinsert into flat entity list.
	 */
	if (nxt0)
		TAILQ_INSERT_BEFORE(nxt0,ent,tqe0);
	else
		TAILQ_INSERT_TAIL(&m->entities,ent,tqe0);

	/*
	 * Reinsert into parent entity list.
	 */
	if (ent->parent) {
		if (nxt)
			TAILQ_INSERT_BEFORE(nxt,ent,tqe);
		else
			TAILQ_INSERT_TAIL(&ent->parent->entities,ent,tqe);
	}

	/*
	 * Finally, update the global top-of-entity-stack pointer.
	 */
	if (m->last_entity == old)
		m->last_entity	= ent;

	return (success)? ent : NULL;
} /* mime_entity_grow() */
#endif


static struct mime_entity *mime_entity_add(struct mime *m, struct mime_entity *parent) {
	struct mime_entity *ent;

	ent	= arena_malloc(m->arena,sizeof *ent);
	
	if (!ent)
		return mime_seterror(m,MIME_ESYSTEM,errno,"arena_malloc(%lu)",(unsigned long)sizeof *ent), (void *)0;

	*ent	= MIME_ENTITY_INITIALIZER(*ent);

	if (parent) {
		ent->name	= arena_strndup(m->arena,parent->boundary,parent->boundarylen);

		if (!ent->name)
			return mime_seterror(m,MIME_ESYSTEM,errno,"arena_strndup"), (void *)0;

		ent->namelen	= parent->boundarylen;
	}

	ent->position	= mime_offset_initializer;

	ent->position.lineno	= m->lineno;
	ent->position.offset	= m->offset;
	ent->position.unixno	= m->unixno;

	TAILQ_INSERT_TAIL(&m->entities,ent,tqe0);

	ent->parent	= parent;

	if (ent->parent)
		TAILQ_INSERT_TAIL(&ent->parent->entities,ent,tqe);

	return ent;
} /* mime_entity_add() */


/*
 * Returns the MIME entity specified in the multipart separator. Heavily
 * influenced by sendmail:mime.c:mimeboundary().
 */
static struct mime_entity *mime_entity_find(struct mime *m, int *isfinal, const char *line, size_t len) {
	const char *pos, *end;
	struct mime_entity tmp, *ent;
	int final;

	if (len == 0)	/* EOF */
		return *isfinal = 1, TAILQ_FIRST(&m->entities);

	if (len < 2 || !mime_parse_isseparator(line,len))
		return NULL;

	pos	= line + 2;
	end	= line + len;

	if (end - pos >= (ptrdiff_t)m->eolen && 0 == memcmp(end - m->eolen,m->eol,m->eolen))
		end	-= m->eolen;	/* Trim linebreak */

	for (end--; end >= pos && (*end == ' ' || *end == '\t');end--)
		;;	/* Trim trailing space */

	end++;

	/*fprintf(stderr,"comparing against: %.*s\n",(int)(end-pos),pos);*/
	
	if (pos >= end)
		return NULL;

	final	= 0;

search:
	tmp.key	= mime_entity_key(pos,end-pos);

	ent	= RB_FIND(mime_bounds,&m->boundaries,&tmp);

	if (ent)
		return *isfinal = final, LIST_FIRST(&ent->duplicates);
		/* Return top of duplicate stack */

	if (!final && end - pos > 4 && end[-1] == '-' && end[-2] == '-') {
		end	-=2;
		final	= 1;
		goto search;
	}

	return NULL;
} /* mime_entity_find() */


/* mime_entity_finalize()
 *
 * Finalize an entity.
 */
static enum mime_errno mime_entity_finalize(struct mime *m, struct mime_entity *ent) {
	enum mime_errno err	= MIME_ESUCCESS;
	struct mime_header *hdr;
	struct mime_entity *dup;

	/*
	 * Loop over the headers looking for useful MIME specific headers
	 * Set entity attributes and internal hints accordingly.
	 *
	 * The last header added becomes the significant header.
	 */
	CIRCLEQ_FOREACH_REVERSE(hdr,&ent->headers,cqe) {
		if (!ent->type && 0 == strlcasecmp(hdr->name,hdr->namelen,"content-type",sizeof "content-type" - 1) && hdr->ctype.typelen) {
			if (hdr->ctype.typelen) {
				ent->type	= arena_strndup(m->arena,hdr->ctype.type,hdr->ctype.typelen);

				if (!ent->type)
					return mime_seterror(m,MIME_ESYSTEM,errno,"arena_strndup");

				ent->typelen	= hdr->ctype.typelen;

				if (0 == strncmp(ent->type,"text/",sizeof "text/" - 1))
					ent->hints.ctype_istext	= 1;
			}

			if (hdr->ctype.charsetlen) {
				ent->charset	= arena_strndup(m->arena,hdr->ctype.charset,hdr->ctype.charsetlen);

				if (!ent->charset)
					return mime_seterror(m,MIME_ESYSTEM,errno,"arena_strndup");

				ent->charsetlen	= hdr->ctype.charsetlen;
			}

			if (hdr->ctype.boundarylen) {
				ent->boundary		= arena_strndup(m->arena,hdr->ctype.boundary,hdr->ctype.boundarylen);

				if (!ent->boundary)
					return mime_seterror(m,MIME_ESYSTEM,errno,"arena_strndup");

				ent->boundarylen	= hdr->ctype.boundarylen;
			}
		} else if (!ent->encoding && 0 == strlcasecmp(hdr->name,hdr->namelen,"content-transfer-encoding",sizeof "content-transfer-encoding" - 1)) {
			if (hdr->ctenc.encodinglen) {
				ent->encoding	= arena_strndup(m->arena,hdr->ctenc.encoding,hdr->ctenc.encodinglen);

				if (!ent->encoding)
					return mime_seterror(m,MIME_ESYSTEM,errno,"arena_strndup");

				ent->encodinglen	= hdr->ctenc.encodinglen;

				if (0 == strcmp(ent->encoding,"base64")) {
					ent->hints.ctenc_isbase64	= 1;
				} else if (0 == strcmp(ent->encoding,"quoted-printable")) {
					ent->hints.ctenc_isquoted	= 1;
				}
			}
		}

		if (ent->type && ent->encoding)
			break;
	}

	if (ent->typelen > sizeof "multipart/" - 1 && 0 == strncasecmp(ent->type,"multipart/",sizeof "multipart/" - 1) && ent->boundarylen) {
		ent->key	= mime_entity_key(ent->boundary,ent->boundarylen);

		dup	= RB_INSERT(mime_bounds,&m->boundaries,ent);

		if (dup)
			err	= mime_seterror(m,MIME_WDUPLICATE_BOUNDARY,"duplicate boundary %.*s in entity starting at line %lu",(int)ent->boundarylen,ent->boundary,(unsigned long)ent->position.lineno);
		else
			dup	= ent;

		LIST_INSERT_HEAD(&dup->duplicates,ent,le);

		ent->dupof	= dup;
		ent->intree	= 1;

		/*
		 * If the entity is multipart, then treat the prologue and
		 * epilogue as type text/plain and set the hint so the text
		 * event fires.
		 */
		 ent->hints.ctype_istext	= 1;
	}

	/*
	 * If it's the root entity and no Content-type header was given,
	 * assume text/plain.
	 */
	if (!ent->parent && !ent->typelen)
		ent->hints.ctype_istext	= 1;

	return err;
} /* mime_entity_finalize() */


struct mime_entity mime_entity_zero	= MIME_ENTITY_INITIALIZER(mime_entity_zero);


bool mime_entity_isdescendentof(struct mime *m, const struct mime_entity *ent, const struct mime_entity *ancestor, struct mime_edit *e) {
	struct mime_entity *prev;

	/*
	 * Walk down the stack
	 */
	for (prev = ent->parent; prev; prev = prev->parent)
		if (prev == ancestor)
			return true;

	return false;
} /* mime_entity_isdescendentof() */


struct mime_entity *mime_entity_parent(struct mime *m, const struct mime_entity *ent, struct mime_edit *e) {
	return ent->parent;
} /* mime_entity_parent() */


struct mime_entity *mime_entity_next(struct mime *m, const struct mime_entity *ent, struct mime_edit *e) {
	if (ent->parent)
		return TAILQ_NEXT(ent,tqe);
	else
		return NULL;
} /* mime_entity_next() */


struct mime_entity *mime_entity_prev(struct mime *m, const struct mime_entity *ent, struct mime_edit *e) {
	if (ent->parent)
		return TAILQ_PREV(ent,mime_entities,tqe);
	else
		return NULL;
} /* mime_entity_prev() */


struct mime_entity *mime_entity_first(struct mime *m, const struct mime_entity *ent, struct mime_edit *e) {
	if (ent == MIME_ENTITY_ZERO)
		return TAILQ_FIRST(&m->entities);
	else
		return TAILQ_FIRST(&ent->entities);
} /* mime_entity_first() */


struct mime_entity *mime_entity_last(struct mime *m, const struct mime_entity *ent, struct mime_edit *e) {
	if (ent == MIME_ENTITY_ZERO)
		return TAILQ_FIRST(&m->entities);
	else
		return TAILQ_LAST(&ent->entities,mime_entities);
} /* mime_entity_last() */

