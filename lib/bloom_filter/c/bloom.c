#include "bloom.h"

#define CHAR_BIT sizeof(char)

void bf_init(
    bloom_filter_t *bf, 
    uint32_t (*hash_fn)(const void *key, size_t len, uint32_t seed), 
    size_t items_estimate, 
    float false_positive_prob) 
{
    double num_hashes;
    num_hashes = -log(false_positive_prob) / log(2);
    size_t num_bits;
    num_bits = (size_t)(items_estimate * num_hashes / log(2));

    if (num_bits == 0) {
        // throw error
        exit(0);
    }

    size_t num_bytes;
    num_bytes = (num_bits / CHAR_BIT) + (num_bits % CHAR_BIT ? 1 : 0);

    bf->num_items = 0;
    bf->num_hash_functions = num_hashes;
    bf->num_bits = num_bits;
    bf->bits = malloc(num_bytes);
    memset(bf->bits, 0, num_bytes);
    bf->hash_fn = hash_fn;
}

void bf_insert(bloom_filter_t *bf, const void *key, size_t len) {
    uint32_t hash = len;
    
    size_t i;
    for (i = 0; i < bf->num_hash_functions; ++i) {
        hash = bf->hash_fn(key, len, hash) % bf->num_bits;
        bf->bits[hash / CHAR_BIT] |= (1 << (hash % CHAR_BIT));
    }
    bf->num_items++;
}

int
bf_may_contain(bloom_filter_t *bf, const void *key, size_t len) {
    uint32_t hash = len;
    uint8_t byte_mask;
    uint8_t byte;

    size_t i;
    for (i = 0; i < bf->num_hash_functions; ++i) {
        hash = bf->hash_fn(key, len, hash) % bf->num_bits;
        byte = bf->bits[hash / CHAR_BIT];
        byte_mask = (1 << (hash % CHAR_BIT));
        
        if ((byte & byte_mask) == 0) {
            return 0;
        }
    }
    return 1;
}
