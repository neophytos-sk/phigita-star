#ifndef CRITBIT_H_
#define CRITBIT_H_


typedef struct {
  void *root;
  int size;
  int keylen;
} critbit0_tree;

int critbit0_bytelen(const critbit0_tree*const t, const char *u);
int critbit0_contains(critbit0_tree *t, const char *u);
int critbit0_insert(critbit0_tree*const t, const char *u, const size_t ulen);
int critbit0_delete(critbit0_tree *t, const char *u, const size_t ulen);
void critbit0_clear(critbit0_tree *t);
int critbit0_allprefixed(const critbit0_tree*const t, const char *prefix,
			 int (*callback)(const critbit0_tree*const t,const char *, void *), void *arg);

int allprefixed_cb(const critbit0_tree*const t,const char *elem, void *arg);
int prefix_match_cb(const critbit0_tree*const t,const char *elem, int *remaining, void *arg);
int critbit0_prefix_match(const critbit0_tree*const t, const char *u, const size_t ulen, 
			  const int sort_direction,const int limit,const int exact_match,
			  int (*callback)(const critbit0_tree*const t,const char *,int *, void *),  void *arg);

int critbit0_segment_match(const critbit0_tree*const t, const char *u, const size_t ulen, void **leaf);
int critbit0_dump(const critbit0_tree*const t, const char*const filename);
int critbit0_restore(critbit0_tree*const t, const char*const filename);
int critbit0_prefix_exists(const critbit0_tree*const t, const char*const u,const size_t ulen);
int critbit0_get(const critbit0_tree*const t, const char*const u,const size_t ulen, void **leaf);
#endif  // CRITBIT_H_
