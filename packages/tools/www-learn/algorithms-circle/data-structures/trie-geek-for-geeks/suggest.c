#include <stdio.h>
#include <stdlib.h>
#include <string.h>
 
#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])
 
// Alphabet size (# of symbols)
#define ALPHABET_SIZE (26)
// Converts key current character into index
// use only 'a' through 'z' and lower case
#define CHAR_TO_INDEX(c) ((int)c - (int)'a')
#define INDEX_TO_CHAR(i) ((int)i + (int)'a')
 
// trie node
typedef struct trie_node trie_node_t;
struct trie_node
{
    int value;
    trie_node_t *children[ALPHABET_SIZE];
};
 
// trie ADT
typedef struct trie trie_t;
struct trie
{
    trie_node_t *root;
    int count;
};
 
// Returns new trie node (initialized to NULLs)
trie_node_t *getNode(void)
{
    trie_node_t *pNode = NULL;
 
    pNode = (trie_node_t *)malloc(sizeof(trie_node_t));
 
    if( pNode )
    {
        int i;
 
        pNode->value = 0;
 
        for(i = 0; i < ALPHABET_SIZE; i++)
        {
            pNode->children[i] = NULL;
        }
    }
 
    return pNode;
}
 
// Initializes trie (root is dummy node)
void initialize(trie_t *pTrie)
{
    pTrie->root = getNode();
    pTrie->count = 0;
}
 
// If not present, inserts key into trie
// If the key is prefix of trie node, just marks leaf node
void insert(trie_t *pTrie, char key[])
{
    int level;
    int length = strlen(key);
    int index;
    trie_node_t *pCrawl;
 
    pTrie->count++;
    pCrawl = pTrie->root;
 
    for( level = 0; level < length; level++ )
    {
        index = CHAR_TO_INDEX(key[level]);
 
        if( pCrawl->children[index] )
        {
            // Key current character already present
            // skip the node
            pCrawl = pCrawl->children[index];
        }
        else
        {
            // Add new node
            pCrawl->children[index] = getNode();
            pCrawl = pCrawl->children[index];
        }
    }
 
    // mark last node as leaf
    pCrawl->value = pTrie->count;
}
 
// Returns non zero, if key presents in trie
int search(trie_t *pTrie, char key[])
{
    int level;
    int length = strlen(key);
    int index;
    trie_node_t *pCrawl;
 
    pCrawl = pTrie->root;
 
    for( level = 0; level < length; level++ )
    {
        index = CHAR_TO_INDEX(key[level]);
 
        if( !pCrawl->children[index] )
        {
            return 0;
        }
 
        pCrawl = pCrawl->children[index];
    }
 
    return (0 != pCrawl && pCrawl->value);
}

int suggest(trie_node_t *pCrawl, char key[], int level, int allowed_missing, char out[]) {

  if (!pCrawl) return;

  int length = strlen(key);
  int index = CHAR_TO_INDEX(key[level]);

  out[level]='\0';
  printf("level=%d out=%s edge=%c\n",level,out,key[level]);

  if (!pCrawl->children[index] && allowed_missing==0) 
    return 0;
  else if (!pCrawl->children[index]) {
    for(index=0;index<ALPHABET_SIZE;++index) {
      if (pCrawl->children[index]) {
	out[level]=INDEX_TO_CHAR(index);
	suggest(pCrawl->children[index],key,level,allowed_missing-1,out);
      }
    }
  } else {
    int r=0;
    if (allowed_missing>0) {
      out[level]='x';
      r += suggest(pCrawl,key,level,allowed_missing-1,out);
    }
    out[level]=INDEX_TO_CHAR(index);
    r += suggest(pCrawl->children[index],key,level+1,allowed_missing,out);
    return r;
  }

}
 
// Driver
int main()
{
    // Input keys (use only 'a' through 'z' and lower case)
    char keys[][8] = {"the", "a", "there", "answer", "any", "by", "bye", "their"};
    trie_t trie;
 
    char output[][32] = {"Not present in trie", "Present in trie"};
 
    initialize(&trie);
 
    // Construct trie
    for(int i = 0; i < ARRAY_SIZE(keys); i++)
    {
        insert(&trie, keys[i]);
    }
 
    // Search for different keys
    printf("%s --- %s\n", "the", output[search(&trie, "the")] );
    printf("%s --- %s\n", "these", output[search(&trie, "these")] );
    printf("%s --- %s\n", "their", output[search(&trie, "their")] );
    printf("%s --- %s\n", "thaw", output[search(&trie, "thaw")] );


    char out[1000];
    printf("allowed_missing=2, number of suggestions = %d\n",suggest((&trie)->root,"teir",0,2,out));
 
    return 0;
}
