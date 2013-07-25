#include <stdio.h>
#include <stdbool.h>

#include <sys/param.h>

#include <string.h>

#include <zlib.h>

#include "../include/mime.h"


char *entity_name(struct mime *m, struct mime_entity *ent) {
	static char name[256];
	struct mime_entity *nxt;

	*name	= '\0';

	nxt	= mime_entity_first(m,MIME_ENTITY_ZERO,MIME_EDIT_ALL);

	do {
		while (nxt && nxt != ent && !mime_entity_isdescendentof(m,ent,nxt,MIME_EDIT_ALL))
			nxt	= mime_entity_next(m,nxt,MIME_EDIT_ALL);

		if (!nxt)
			break;

		if (nxt->namelen) {
			(void)strlcat(name,"/",sizeof name);
			(void)strlcat(name,nxt->name,sizeof name);
		}

		/*printf("parent: %p\n",(void *)nxt);*/

		if (nxt == ent)
			break;

		nxt	= mime_entity_first(m,nxt,MIME_EDIT_ALL);
	} while(nxt);

	if (!*name)
		(void)strlcat(name,"/",sizeof name);

	return name;
}

void catch_entity(struct mime_entity *ent, struct mime_offset *off, void *arg) {
	/*printf"Entity (%d/%d): %.*s\n",(int)off->lineno,(int)off->nspan,(int)ent->namelen,ent->name);*/
	printf("Entity %s at line %d spanning %d\n",entity_name(arg,ent),(int)off->lineno,(int)off->nspan);
}

void catch_endofentity(struct mime_entity *ent, struct mime_offset *off, void *arg) {
	printf("End of entity %s at line %d spanning %d\n",entity_name(arg,ent),(int)off->lineno,(int)off->nspan);
}

void catch_unixfrom(struct mime_entity *ent, const char *line, size_t len, struct mime_offset *off, void *arg) {
	printf("Unix From in %s at line %d spanning %d: %.*s",entity_name(arg,ent),(int)off->lineno,(int)off->nspan,(int)len,line);

	if (!len || line[len - 1] != '\n')
		printf("\n");
}

void catch_boundary(struct mime_entity *ent, const char *line, size_t len, struct mime_offset *off, void *arg) {
	printf("Boundary in %s at line %d spanning %d: %.*s",entity_name(arg,ent),(int)off->lineno,(int)off->nspan,(int)len,line);

	if (!len || line[len - 1] != '\n')
		printf("\n");
}

void catch_endofheader(struct mime_entity *ent, struct mime_offset *off, void *arg) {
	printf("End of header in %s at line %d spanning %d\n",entity_name(arg,ent),(int)off->lineno,(int)off->nspan);
/*	printf("Content-Type: %.*s; charset=%.*s; boundary=%.*s\n",(int)ent->typelen,ent->type,(int)ent->charsetlen,ent->charset,(int)ent->boundarylen,ent->boundary);*/
}

void catch_header(struct mime_entity *ent, struct mime_header *hdr, struct mime_offset *off, void *arg) {
	char buf[256];
	size_t len;
	enum mime_errno err;

#if 1
	err	= MIME_ESUCCESS;
	len	= mime_header_decode(arg,buf,sizeof buf,hdr,&err);

	if (err != MIME_ESUCCESS)
		fprintf(stderr,"%s\n",mime_strerror(err,arg));

	printf("Header in %s at line %d spanning %d: %.*s: [%d] '%.*s'\n",entity_name(arg,ent),(int)off->lineno,(int)off->nspan,(int)hdr->namelen,hdr->name,(int)len,(int)MIN(len,sizeof buf),buf);
#else
	printf("Header in %s at line %d spanning %d: %.*s\n",entity_name(arg,ent),(int)off->lineno,(int)off->nspan,(int)hdr->namelen,hdr->name);
/*	printf("Header body: %.*s",(int)hdr->bodylen,hdr->body);*/
#endif
}

void catch_body(struct mime_entity *ent, const char *line, size_t len, struct mime_offset *off, void *arg) {
	printf("Body (%d/%d): %.*s",(int)off->lineno,(int)off->nspan,(int)len,line);

	if (!len || line[len - 1] != '\n')
		printf("\n");
}


int main(int argc, char *argv[]) {
	struct mime_options opts	= mime_defaults;
	struct mime_event bnd, boe, frm, hdr, eoh/*, bod*/, eoe;
	struct mime *m;
	enum mime_errno err;

	strlcpy(opts.linebreak,"\n",sizeof opts.linebreak);

	for (argv++; *argv; argv++) {

	m	= mime_open(&opts);

	err	= mime_encoding_set(m,"utf7");

	if (!MIME_SUCCESS(err))
		fprintf(stderr,"%s\n",mime_strerror(err,m));

	err	= mime_encoding_add(m,"iso-2022-jp");

	if (!MIME_SUCCESS(err))
		fprintf(stderr,"%s\n",mime_strerror(err,m));

	err	= mime_encoding_add(m,"big5");

	if (!MIME_SUCCESS(err))
		fprintf(stderr,"%s\n",mime_strerror(err,m));

	err	= mime_encoding_add(m,"utf8");

	if (!MIME_SUCCESS(err))
		fprintf(stderr,"%s\n",mime_strerror(err,m));

	err	= mime_encoding_add(m,"iso-8859-1");

	if (!MIME_SUCCESS(err))
		fprintf(stderr,"%s\n",mime_strerror(err,m));

	mime_event_set(&bnd,boundary,catch_boundary,m);
	mime_event_set(&boe,entity,catch_entity,m);
	mime_event_set(&frm,unixfrom,catch_unixfrom,m);
	mime_event_set(&hdr,header,catch_header,m);
	mime_event_set(&eoh,eoh,catch_endofheader,m);
/*	mime_event_set(&bod,body,catch_body,m);*/
	mime_event_set(&eoe,eoe,catch_endofentity,m);

	mime_event_add(m,&bnd);
	mime_event_add(m,&boe);
	mime_event_add(m,&frm);
	mime_event_add(m,&hdr);
	mime_event_add(m,&eoh);
/*	mime_event_add(m,&bod);*/
	mime_event_add(m,&eoe);

	err	= mime_readfile(m,*argv);

	if (MIME_FAILURE(err))
		fprintf(stderr,"mime_readfile: %s\n",mime_strerror(err,m));

	mime_close(m);

	}

	return 0;
}

