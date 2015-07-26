#include "bloom.h"

int main(int argc, char **argv) {
    bloom_filter_t bf;
    // bf_init(bf, 1000);
    bf->num_bits = 1000;
    bf->num_hash_functions = 1;
    bf->num_items = 0;
    num_bytes = (bf->num_bits / CHAR_BIT) + (bf->num_bits % CHAR_BIT ? 1 : 0);
    memset(bf->bits, 0, num_bytes);

    return 0;
}
