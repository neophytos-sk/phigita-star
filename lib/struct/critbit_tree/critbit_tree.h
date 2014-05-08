/*
 * =====================================================================================
 *
 *       Filename:  critbit_tree.h
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  02/08/2014 08:17:42 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Neophytos Demetriou (), 
 *   Organization:  
 *
 * =====================================================================================
 */

#include <sys/types.h>

typedef struct {
    int (keycmp)(void *k1, void *k2);
    int (keylen)(void *key);
} critbit0_type;

typedef struct{
    void *child[2];
    uint32_t byte;
    uint8_t otherbits;
} critbit0_node;

typedef struct{
    void *root;
    critbit0_type *typePtr;
} critbit0_tree;


critbit0_type critbit0_stringkeys = {
    strcmp,
    strlen
}


static inline int
intcmp(void *k1, void *k2)
{
    int v1 = *((int *) k1);
    int v2 = *((int *) k2);
    return v1 == v2;
}

static inline int
intlen(void *)
{
    return sizeof(int);
}

critbit0_type critbit0_intkeys = {
    intcmp,
    intlen
}


static inline int
critbit0_ref_is_internal(uint8_t *p)
{
    return 1 & (intptr_t) p;
}

static inline void *
critbit0_new(critbit0_type *typePtr)
{
    critbit0_tree *t = malloc(sizeof(critbit0_tree));
    t->typePtr = typePtr;
    return t;
}

int
critbit0_contains(critbit0_tree *t, const char *u){

    const uint8_t *ubytes = (void*)u;
    const size_t ulen = t->keylen(u);
    uint8_t *p = t->root;

    if (!p) return 0;


    while (critbit0_ref_is_internal(p)){

        critbit0_node *q = (void*)(p-1);

        uint8_t c = 0;
        if (q->byte < ulen) {
            c = ubytes[q->byte];
        }

        const int direction = (1 + (q->otherbits | c)) >> 8;


        p = q->child[direction];
    }


    // 0 == strcmp(u,(const char*)p);
    return t->keycmp(u, (const char *)p);


}



int 
critbit0_insert(critbit0_tree *t, const char *u)
{
    const uint8_t *const ubytes = (void*)u;
    const size_t ulen = t->keylen(u);
    uint8_t *p = t->root;

    /* empty tree, inserts first node */
    if (!p){
        char *x;
        int a = posix_memalign((void**)&x, sizeof(void*), ulen+1);
        if (a) return 0;
        memcpy(x, u, ulen+1);
        t->root = x;
        return 2;
    }

    /* The address of the allocated memory is a power of two and a multiple
     * of sizeof(void *) and thus the first node (when it is the only node)
     * in the tree cannot be an internal node.
     *
     * Below, it traverses the tree in order to find the external node with 
     * the longest common prefix with ubytes. In the case when p is an
     * internal reference, the critbit node is expected to be found at p-1.
     * 
     */
    while (critbit0_ref_is_internal(p)){
        critbit0_node *q = (void*)(p-1);

        uint8_t c = 0;
        if (q->byte < ulen) c = ubytes[q->byte];
        const int direction = (1 + (q->otherbits|c)) >> 8;


        p= q->child[direction];
    }


    uint32_t newbyte;
    uint32_t newotherbits;

    /* find differing bytes: compares the given key, i.e. ubytes, and the key found matching
     * its prefix by following all internal nodes above and find the byte in which they differ
     */
    for (newbyte = 0; newbyte < ulen; ++newbyte) {
        if (p[newbyte] != ubytes[newbyte]) {
            /* newotherbits holds the bits that differ between the differing byte of ubytes and p */
            newotherbits = p[newbyte] ^ ubytes[newbyte];
            goto different_byte_found;
        }
    }

    /* check whether the given key is shorter than the found key */
    if (p[newbyte] != 0) {
        newotherbits = p[newbyte];
        goto different_byte_found;
    }

    /* key already exists */
    return 1;

different_byte_found:


    /* find differing bit: we could have searched bits 7..0 to find the most significant bit that
     * differs but with this trick we recursively fold 1s so that every bit to the 
     * right of the most significant different bit is set to 1. To see how this works,
     * convince yourself that there is a left-most bit that is set to 1. Getting the bitwise OR
     * of the differing bits (plural) with the differing bits shifted by 1, 2 and 4 makes all
     * the bits to the right of the MSB set to 1, so if the differing byte is 00100001, after
     * shifting right by 1 it becomes 00110001, after shifting by 2 it becomes 00111101, and
     * finally shifting by 4 it becomes 00111111, then ~(newotherbits >> 1) results in
     * 11100000 and the bitwise OR gives us 00100000, and finally bitwise XOR sets all bits
     * to 1 except the differing bit which is set to 0, i.e. 11011111.
     */
    newotherbits |= newotherbits >> 1;
    newotherbits |= newotherbits >> 2;
    newotherbits |= newotherbits >> 4;
    newotherbits = (newotherbits & ~(newotherbits >> 1)) ^ 255;
    uint8_t c = p[newbyte];

    /*  if c has the differing bit set to 1, then the new direction is 1, otherwise it is 0 */
    int newdirection = (1 + (newotherbits | c)) >> 8;


    critbit0_node *newnode;
    if (posix_memalign((void **)&newnode, sizeof(void *), sizeof(critbit0_node))) return 0;

    char *x;
    if(posix_memalign((void **)&x, sizeof(void *), ulen + 1)) {
        free(newnode);
        return 0;
    }

    memcpy(x, ubytes, ulen+1);

    newnode->byte = newbyte;
    newnode->otherbits = newotherbits;
    newnode->child[1-newdirection] = x;


    void **wherep = &t->root;
    for(;;) {
        uint8_t *p = *wherep;
        if (!(critbit0_ref_is_internal(p))) break;
        critbit0_node *q = (void *)(p-1);
        if (q->byte > newbyte) break;
        if (q->byte == newbyte && q->otherbits > newotherbits) break;
        uint8_t c = 0;
        if (q->byte < ulen) c = ubytes[q->byte];
        const int direction = (1 + (q->otherbits | c)) >> 8;
        wherep = q->child + direction;
    }

    /* wherep holds the address to an external node, i.e. the key that differs with the 
     * inserted key which will become the one child of our critbit node, the other being
     * the inserted key
     */
    newnode->child[newdirection] = *wherep;

    /* By adding 1 below we ensure that the pointer will be identified 
     * as internal, i.e. newnode is a pointer to a critbit node that is
     * a power of two and a multiple of sizeof(void *). So, given a reference
     * that is an internal node, we can get the address of the critbit node 
     * by removing 1 from the reference.
     */
    *wherep = (void *)(1 + (char *)newnode);

    return 2;
}
