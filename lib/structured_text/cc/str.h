#ifndef __STR_H__
#define __STR_H__

#ifndef NULL
#define NULL ((void *) 0)
#endif

typedef int bool_t;
typedef unsigned int uint;

typedef struct {
    const char *data;
    uint length;
} string_t;


static inline bool_t StringEmpty(const string_t *const str) {
    return !str->length;
}

static inline void StringInit(string_t *str) {

    str->data = NULL;
    str->length = 0;

}

static inline void StringFree(string_t *str) {
    // do nothing
}

static inline void StringAssign(string_t *str, const char *data, uint length) {
    str->data = data;
    str->length = length;
}

static inline uint StringLength(const string_t *const str) {
    return str->length;
}

static inline const char *StringData(const string_t *const str) {
    return str->data;
}



#endif /* __STR_H__ */



