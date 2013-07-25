dnl ==========================================================================
dnl libmime/src/mime.h.m4 - Streaming Event MIME Message Parser in C
dnl --------------------------------------------------------------------------
dnl Copyright (c) 2004, 2005, 2006  Barracuda Networks, Inc.
dnl
dnl Permission is hereby granted, free of charge, to any person obtaining a
dnl copy of this software and associated documentation files (the
dnl "Software"), to deal in the Software without restriction, including
dnl without limitation the rights to use, copy, modify, merge, publish,
dnl distribute, sublicense, and/or sell copies of the Software, and to permit
dnl persons to whom the Software is furnished to do so, subject to the
dnl following conditions:
dnl
dnl The above copyright notice and this permission notice shall be included
dnl in all copies or substantial portions of the Software.
dnl
dnl THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
dnl OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
dnl MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
dnl NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
dnl DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
dnl OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
dnl USE OR OTHER DEALINGS IN THE SOFTWARE.
dnl --------------------------------------------------------------------------
dnl History
dnl
dnl 2006-02-01 (william@25thandClement.com)
dnl 	Published by Barracuda Networks, originally authored by
dnl 	employee William Ahern (wahern@barracudanetworks.com).
dnl --------------------------------------------------------------------------
dnl Description
dnl
dnl Central standlone libmime header. All interfaces are declared here,
dnl internal and external.
dnl --------------------------------------------------------------------------
dnl Instructions
dnl
dnl This meta header can build two different versions of mime.h:
dnl 	1) Internal declarations/definitions not desired externally
dnl 	2) External declarations/definitions not desired internally
dnl
dnl From M4, define MODE to be `internal' or `external'.
dnl
dnl ==========================================================================
dnl
define(EXTERN,ifelse(MODE,external,`$*'))dnl
define(INTERN,ifelse(MODE,internal,`$*'))dnl
define(UNICODE,ifelse(MODE,internal,`$*',
`#ifdef UTYPE_H'
`$*'dnl
`#endif /* UTYPE_H */'
))dnl
/*
 * DO NOT EDIT DO NOT EDIT DO NOT EDIT DO NOT EDIT DO NOT EDIT DO NOT EDIT
 * NOT EDIT DO NOT EDIT DO NOT EDIT DO NOT EDIT DO NOT EDIT DO NOT EDIT DO
 * EDIT DO NOT EDIT DO NOT EDIT DO NOT EDIT DO NOT EDIT DO NOT EDIT DO NOT
 *
 * This file was generated on esyscmd(`date | awk ''{printf("%s",$0)}''').
 *
 * ==========================================================================
 * libmime/src/mime.h - Streaming Event MIME Message Parser in C
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
 * Instructions
 *
 * Required Def/Decl	Suggested Include
 * ----------------------------------------------------
 * size_t		<stdlib.h>
 * FILE			<stdio.h>
 * bool			<stdbool.h>
 *
 * Optional Def/Decl	Suggested Include
 * ----------------------------------------------------
 * UChar		<unicode/utypes.h>
 * ==========================================================================
 */
#ifndef MIME_H
#define MIME_H


INTERN(dnl
#ifndef MIME_DEFAULT_LOCALE
#define MIME_DEFAULT_LOCALE		en_US
#endif

#ifndef MIME_DEFAULT_ENCODING
#define MIME_DEFAULT_ENCODING		iso-8859-1
#endif

#ifndef MIME_DEFAULT_LIBPATH
#define MIME_DEFAULT_LIBPATH
#endif

#ifndef MIME_DEFAULT_LINEBREAK
#define MIME_DEFAULT_LINEBREAK		\r\n
#endif

#ifndef MIME_DEFAULT_ARNBUFSIZ		/* Minimum Arena size */
#define MIME_DEFAULT_ARNBUFSIZ		4096
#endif


)dnl


struct mime;
/* Declaration for MIME object, which is always a pointer to a struct mime */

struct mime_entity;
/* Declaration for MIME Entity object. */

struct mime_header;
/* Declaration for MIME Header object. */

struct mime_edit;
/* Declaration for MIME Edit object. */


#define MIME_SUCCESS(e)	(!MIME_FAILURE(e))
#define MIME_FAILURE(e)	((e) & MIME_EBOUNDARY)
#define MIME_WARNING(e) ((e) & MIME_WBOUNDARY)
#define MIME_MESSAGE(e) ((e) & MIME_MBOUNDARY)

enum mime_errno {
	MIME_ESUCCESS	= 0,		/* No error */

	MIME_EBOUNDARY	= 0x0400,	/* 0x0400-0x07ff (1024-2047) */
	MIME_ESYSTEM,			/* Check C errno */
	MIME_EUNICODE,			/* Check ICU errno */
	MIME_ELOCALE,			/* Bad locale specifier */
	MIME_EENCODING,			/* Bad encoding specifier */
	MIME_ESYNTAX,			/* Bad syntax */
	MIME_EASSERTION,		/* Missed assertion */

	MIME_WBOUNDARY	= 0x0800,	/* 0x0800-0x0bff (2048-3071) */
	MIME_WUNICODE,			/* Check ICU errno */
	MIME_WLOCALE,			/* Bad local specifier */
	MIME_WENCODING,			/* Bad encoding specifier */
	MIME_WDUPLICATE_BOUNDARY,	/* Duplicate boundary */

	MIME_MBOUNDARY	= 0x1000,	/* 0x1000-0x13ff (4096-5119) */
	MIME_MUNICODE,			/* Check ICU errno */
};

enum mime_errno mime_errno(struct mime *m);
/*
 * Return the last MIME errno associated with the MIME object, or the last
 * global MIME errno if the MIME object is NULL.
 */

const char *mime_strerror(enum mime_errno e, struct mime *m);
/*
 * Return a string representation of the MIME errno. If the MIME errno
 * passed was returned as a result of a function which took a MIME object
 * then provide that associated MIME object, otherwise pass NULL.
 */

INTERN(

#define MIME_NOSTRERROR	((const char *)"")
/*
 * Pass as the format specifier to mime_seterror() for an empty context
 * description.
 */

static __thread int last_errno;
/*
 * Store the last errno so it doesn't get munged when we return a
 * MIME_ESYSTEM errno.
 */

static __thread UErrorCode last_icu_errno;
/*
 * Store the last ICU errno for interfaces that don't take a MIME context.
 */

static __thread enum mime_errno last_mime_errno;
/*
 * Store the last MIME errno for interfaces that don't take a MIME context.
 */

static __thread char last_error_descr[256];
/* Store a contextual description of the last error. */

static UErrorCode mime_icu_errno(struct mime *m);

static int mime_sys_errno(struct mime *m);

static enum mime_errno mime_seterror(struct mime *m, enum mime_errno e, ...);

)dnl INTERN


INTERN(

static __thread struct pool *mime_bufs;
/*
 * Per-thread buffer pool.
 */

) dnl INTERN


INTERN(
#define MIME_OFFSET_INITIALIZER	((struct mime_offset){.lineno = 0, .nspan = 0, .offset = 0, .nbytes = 0, .unixno = 0, .nunix = 0})
)

INTERN(const) struct mime_offset {
	EXTERN(const) size_t lineno;	/* lineno from whence object began */
	EXTERN(const) size_t nspan;	/* # of lines spanned by object */

	EXTERN(const) size_t offset;	/* byte offset object started at */
	EXTERN(const) size_t nbytes;	/* # of bytes object spanned */

	EXTERN(const) size_t unixno;	/* Unix lineno from when object began */
	EXTERN(const) size_t nunix;	/* # of Unix lines spanned by object */
} INTERN(`mime_offset_initializer = {
	.lineno	= 0,
	.nspan	= 0,
	.offset	= 0,
	.nbytes	= 0,
	.unixno	= 0,
	.nunix	= 0
}');


struct mime_entity {
	EXTERN(const) char *EXTERN(const) name;		/* boundary marker of parent */
	EXTERN(const) size_t namelen;

	EXTERN(const) char *EXTERN(const) type;		/* Content-Type: MIME type */
	EXTERN(const) size_t typelen;

	EXTERN(const) char *EXTERN(const) charset;	/* Content-Type: charset */
	EXTERN(const) size_t charsetlen;

	EXTERN(const) char *EXTERN(const) boundary;	/* Content-Type: boundary marker */
	EXTERN(const) size_t boundarylen;

	EXTERN(const) char *EXTERN(const) encoding;	/* Content-Transfer-Encoding: */
	EXTERN(const) size_t encodinglen;

	struct mime_offset position;

	INTERN(
		CIRCLEQ_HEAD(,mime_header) headers;
		TAILQ_HEAD(mime_entities,mime_entity) entities;
		TAILQ_ENTRY(mime_entity) tqe;	/* Hierarchical entry */
		TAILQ_ENTRY(mime_entity) tqe0;	/* Flat entry */

		uLong key;			/* CRC32 hash of boundary */
		int intree;			/* Whether in tree */

		RB_ENTRY(mime_entity) rbe;	/* Sorted entry by boundary */
		LIST_HEAD(,mime_entity) duplicates;
		LIST_ENTRY(mime_entity) le;	/* Duplicate boundary entry */
		struct mime_entity *dupof;

		struct mime_entity *parent;

		struct {
			int ctype_istext;	/* Content-type: text/foo */
			int ctenc_isbase64;	/* Content-transfer-encoding: base64 */
			int ctenc_isquoted;	/* Content-transfer-encoding: quoted-printable */
		} hints;
	)
}; /* struct mime_entity */

INTERN(dnl

#define MIME_ENTITY_INITIALIZER(e) (typeof(e)){				\
	.headers	= CIRCLEQ_HEAD_INITIALIZER((e).headers),	\
	.entities	= TAILQ_HEAD_INITIALIZER((e).entities),		\
	.duplicates	= LIST_HEAD_INITIALIZER((e).duplicates),	\
	/* Everything else zero. */					\
}

)dnl INTERN


INTERN(static const) struct mime_header {
	EXTERN(const) char *EXTERN(const) raw;	/* Actual header, including CRLF(s) */
	EXTERN(const) size_t rawlen;

	EXTERN(const) char *EXTERN(const) name;	/* Header name */
	EXTERN(const) size_t namelen;

	EXTERN(const) char *EXTERN(const) colon;
	EXTERN(const) size_t colonlen;
	/*
	 * Colon position. Use to differentiate between a Unix 'From ' and a
	 * regular 'From:'
	 */

	EXTERN(const) char *EXTERN(const) body;
	EXTERN(const) size_t bodylen;
	/*
	 * Everything else (or nothing at all).
	 */

	struct mime_offset position;

	INTERN(
		int fixed;	/* Has this structure been finalized? */

		unsigned char *deletedby;
				/* Bitmap of deletion edit contexts. */
		unsigned char *createdby;
				/* Bitmap of addition edit contexts. */

		intptr_t edit_max;
				/* Current maximum edit bitmap index. */
				
		union {
			struct {
				char *type;	/* Content-Type: MIME type */
				size_t typelen;

				char *charset;	/* Content-Type: charset */
				size_t charsetlen;

				char *boundary;	/* Content-Type: boundary market */
				size_t boundarylen;
			} ctype;

			struct {
				char *encoding;	/* Content-Transfer-Encoding: */
				size_t encodinglen;
			} ctenc;
		};

		char *u8body;		/* UTF-8 represenation of body */
		size_t u8bodylen;

		UChar *u16body;		/* UTF-16 representation of body */
		size_t u16bodylen;

		struct mime_entity *parent;

		CIRCLEQ_ENTRY(mime_header) cqe;
	)
INTERN(`} mime_header_initializer = {
	.raw		= NULL,
	.rawlen		= 0,
	.name		= NULL,
	.namelen	= 0,
	.colon		= NULL,
	.colonlen	= 0,
	.body		= NULL,
	.bodylen	= 0,
	.position	= MIME_OFFSET_INITIALIZER,
	.fixed		= 0,
	.deletedby	= NULL,
	.createdby	= NULL,
	.edit_max	= -1,
	.u8body		= NULL,
	.u8bodylen	= 0,
	.u16body	= NULL,
	.u16bodylen	= 0,
')}; /* struct mime_header */


dnl
dnl The MIME event structure is allocated externally. We can hide the inner
dnl members by padding out the external definition and using an anonymous
dnl union to define the inner members, seamlessly keeping proper alignment.
dnl
struct mime_event {
	union {
		struct {
			unsigned long entity:1;
			unsigned long eoe:1;
			unsigned long unixfrom:1;
			unsigned long boundary:1;
			unsigned long header:1;
			unsigned long eoh:1;
			unsigned long body:1;
			unsigned long text:1;
		} name;
		unsigned long all:8;
	} type;

	union {
		void (*entity)(struct mime_entity *ent, struct mime_offset *pos, void *arg);
		void (*eoe)(struct mime_entity *ent, struct mime_offset *pos, void *arg);

		void (*unixfrom)(struct mime_entity *ent, const char *line, size_t len, struct mime_offset *pos, void *arg);
		void (*boundary)(struct mime_entity *ent, const char *line, size_t len, struct mime_offset *pos, void *arg);

		void (*header)(struct mime_entity *ent, struct mime_header *hdr, struct mime_offset *pos, void *arg);
		void (*eoh)(struct mime_entity *ent, struct mime_offset *pos, void *arg);

		void (*body)(struct mime_entity *ent, const char *line, size_t len, struct mime_offset *pos, void *arg);
		void (*text)(struct mime_entity *ent, const char *text, size_t len, struct mime_offset *pos, void *arg);
	} cb;

	void *arg;

	EXTERN(
		const char pad[64];
	) dnl Padding for our hidden data structures. 

	INTERN(
		union {
			struct {
				LIST_ENTRY(mime_event) le;
			};

			char pad[64];
		};		
	) dnl GNU GCC supports anonymous unions and structures.

}; /* struct mime_event */


struct mime_options {
	char locale[64];	/* Locale hints, colon separated */

	char encoding[256];	/* Encoding hints, colon separated */

	char libpath[128];	/* Module search paths, colon separated */

	char linebreak[8];	/* Line separator: \n, \r\n */
	
	size_t arenasiz;	/* Arena size */
};

extern const struct mime_options mime_defaults;
/* Use to initialize a struct mime_options to create a MIME Options object */

dnl
dnl enum mime_errno mime_options_load(struct mime_options *opts, const char *path, const char *base);
dnl /*
dnl  * Load options from a file into a MIME Options object. Optionally specify
dnl  * base by passing a C string. Base specifies the name of a named
dnl  * [bracketed] subsection. The former two name=value pairs are equivalent.
dnl  *
dnl  * locale	= en_US
dnl  *
dnl  * [country/United States/mime]
dnl  * 	locale	= en_US
dnl  *
dnl  * country/United States/mime/locale = en_US
dnl  *
dnl  */
dnl

struct mime *mime_open(const struct mime_options *opts);
/*
 * Create a new MIME object using the provided MIME Options object.
 */

enum mime_errno mime_close(struct mime *m);
/*
 * Destroy and free all resources associated with MIME object.
 */

enum mime_errno mime_locale_set(struct mime *m, const char *locale);
enum mime_errno mime_locale_add(struct mime *m, const char *locale);
/*
 * Set or add a locale hint for a MIME object.
 */


enum mime_errno mime_encoding_set(struct mime *m, const char *encoding);
enum mime_errno mime_encoding_add(struct mime *m, const char *encoding);
/*
 * Set or add an encoding hint for a MIME object.
 */

enum mime_errno mime_writeln(struct mime *m, const char *line, size_t linelen);
enum mime_errno mime_write(struct mime *m, const char *buf, size_t buflen);
enum mime_errno mime_readfile(struct mime *m, const char *path);
/*
 * Provide MIME content for a MIME object to parse.
 */


#define MIME_EV_UNIXFROM	unixfrom
#define MIME_EV_ENTITY		entity
#define MIME_EV_EOE		eoe
#define MIME_EV_BOUNDARY	boundary
#define MIME_EV_HEADER		header
#define MIME_EV_EOH		eoh
#define MIME_EV_BODY		body
#define MIME_EV_TEXT		text
/*
 * Make the string literals look like typical constants.
 */


#define MIME_EVENT_SET(e,t,f,a) do {					\
	(e)->type.all		= 0;					\
	(e)->type.name.t	= 1;					\
	(e)->cb.t		= (f);					\
	(e)->arg		= (a);					\
} while(0)

#define mime_event_set(e,t,f,a) MIME_EVENT_SET(e,t,f,a)
/*
 * Set the MIME Event object (e) to specify the event (t)--literal
 * string--using the callback function (f) and callback context token (a).
 *
 * Example:
 * 	struct mime_event ev;
 *
 *	mime_event_set(&ev,MIME_EV_HEADER,my_catch_func,my_cnxt);
 */


#define mime_event_isset(e,t) ((e)->type.name.t)
/*
 * Return whether the specified event is set or not.
 *
 * Example:
 * 	struct mime_event ev;
 *
 * 	if (mime_event_isset(&ev,MIME_EV_HEADER))
 * 		...
 */


enum mime_errno mime_event_add(struct mime *m, struct mime_event *ev);
enum mime_errno mime_event_del(struct mime *m, struct mime_event *ev);
/*
 * Add or remove a MIME Event object to a MIME object. MIME Event object
 * (ev) must have been initialized using the mime_event_set() interface.
 */


size_t mime_header_decode(struct mime *m, char *buf, size_t buflen, const struct mime_header *hdr, enum mime_errno *);
UNICODE(
size_t mime_header_udecode(struct mime *m, UChar *buf, size_t buflen, const struct mime_header *hdr, enum mime_errno *);
)

struct mime_entity *mime_header_parent(struct mime *m, struct mime_header *hdr);
/*
 * Return the parent entity of a header.
 *
 * @m		MIME object.
 * @hdr		MIME Header object.
 */

struct mime_header *mime_header_first(struct mime *m, struct mime_entity *ent, struct mime_edit *e);
/*
 * Return the first header in entity @ent, or NULL if the entity has no
 * headers.
 *
 * @m		MIME object.
 * @ent		MIME Entity object.
 * @e		MIME Edit object.
 */

struct mime_header *mime_header_last(struct mime *m, struct mime_entity *ent, struct mime_edit *e);
/*
 * Return the last header in entity @ent, or NULL if the entity has no
 * headers.
 *
 * @m		MIME object.
 * @ent		MIME Entity object.
 * @e		MIME Edit object.
 */

struct mime_header *mime_header_next(struct mime *m, struct mime_header *hdr, struct mime_edit *e);
/*
 * Return the next header in order after @hdr, or NULL if @hdr is the last
 * header.
 *
 * @m		MIME object.
 * @hdr		MIME Header object.
 * @e		MIME Edit object.
 */

struct mime_header *mime_header_prev(struct mime *m, struct mime_header *hdr, struct mime_edit *e);
/*
 * Return the previous header in order before @hdr, or NULL if @hdr is the
 * first header.
 *
 * @m		MIME object.
 * @hdr		MIME Header object.
 * @e		MIME Edit object.
 */

struct mime_header *mime_header_first_byname(struct mime *m, struct mime_entity *ent, const char *nam, size_t namlen, struct mime_edit *e);
/*
 * Return the first header in entity @ent with the given name, or NULL if
 * the entity has no such headers with that name.
 *
 * @m		MIME object.
 * @ent		MIME Entity object.
 * @nam		Header name.
 * @namlen	Header name length.
 * @e		MIME Edit object.
 */

struct mime_header *mime_header_last_byname(struct mime *m, struct mime_entity *ent, const char *nam, size_t namlen, struct mime_edit *e);
/*
 * Return the last header in entity @ent with the given name, or NULL if
 * the entity has no such headers with that name.
 *
 * @m		MIME object.
 * @ent		MIME Entity object.
 * @nam		Header name.
 * @namlen	Header name length.
 * @e		MIME Edit object.
 */

struct mime_header *mime_header_next_byname(struct mime *m, struct mime_header *hdr, struct mime_edit *e);
/*
 * Return the first header in order after @hdr with the same name as
 * @hdr, or NULL if @hdr is the last such header.
 *
 * @m		MIME object.
 * @hdr		MIME Header object.
 * @e		MIME Edit object.
 */

struct mime_header *mime_header_prev_byname(struct mime *m, struct mime_header *hdr, struct mime_edit *e);
/*
 * Return the previous header in order before @hdr with the same name as
 * @hdr, or NULL if @hdr is the first such header.
 *
 * @m		MIME object.
 * @hdr		MIME Header object.
 * @e		MIME Edit object.
 */


INTERN(dnl

static struct mime_header *mime_header_parse_ctype(struct mime *m, struct mime_entity *ent, struct mime_header *hdr);
/*
 * Simple MIME Content-Type parser to locate type/subtype, charset, and
 * boundary marker.
 */

static struct mime_header *mime_header_add(struct mime *m, struct mime_entity *ent, const char *line, size_t len, struct mime_header *before);
/*
 * Add a header to the specified MIME Entity using the content of line to
 * initialize the MIME Header object.
 */

static enum mime_errno mime_header_del(struct mime *m, struct mime_header *hdr);
/*
 * Delete a header from it's parent entity's list.
 *
 * WARNING: This is a dangerous interface. This function is best used near a
 * preceding mime_header_add() call. Pointers to the header must not exist
 * anywhere else.
 */

static enum mime_errno mime_header_finalize(struct mime *m, struct mime_entity *ent, struct mime_header *hdr);
/*
 * Finalize a MIME Header object by doing any post-processing necessary or
 * useful before passing outside of the library. For instance parsing a
 * Content-Type: header into a canonical form for easy access.
 */

)dnl INTERN


extern struct mime_entity mime_entity_zero;
#define MIME_ENTITY_ZERO (&mime_entity_zero)
/*
 * The top most entity; the top message object. (Not technically an entity.)
 */

struct mime_entity *mime_entity_parent(struct mime *m, const struct mime_entity *ent, struct mime_edit *e);
/*
 * Return parent entity, or NULL if not nested.
 */

struct mime_entity *mime_entity_next(struct mime *m, const struct mime_entity *ent, struct mime_edit *e);
/*
 * Return the next sibling entity, or NULL if there are none.
 */

struct mime_entity *mime_entity_prev(struct mime *m, const struct mime_entity *ent, struct mime_edit *e);
/*
 * Return the prev sibling entity, or NULL if there are none.
 */

struct mime_entity *mime_entity_first(struct mime *m, const struct mime_entity *ent, struct mime_edit *e);
/*
 * Return the first embedded child entity, or NULL if there are no children.
 */

struct mime_entity *mime_entity_last(struct mime *m, const struct mime_entity *ent, struct mime_edit *e);
/*
 * Return the last embedded child entity, or NULL if there are no children.
 */

bool mime_entity_isdescendentof(struct mime *m, const struct mime_entity *ent, const struct mime_entity *anscestor, struct mime_edit *e);
/*
 * Determine whether an entity is descended from another entity.
 */


INTERN(dnl

static struct mime_entity *mime_entity_add(struct mime *m, struct mime_entity *parent);
/*
 * Add and initialize an a MIME Entity to MIME object (m), optionally
 * attaching it to MIME Entity parent.
 */

static struct mime_entity *mime_entity_find(struct mime *m, int *final, const char *line, size_t len);
/*
 * Returns the MIME entity specified in the multipart separator. Heavily
 * influenced by sendmail:mime.c:mimeboundary().
 */

static enum mime_errno mime_entity_finalize(struct mime *m, struct mime_entity *ent);
/*
 * Finalize a MIME Entity object by doing any post-processing. For instance,
 * inheriting Content-Type and Content-Transfer-Encoding declarations.
 */

)dnl INTERN

EXTERN(extern) struct mime_edit *mime_edit_base;
EXTERN(extern) struct mime_edit *mime_edit_all;

#define MIME_EDIT_BASE	(mime_edit_base)
#define MIME_EDIT_ALL	(mime_edit_all)

INTERN(
static inline bool mime_edit_hasheader_inline(struct mime *m, struct mime_edit *e, struct mime_header *hdr);

static inline enum mime_errno mime_edit_header_set_createdby(struct mime *m, struct mime_edit *e, struct mime_header *h);
static inline void mime_edit_header_unset_createdby(struct mime *m, struct mime_edit *e, struct mime_header *h);

static inline enum mime_errno mime_edit_header_set_deletedby(struct mime *m, struct mime_edit *e, struct mime_header *h);
static inline void mime_edit_header_unset_deletedby(struct mime *m, struct mime_edit *e, struct mime_header *h);

static inline enum mime_errno mime_edit_header_growmap(struct mime *m, struct mime_header *h, struct mime_edit *e);
)dnl INTERN


struct mime_edit *mime_edit_open(struct mime *m);
/*
 * Open a new MIME edit context. Returns a MIME Edit object.
 *
 * @m		MIME object.
 */


void mime_edit_close(struct mime *m, struct mime_edit *e);
/*
 * Free resources associated with MIME edit context @e.
 *
 * @m		MIME object.
 * @e		MIME Edit object.
 */


enum mime_errno mime_edit_saveto(struct mime *m, struct mime_edit *e, FILE *fp);
/*
 * Save MIME edits to @fp in Unified Diff format.
 *
 * @m		MIME object.
 * @e		MIME Edit object.
 * @fp		FILE object.
 */


bool mime_edit_hasheader(struct mime *m, struct mime_edit *e, struct mime_header *hdr);
/*
 * Returns true if @hdr is included as part of the @e edit context.
 *
 * @m		MIME object.
 * @e		MIME Edit object.
 * @hdr		MIME Header object.
 */


struct mime_header *mime_edit_addheader(struct mime *m, struct mime_entity *ent, const char *txt, size_t txtlen, struct mime_header *before, struct mime_edit *e);
/*
 * Edit a parsed MIME message by inserting a header into entity @ent.  If
 * @hdr is non-NULL, the header is inserted in order before @hdr, otherwise
 * it is appended after the current last header in @ent. Returns a new MIME
 * Header object on success or NULL on failure.
 *
 * @m		MIME object.
 * @ent		MIME Entity object.
 * @txt		The raw text of the header including name, colon, body and
 * 		any embedded CRLF pairs.
 * @txtlen	Length of @txt.
 * @before	Optional placement reference.
 * @e		Optional MIME Edit object.
 */


enum mime_errno mime_edit_delheader(struct mime *m, struct mime_header *hdr, struct mime_edit *e);
/*
 * Edit a parsed MIME message by deleting a specific header.
 *
 * @m		MIME object.
 * @hdr		MIME Header object.
 * @e		Optional MIME Edit object.
 */



INTERN(dnl

static bool mime_parse_isheader(const char *line, size_t len);
static bool mime_parse_isfold(const char *line, size_t len);
static bool mime_parse_isfrom(const char *line, size_t len);
static bool mime_parse_isseparator(const char *line, size_t len);
static bool mime_parse_isencoded_word(const char *line, size_t len);
static inline bool mime_parse_islinebreak(const char *str, size_t slen, const char *brk, size_t blen);

size_t mime_parse_header_body(char **token, char **space, char **comment, char *buf, size_t buflen, const char **line, size_t len, const char *linebreak, size_t linebreaklen, const char *punct, const char *nopunct);
/*
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

static bool mime_parse_header(char **name, size_t *namelen, char **colon, size_t *colonlen, char **body, size_t *bodylen, char *line, size_t len);
/*
 * Split a header into 3 parts: field name, colon separator and field body.
 * Strips trailing field name space, and prefixed field body space.
 */

static char *mime_parse_encoded_word(char **charset, size_t *charlen, char **language, size_t *langlen, char **encoding, size_t *enclen, char **word, size_t *wrdlen, char *str, size_t strlen, const char *linebreak, size_t brklen);
/*
 * Split an encoded word into 4 parts: character set, language [optional],
 * encoding and encoded word. Returns the position at which parsing stopped.
 */

enum mime_parse {
	mime_parse_ini	= 0,
	mime_parse_boe	= 1<<0,
	mime_parse_boh	= 1<<1,
	mime_parse_hdr	= 1<<3,
	mime_parse_eoh	= 1<<6,
	mime_parse_bod	= 1<<9,
	mime_parse_eoe	= 1<<12,
	mime_parse_fin	= 1<<15,
};

static enum mime_errno mime_parse(struct mime *m, const char *line, size_t len);
/*
 * MIME parsing state machine.
 */

)dnl INTERN


#define MIME_DECODE_FLUSH	(1<<28)
#define MIME_DECODE_STRICT	(1<<29)


size_t mime_decode_base64(char *buf, size_t buflen, char *str, size_t strlen, char **end, const char *stop, size_t nstop, unsigned long *state);
/*
 * Base64 decoder. Decoded octets are stored in `buf'. `str' points to a
 * Base64 encoded string.
 *
 * @buf		Output buffer.
 * @buflen	Output buffer length.
 * @str		Input buffer.
 * @strlen	Input buffer length.
 * @end		Position in @str (or one past) at which processing stopped.
 * @stop	Characters to stop processing at.
 * @nstop	Number of characters in @stop.
 * @state	Parsing state. Initialize to 0.
 */
 
size_t mime_decode_quoted(char *buf, size_t buflen, char *str, size_t strlen, char **end, const char *stop, size_t nstop, unsigned long *state);
/*
 * Quoted printable decoder. Decoded octets are stored in `buf'. `str'
 * points to a string containing quoted printable codes.
 *
 * @buf		Output buffer.
 * @buflen	Output buffer length.
 * @str		Input buffer.
 * @strlen	Input buffer length.
 * @end		Position in @str (or one past) at which processing stopped.
 * @stop	Characters to stop processing at.
 * @nstop	Number of characters in @stop.
 * @state	Parsing state. Initialize to 0.
 */


size_t mime_decode_script(char *buf, size_t buflen, char *text, size_t textlen, const char *hint, size_t hintlen, int noguess, int is8bit, struct mime *m, unsigned long *state, enum mime_errno *err);
/*
 * Attempts to transliterate from an input script encoding to UTF-8 (e.g.
 * from ISO-2022-JP to UTF-8). Returns the length of the decoded output,
 * which may be more than @buflen.  No more than @buflen characters are
 * written, however.
 *
 * @buf		Output buffer.
 * @buflen	Output buffer length.
 * @text	Input buffer.
 * @textlen	Input buffer length.
 * @hint	Input encoding hint (i.e. ISO-2022-JP).
 * @hintlen	Input encoding hint length.
 * @is8bit	Boolean value specifying whether any byte in @text has the
 * 		high bit set.
 * @m		MIME object.
 * @state	Decoding saved state for streaming (unused currently).
 * @err		Returns any error, warnings or messages encountered during
 * 		transliteration. Should be initialized to MIME_ESUCCESS.
 */


size_t mime_decode_header(char *buf, size_t buflen, char *txt, size_t txtlen, struct mime *m, enum mime_errno *err);
/*
 * MIME header decoder. Decodes encoded words and transcodes to Unicode.
 * Returns the length of the decoded output, which may be more than
 * @buflen. No more than @buflen characters are written, however.
 *
 * @buf		Output buffer.
 * @buflen	Output buffer length.
 * @txt		Input buffer.
 * @txtlen	Input buffer length.
 * @m		MIME object.
 * @err		MIME error.
 */


enum mime_errno mime_script_init(struct mime *);
void mime_script_deinit(struct mime *);
/*
 * MIME decode converter list constructor/destructor.
 *
 * @m		MIME object.
 *
 */


const char *mime_script_last_seen(struct mime *);
/*
 * Returns the last charset encountered in any decoding job.
 *
 * @m		MIME object.
 */


INTERN(

static const struct mime_script {
	const char *name;	/* Name of converter. */
	UConverter *ucnv;	/* ICU converter object. */

	UChar *buf;		/* Buffer for storing last conversion. */
	int32_t bufsiz;		/* Buffer size. */
	int32_t buflen;		/* Last conversion length. */

	float confidence;	/* Confidence score. */

	RB_ENTRY(mime_script) rbe;
	LIST_ENTRY(mime_script) le;
	SLIST_ENTRY(mime_script) sle;
} mime_script_initializer;

)dnl INTERN


INTERN(

#define MIME_INIT(m) do {						\
	*(m)		= mime_initializer;				\
	(m)->options	= mime_defaults;				\
	TAILQ_INIT(&(m)->entities);					\
	RB_INIT(&(m)->boundaries);					\
	LIST_INIT(&(m)->events);					\
	LIST_INIT(&(m)->scripts);					\
	RB_INIT(&(m)->script_names);					\
} while(0)

static const struct mime {
	int last_errno;				/* Last System errno */

	UErrorCode last_icu_errno;		/* Last ICU errno */

	enum mime_errno last_mime_errno;	/* Last MIME errno */

	char last_error_descr[256];		/* Last description (see
						 * mime_seterror())
						 */

	char last_decode_script[UCNV_MAX_CONVERTER_NAME_LENGTH];
						/* Name of last script used
						 * to decode something.
						 */

	struct mime_options options;

	const char *eol;
	size_t eolen;

	char *buffer;				/* For input line buffering */
	size_t buflen;
	size_t bufsiz;
	
	unsigned long lineno;			/* Current input line # */
	unsigned long offset;			/* Current input byte offset */
	unsigned long unixno;			/* Current input Unix line # */

	struct mime_entity *last_entity;	/* Current MIME Entity */

	struct {
		enum mime_parse exec;		/* See mime_parse() */
		enum mime_parse done;
	} state;

	TAILQ_HEAD(,mime_entity) entities;	/* Flat list */

	RB_HEAD(mime_bounds,mime_entity) boundaries;
	/*
	 * MIME Entities with boundary marker sorted by boundary marker
	 */

	LIST_HEAD(,mime_event) events;		/* MIME Events */
	unsigned nevents;

	struct {
		struct mime_event entity, body, eoe;
		unsigned long state;
	} text;

	struct arena *arena;

	intptr_t edit_nexti;			/* Next edit index */

	LIST_HEAD(,mime_script) scripts;	/* ICU converters */
	RB_HEAD(mime_script_names,mime_script) script_names;
} mime_initializer = {
	.last_errno		= 0,
	.last_icu_errno		= U_ZERO_ERROR,
	.last_mime_errno	= MIME_ESUCCESS,
	.last_error_descr	= "",
	.last_decode_script	= "ISO-8859-1",
	.eol			= STRINGIFY(MIME_DEFAULT_LINEBREAK),
	.eolen			= sizeof STRINGIFY(MIME_DEFAULT_LINEBREAK),
	.buffer			= NULL,
	.buflen			= 0,
	.bufsiz			= 0,
	.lineno			= 0,
	.offset			= 0,
	.unixno			= 0,
	.last_entity		= NULL,
	.state			= {mime_parse_ini,0},
	.nevents		= 0,
	.arena			= NULL,
	.edit_nexti		= 2,	/* 0 = mime_edit_base, 1 = mime_edit_all */
};

)dnl INTERN


#endif /* MIME_H */
