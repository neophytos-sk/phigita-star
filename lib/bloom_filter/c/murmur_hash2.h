#ifndef MURMUR_H_
#define MURMUR_H_

#include <stdint.h>     // uint8_t, uint32_t
#include <sys/types.h>  // size_t

uint32_t MurmurHash2 ( const void * key, size_t len, uint32_t seed );

#endif
