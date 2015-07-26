#include <stdio.h>
#include <string.h>
#include "bloom.h"
#include "murmur_hash2.h"

int main(int argc, char **argv) {
    bloom_filter_t bf;
    bf_init(&bf, MurmurHash2, 1000,0.0001);
    
    size_t i;
    for (i=0; i<argc; ++i) {
        bf_insert(&bf, argv[i], strlen(argv[i]));
    }

    printf("may_contain(abc)=%d\n",bf_may_contain(&bf,"abc",3));
    printf("may_contain(defgh)=%d\n",bf_may_contain(&bf,"defgh",5));
    return 0;
}
