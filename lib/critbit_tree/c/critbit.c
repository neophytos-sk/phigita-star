#define _POSIX_C_SOURCE 200112
#define uint8 uint8_t
#define uint32 uint32_t

#include <stdio.h>  // for fprintf, fwrite, fread
#include <stdint.h> 
#include <string.h> 
#include <stdlib.h> 

#include <sys/types.h> 
#include <errno.h> 

#undef DEBUG
#ifndef DEBUG
#define DBG(x)
#else
#define DBG(x) (x)
#endif

typedef struct{
  void*child[2];
  uint32 byte;
  uint8 otherbits;
} critbit0_node;

// TODO: add dirty bit flag either in critbit0_tree or critbit0_node (we have 3 bytes available)
/* keylen: 0 = STRING_KEYS, 4 = UINT32_KEYS 8 = UINT64_KEYS */
typedef struct{
  void*root;
  uint32 size;
  int keylen;
} critbit0_tree;

int
critbit0_bytelen(const critbit0_tree*const t,const char*u) {
  //printf("keylen=%d %zd elem=%s\n",t->keylen,strlen(u),u);
  int retval= t->keylen + strlen(&u[t->keylen]);
  return retval;
}

int
critbit0_contains(const critbit0_tree*t,const char*u){
  const uint8*ubytes= (void*)u;
  const size_t ulen= critbit0_bytelen(t,u);
  uint8*p= t->root;

  if(!p)return 0;

  while(1&(intptr_t)p){
    critbit0_node*q= (void*)(p-1);
    uint8 c= 0;
    if(q->byte<ulen)c= ubytes[q->byte];
    const int direction= (1+(q->otherbits|c))>>8;
    p= q->child[direction];
  }
  return 0==strcmp(u,(const char*)p);
}

int critbit0_insert(critbit0_tree*const t,const unsigned char*u, const size_t ulen)
{
  const uint8*const ubytes= (void*)u;
  uint8*p= t->root;

  if(!p){
    char*x;
    int a= posix_memalign((void**)&x,sizeof(void*),ulen+1);
    if(a)return 0;
    //memcpy(x,u,ulen+1);
    memcpy(x,u,ulen);
    x[ulen]='\0';
    t->root= x;
    return 2;
  }

  while(1&(intptr_t)p){
    critbit0_node*q= (void*)(p-1);
    uint8 c= 0;
    if(q->byte<ulen)c= ubytes[q->byte];
    const int direction= (1+(q->otherbits|c))>>8;
    p= q->child[direction];
  }

  uint32 newbyte;
  uint32 newotherbits;

  for(newbyte= 0;newbyte<ulen;++newbyte){
    if(p[newbyte]!=ubytes[newbyte]){
      newotherbits= p[newbyte]^ubytes[newbyte];
      goto different_byte_found;
    }
  }

  if(p[newbyte]!=0){
    newotherbits= p[newbyte];
    goto different_byte_found;
  }
  return 1;
  
 different_byte_found:

  while(newotherbits&(newotherbits-1))newotherbits&= newotherbits-1;
  newotherbits^= 255;
  uint8 c= p[newbyte];
  int newdirection= (1+(newotherbits|c))>>8;
  
  critbit0_node*newnode;
  if(posix_memalign((void**)&newnode,sizeof(void*),sizeof(critbit0_node)))return 0;

  char*x;
  if(posix_memalign((void**)&x,sizeof(void*),ulen+1)){
    free(newnode);
    return 0;
  }
  //memcpy(x,ubytes,ulen+1);
  memcpy(x,ubytes,ulen);
  x[ulen]='\0';

  newnode->byte= newbyte;
  newnode->otherbits= newotherbits;
  newnode->child[1-newdirection]= x;

  void**wherep= &t->root;
  for(;;){
    uint8*p= *wherep;
    if(!(1&(intptr_t)p))break;
    critbit0_node*q= (void*)(p-1);
    if(q->byte> newbyte)break;
    if(q->byte==newbyte&&q->otherbits> newotherbits)break;
    uint8 c= 0;
    if(q->byte<ulen)c= ubytes[q->byte];
    const int direction= (1+(q->otherbits|c))>>8;
    wherep= q->child+direction;
  }
  
  newnode->child[newdirection]= *wherep;
  *wherep= (void*)(1+(char*)newnode);

  ++(t->size);
  return 2;
}

int critbit0_delete(critbit0_tree*const t,const char*const u,const size_t ulen){
  const uint8*ubytes= (void*)u;
  //const size_t ulen= strlen(u);
  uint8*p= t->root;
  void**wherep= &t->root;
  void**whereq= 0;
  critbit0_node*q= 0;
  int direction= 0;

  if(!p)return 0;

  while(1&(intptr_t)p){
    whereq= wherep;
    q= (void*)(p-1);
    uint8 c= 0;
    if(q->byte<ulen)c= ubytes[q->byte];
    direction= (1+(q->otherbits|c))>>8;
    wherep= q->child+direction;
    p= *wherep;
  }

  if(0!=strcmp(u,(const char*)p))return 0;
  free(p);

  --(t->size);

  if(!whereq){
    t->root= 0;
    return 1;
  }

  *whereq= q->child[1-direction];
  free(q);
  
  return 1;
}



static void
traverse(void*top){
  
  uint8*p= top;

  if(1&(intptr_t)p){
    critbit0_node*q= (void*)(p-1);
    traverse(q->child[0]);
    traverse(q->child[1]);
    free(q);
  }else{
    free(p);
  }
  

}

void critbit0_clear(critbit0_tree*t)
{
  if(t->root)traverse(t->root);
  t->root= NULL;
}


static int
allprefixed_traverse(critbit0_tree*t,uint8*top,
		     int(*callback)(critbit0_tree*t,const char*,void*),void*arg){

  if(1&(intptr_t)top){
    critbit0_node*q= (void*)(top-1);
    int direction;
    for(direction= 0;direction<2;++direction)
      switch(allprefixed_traverse(t,q->child[direction],callback,arg)){
      case 1:break;
      case 0:return 0;
      default:return-1;
      }
    return 1;
  }
  
  return callback(t,(const char*)top,arg);

}

int
critbit0_allprefixed(critbit0_tree*t,const char*prefix,
		     int(*callback)(critbit0_tree*t,const char*,void*),void*arg){
  const uint8*ubytes= (void*)prefix;
  const size_t ulen= critbit0_bytelen(t,prefix);
  uint8*p= t->root;
  uint8*top= p;
  
  if(!p)return 1;

  while(1&(intptr_t)p){
    critbit0_node*q= (void*)(p-1);
    uint8 c= 0;
    if(q->byte<ulen)c= ubytes[q->byte];
    const int direction= (1+(q->otherbits|c))>>8;
    p= q->child[direction];
    if(q->byte<ulen)top= p;
  }
  
  size_t i;
  for(i= 0;i<ulen;++i){
    if(p[i]!=ubytes[i])return 1;
  }

  return allprefixed_traverse(t,top,callback,arg);
}



int allprefixed_cb(critbit0_tree*t, const char *elem, void *arg) {
  /* NOTE: arg and t are both of type critbit0_tree*t for allprefixed_cb 
   *       but they are different types for allprefixed_TclObj_cb
   */
  critbit0_insert(arg,elem,critbit0_bytelen(t,elem));
  return 1;
}

int print_external_cb(critbit0_tree*t, const char *elem, void *arg) {
  int *counter = (intptr_t)arg;
  DBG(fprintf(stderr,"external node %d\n",*counter));

  const uint32 ulen = critbit0_bytelen(t,elem);
  const char *u = elem;
  DBG(fprintf(stderr,"%.*s\n",ulen,u));

  ++(*counter);
  return 1;
}


int prefix_match_cb(const critbit0_tree*const t,const char *elem, int *remaining, void *arg) {

  if (remaining) {
    int ulen = critbit0_bytelen(t,elem);
    critbit0_insert(arg,elem,critbit0_bytelen(t,elem));
    --(*remaining);
    return 1;
  } else {
    return 0;
  }
}




static int
guided_traverse(critbit0_tree*t,uint8*top,
		int(*callback)(critbit0_tree*t,const char*,int *remaining, void*),
		const int direction, int *remaining, void*arg){

  DBG(printf("direction=%d remaining=%d\n",direction,*remaining));

  if(1&(intptr_t)top){
    critbit0_node*q= (void*)(top-1);
    
    switch(guided_traverse(t,q->child[direction],callback,direction,remaining,arg)){
    case 1:break;
    case 0:return 0;
    default:return-1;
    }

    switch(guided_traverse(t,q->child[1-direction],callback,direction,remaining,arg)){
    case 1:break;
    case 0:return 0;
    default:return-1;
    }
    return 1;
  }
  
  return callback(t,(const char*)top,remaining,arg);

}


int
critbit0_prefix_match(critbit0_tree *t, const char *u, const size_t ulen, 
		      const int sort_direction,const int limit,const int exact_match,
		      int (*callback)(critbit0_tree*t,const char *, int *, void *),  void *arg){


  const uint8*const ubytes= (void*)u;
  uint8*p= t->root;
  uint8*top= p;

  if(!p) return 0;
  
  while(1&(intptr_t)p){
    critbit0_node*q= (void*)(p-1);
    uint8 c= 0;
    if(q->byte<ulen)c= ubytes[q->byte];
    const int direction= (1+(q->otherbits|c))>>8;
    p= q->child[direction];
    if(q->byte<ulen)top= p;

  }

  if (exact_match) {
    size_t i;
    for(i= 0;i<ulen;++i){
      if(p[i]!=ubytes[i])return i;
    }
  }

  int remaining = limit;
  return guided_traverse(t,top,callback,sort_direction,&remaining,arg);


}


inline uint32_t PACK(uint8_t c0, uint8_t c1, uint8_t c2, uint8_t c3) {
  return (c0<<24) | (c1<<16) | (c2<<8) | c3;
}

int segment_match_cb(const uint8*const top,const char*const u,const size_t ulen, const void**leaf) {

  const uint8*const ubytes= (void*)u;
  const int invalid = strncmp(top,ubytes,ulen)>0 || strncmp(ubytes,top+ulen,ulen)>0;

  if (!invalid)
    *leaf=top;

  return invalid;


}


int bounded_traverse(const uint8*const top,const char*const u,const size_t ulen, const void**leaf) {

  const uint8*const ubytes= (void*)u;

  if(1&(intptr_t)top){
    critbit0_node*q= (void*)(top-1);
    uint8 c= 0;
    if(q->byte<ulen)c= ubytes[q->byte];
    const int direction= (1+(q->otherbits|c))>>8;

    switch(bounded_traverse(q->child[direction],u,ulen,leaf)){
    case 1:break;
    case 0:return 0;
    default:return-1;
    }

    if (direction==0) {
      switch(bounded_traverse(q->child[1-direction],u,ulen,leaf)){
      case 1:break;
      case 0:return 0;
      default:return-1;
      }
    }

    return 1;
  }
  
  return segment_match_cb(top,u,ulen,leaf);
}


int
critbit0_segment_match(const critbit0_tree*const t,const char*const u, const size_t ulen, const void**leaf){

  int notfound=bounded_traverse(t->root,u,ulen,leaf);
  if(notfound)return 0;
  return 1;

}


static int
serialize(const critbit0_tree*const t,const uint8*const top,
	  int(*internal_node_cb)(const critbit0_tree*const,const uint8*const,uint32*const offset,void*),
	  int(*external_node_cb)(const critbit0_tree*const,const uint8*const,uint32*const offset,void*),
	  uint32*const offset,void*arg){

  if(1&(intptr_t)top){

    if(!internal_node_cb(t,top,offset,arg)) return 0;

    critbit0_node*q= (void*)(top-1);
    int direction;
    for(direction= 0;direction<2;++direction){
      switch(serialize(t,q->child[direction],internal_node_cb,external_node_cb,offset,arg)){
      case 1:break;
      case 0:return 0;
      default:return-1;
      }
    }

    return 1;
  }

  return external_node_cb(t,top,offset,arg);

}



int dump_internal_node_cb(const critbit0_tree * const t,const uint8*const top, uint32*const offset, void*arg) {

  FILE *fp= (FILE*)arg;
  critbit0_node*q= (void*)(top-1);

  // reference code from insert operation: (void*)(1+(char*)newnode)
  int i;
  for(i=0;i<2;++i){
    int node_type_tag= 1&(intptr_t)q->child[i];
    void *child= (void*)(node_type_tag+(char*)(*offset<<sizeof(int)));
    if (!fwrite(&child,sizeof(void*),1,fp)){
      fprintf(stderr,"fwrite error\n");
      return 0;
    }
    *offset += sizeof(void*);
  }

  if (!fwrite(&q->byte,sizeof(uint32),1,fp)){
    fprintf(stderr,"fwrite error\n");
    return 0;
  }

  if (!fwrite(&q->otherbits,sizeof(uint8),1,fp)){
    fprintf(stderr,"fwrite error\n");
    return 0;
  }

  *offset += sizeof(uint32) + sizeof(uint8);
  return 1;
}

int dump_external_node_cb(const critbit0_tree * const t,const uint8*const top, uint32*const offset,FILE *fp) {
  uint32 ulen = critbit0_bytelen(t,(const char*)top);

  // DBG(fprintf(stderr,"%d\n",ftell(fp)));

  // Write the byte length of the data
  if (!fwrite(&ulen,sizeof(uint32),1,fp)) {
    fprintf(stderr,"fwrite error\n");
    return 0;
  }
  //fprintf(stderr,"%d %.*s\n",ftell(fp),ulen,top);

  // Write the data
  if (!fwrite(top,ulen,1,fp)){
    fprintf(stderr,"fwrite error\n");
    return 0;
  }

  *offset += sizeof(int) + ulen;

  return 1;
}

// todo: 
// * file header
// * whether data is binary
//   - if not we might skip adding byte length before each key=value pair)
//   - if not we could also use varchar like types
// * use mmap/munmap
int critbit0_dump(const critbit0_tree*const t, const char*const filename){
  FILE *fp = fopen(filename,"wb");

  if (!fp) {
    fprintf(stderr, "Unable to open file %s", filename);
    return;
  }

  // Write metadata (keylen, todo: size, i.e. number of elements)
  if (!fwrite(&(t->keylen), sizeof(int),1,fp)) {
    fprintf(stderr, "fwrite t->keylen error!");
    fclose(fp);
    return;
  }

  if (!fwrite(&(t->size), sizeof(int),1,fp)) {
    fprintf(stderr, "fwrite t->size error!");
    fclose(fp);
    return;
  }

  // dump the root node type tag of the root
  const int root_type_tag = 1&(intptr_t)t->root;
  fprintf(stderr,"root_type_tag=%d\n",root_type_tag);
  if (!fwrite(&root_type_tag,sizeof(int),1,fp)) {
    fprintf(stderr, "fwrite error: root_type_tag\n");
    fclose(fp);
    return;
  }

  // dump the tree

  uint32 offset = 0;
  if (!serialize(t,t->root,dump_internal_node_cb,dump_external_node_cb,&offset,fp)) {
    fclose(fp);
    return 0;
  }
  fclose(fp);

  // comment in to test that we deserialized correctly:
  // int counter = 0;
  // allprefixed_traverse(t,t->root,print_external_cb,&counter);


  return 1;
}


static int restore_internal_node_cb(const critbit0_tree*const t,void*arg,void**node){
  FILE *fp = (FILE*)arg;

  DBG(fprintf(stderr,"%d\n",ftell(fp)));


  critbit0_node* newnode;
  if(posix_memalign((void**)&newnode,sizeof(void*),sizeof(critbit0_node)))return 0;
  int direction;
  for(direction=0;direction<2;++direction) {
    if(!fread(&newnode->child[direction],sizeof(void*),1,fp)) {
      fprintf(stderr,"fread error: newnode->child[%d]\n",direction);
      fclose(fp);
      return 0;
    }
  }
  if(!fread(&newnode->byte,sizeof(uint32),1,fp)) {
    fprintf(stderr,"fread error: newnode->byte\n",direction);
    fclose(fp);
    return 0;
  }
  if(!fread(&newnode->otherbits,sizeof(uint8),1,fp)) {
    fprintf(stderr,"fread error: newnode->otherbits\n",direction);
    fclose(fp);
    return 0;
  }
  *node = (void*)(1+(char*)newnode);

  DBG(fprintf(stderr,"restore_internal_node_cb: newnode=%p *node=%p byte=%d\n",newnode,*node,newnode->byte));


  return 1;
}


static int restore_external_node_cb(const critbit0_tree*const t,void*arg,void**node){

  FILE *fp = (FILE*)arg;

  DBG(fprintf(stderr,"%d\n",ftell(fp)));

  uint32 ulen;
  if(!fread(&ulen,sizeof(uint32),1,fp)) {
    fprintf(stderr,"fread error: restore_external_node_cb ulen\n");
  }


  //fprintf(stderr,"external ulen=%d\n",ulen);

  char*x;
  if(posix_memalign((void**)&x,sizeof(void*),ulen+1)){
    fprintf(stderr,"posix_memalign error: restore_external_node_cb\n");
    fclose(fp);
    // this should move into deserialize: free(newnode);
    return 0;
  }
  if(!fread(x,ulen,1,fp)) {
    fprintf(stderr,"fread error: value/data\n");
    fclose(fp);
    return 0;
  }
  x[ulen]='\0';

  *node = x;

  DBG(fprintf(stderr,"restore_external_node_cb: x=%p *node=%p data=%.*s\n",x,*node,ulen,*node));

  return 1;
}


static int
deserialize(const critbit0_tree*const t,
	  int(*internal_node_cb)(const critbit0_tree*const,void*,void**),
	  int(*external_node_cb)(const critbit0_tree*const,void*,void**),
	  void*arg,void**top){

  if(1&(intptr_t)(*top)){

    if(!internal_node_cb(t,arg,top)) return 0;

    critbit0_node*q= (void*)(*top-1);
    int direction;
    for(direction= 0;direction<2;++direction){
      switch(deserialize(t,internal_node_cb,external_node_cb,arg,&q->child[direction])){
      case 1:break;
      case 0:return 0;
      default:return-1;
      }
    }

    return 1;
  }

  return external_node_cb(t,arg,top);
}




// TODO:
// * use mmap/munmap
int critbit0_restore(critbit0_tree*const t, const char*const filename){

  // Open file
  FILE *fp = fopen(filename,"rb");
  if (!fp) {
    fprintf(stderr, "Unable to open file %s", filename);
    return;
  }

  unsigned long fileLen;
  fseek(fp, 0, SEEK_END);
  fileLen=ftell(fp);
  fseek(fp, 0, SEEK_SET);

  // read t->keylen
  if(!fread(&t->keylen,sizeof(int),1,fp)) {
    fprintf(stderr,"fread error: t->keylen\n");
  }

  // read t->keylen
  if(!fread(&t->size,sizeof(int),1,fp)) {
    fprintf(stderr,"fread error: t->size\n");
  }


  // read t->root node type tag
  int root_type_tag;
  if(!fread(&root_type_tag,sizeof(int),1,fp)) {
    fprintf(stderr,"fread error: root_type_tag\n");
  }

  // restore-reconstruct the root node
  //t->root = (void*)(root_type_tag + (char*)buffer);
  t->root = (void*)(root_type_tag);
  fprintf(stderr,"t->keylen=%d t->root=%p\n",t->keylen,t->root);

  // fix the rest of the pointers
  if(!deserialize(t,restore_internal_node_cb,restore_external_node_cb,fp,&t->root)) {
    fprintf(stderr,"failed to deserialize\n");
    fclose(fp);
    return 0;
  }

  fclose(fp);

  return 1;
}



int
critbit0_prefix_exists(const critbit0_tree*const t, const char*const u, const size_t ulen){
  const uint8*const ubytes= (void*)u;
  const uint8*p= t->root;

  if(!p) return 0;

  while(1&(intptr_t)p){
    critbit0_node*q= (void*)(p-1);
    uint8 c= 0;
    if(q->byte<ulen)c= ubytes[q->byte];
    const int direction= (1+(q->otherbits|c))>>8;
    p= q->child[direction];
  }

  uint32 i;
  for(i= 0;i<ulen;++i){
    if(p[i]!=ubytes[i])return 0;
  }
  return 1;
}


int
critbit0_get(const critbit0_tree*const t, const char*const u, const size_t ulen, void **leaf){
  const uint8*const ubytes= (void*)u;
  const uint8*p= t->root;

  if(!p) return 0;

  while(1&(intptr_t)p){
    critbit0_node*q= (void*)(p-1);
    uint8 c= 0;
    if(q->byte<ulen)c= ubytes[q->byte];
    const int direction= (1+(q->otherbits|c))>>8;
    p= q->child[direction];
  }

  uint32 i;
  for(i= 0;i<ulen;++i){
    if(p[i]!=ubytes[i])return 0;
  }

  *leaf = p;

  return 1;
}
