
// fix pointers
static int
deserialize_fixpointers(const critbit0_tree*const t, uint8*top){
  fprintf(stderr,"fixpointers\n");

  if(1&(intptr_t)top){

    critbit0_node*q= (void*)(top-1);
    int direction;
    for(direction= 0;direction<2;++direction){
      int node_type_tag = 1*(intptr_t)q->child[direction];

      // FIXME: t->root is where our memory block begins, so add it to our offset
      // reference code from dump_internal_node:
      // void *child= (void*)(node_type_tag+(char*)(*offset << sizeof(int)));

      // q->child[direction] = (void*)((char*)t->root + (char*)((intptr_t)q->child[direction] >> sizeof(int)));
      q->child[direction] = (void*)((char*)&t->root + ((intptr_t)q->child[direction] >> sizeof(int)));

      // no need to invoke deserialize_fixpointers for external nodes
      if(!node_type_tag) return 1;

      switch(deserialize_fixpointers(t,q->child[direction])){
      case 1:break;
      case 0:return 0;
      default:return-1;
      }
    }

    return 1;
  }

  // external node - nothing to fix at the moment - TODO: take care of length, 
  // e.g. add byte length during insert and use that while dumping the tree or calling bytelength
  return 1;

}

  // Allocate memory
  //uint8 *buffer=(void *)malloc(fileLen+1);
  uint8 *buffer;
  if (posix_memalign((void**)&buffer,sizeof(void*),fileLen+1)) {
    fprintf(stderr, "memory alloc error: posix_memalign\n");
    fclose(fp);
    return;
  }

  // Read file contents into buffer
  if (!fread(buffer, fileLen, 1, fp)) {
    fprintf(stderr, "fread error!");
    fclose(fp);
    return;
  }

  fclose(fp);

  // NOTE THAT keylen + root_type_tag is 8 bytes (this is important)

  // read metadata (keylen, todo: size, i.e. number of elements)
  t->keylen = (int)*buffer;
  fprintf(stderr,"keylen=%d\n",t->keylen);
  buffer += sizeof(int);


dump_internal_node_cb
    // void *child= (void*)(node_type_tag+(char*)(*offset << sizeof(int)));
    // for the following to work, we use padding for external nodes to ensure that offset is going to be a power of two and multiple of sizeof(void*)
    // void *child= (void*)(node_type_tag+(char*)(void*)*offset);
    // NOTE: storing node_type_tag together with offset (not the same as in-memory representation)


    // we are only interested in the initial offset (i.e. when i=0)
    //DBG(fprintf(stderr,"i=%d node_type_tag=%d offset=%d mod8=%d mine=%p q->child=%p\n",i,node_type_tag,*offset,*offset % 8,child,q->child[i]));


  //*offset += sizeof(critbit0_node);
  // PROBLEM: we are three bytes short of a multiple of sizeof(void*)
  // FOR NOW WE WE WILL USE PADDING (and later figure out things to store in those three bytes)
  /*
  const char*const padding = "\0\0\0";
  const int paddinglen = 3;
  if (!fwrite(padding,paddinglen,1,fp)){
    fprintf(stderr,"fwrite error\n");
    return 0;
  }
  *offset += paddinglen;
  DBG(fprintf(stderr,"offset=%d pointer=%p\n",*offset,(char*)*offset));
  return 1;
  */


dump_external_node_cb
  
  // pad with null characters to ensure next node next position is a power of two and a multiple of sizeof(void*)
  /*
  const int len = sizeof(int) + ulen;
  const int paddinglen = 0x8 - len % 8; // (len % 8)
  const char*const padding = "\0\0\0\0\0\0\0\0";
  if (paddinglen && !fwrite(padding,paddinglen,1,fp)) {
    fprintf(stderr,"fwrite error: padding string with null characters\n");
    return 0;
  }

  *offset += len + paddinglen;
  DBG(fprintf(stderr,"offset=%d pointer=%p\n",*offset,(char*)*offset));
  */


segment_match

  //const uint8*const other = top+ulen;
  //const uint32_t lo= PACK(*top,*(top+1),*(top+2),*(top+3));
  //const uint32_t hi= PACK(*other,*(other+1),*(other+2),*(other+3));
  //const uint32_t x= PACK(*ubytes,*(ubytes+1),*(ubytes+2),*(ubytes+3));
  //printf("segment_match_cb lo>x=%d x>hi=%d\n",lo>x,x>hi);
  //const int invalid= lo>x || x>hi;

  // TODO: LINE BELOW SPECIFIC FOR GEOIP (SAVES TIME BUT MISSES SOLUTIONS)
  //const size_t skip=0;
  //const int invalid = (strncmp(top+skip,ubytes+skip,ulen-skip) > 0) || (strncmp(ubytes+skip,top+ulen+skip,ulen-skip) > 0);

  //const int invalid = strncmp(ubytes+skip,top+ulen+skip,ulen-skip) > 0;



critbit0_prefix_match


  /*
  while(1&(intptr_t)top){
    critbit0_node*q= (void*)(top-1);
    // parameterize direction here
    // 0 for min element after prefix
    // 1 for max element after prefix
    int direction=1;
    top=q->child[direction];
  }

  *leaf=(void*)top;
  return i;
  */
