#ifndef MD5_H
#define MD5_H

#include <inttypes.h>

typedef uint32_t uint32;

struct MD5Context {
        uint32 buf[4];
        uint32 bits[2];
        unsigned char in[64];
};

extern void MD5Init();
extern void MD5Update();
extern void MD5Final();
extern void MD5Transform();

/*
 * This is needed to make RSAREF happy on some MS-DOS compilers.
 */
typedef struct MD5Context MD5_CTX;

#endif /* !MD5_H */
