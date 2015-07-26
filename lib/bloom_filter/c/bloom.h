#ifndef BLOOM_H_
#define BLOOM_H_

#include <stdint.h>     // uint8_t, uint32_t
#include <sys/types.h>  // size_t
#include <math.h>       // log
#include <stdlib.h>     // malloc 
#include <string.h>     // memset

typedef struct {
    uint8_t *bits;
    size_t num_bits;
    size_t num_items;
    size_t num_hash_functions;
    uint32_t (*hash_fn)(const void *key, size_t len, uint32_t seed);
} bloom_filter_t;

void bf_init(
    bloom_filter_t *bf,
    uint32_t (*hash_fn)(const void *key, size_t len, uint32_t seed),
    size_t items_estimate,
    float false_positive_prob
);

void bf_insert(bloom_filter_t *bf, const void *key, size_t len);
int bf_may_contain(bloom_filter_t *bf, const void *key, size_t len);

#endif // BLOOM_H
