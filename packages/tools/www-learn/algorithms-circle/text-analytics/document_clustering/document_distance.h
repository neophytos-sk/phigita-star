#ifndef DOCUMENT_DISTANCE_H
#define DOCUMENT_DISTANCE_H

#include <cmath>
#include <string>

#include "common.h"


void count_frequency(const word_list_t &words, freq_map_t &freq_map);
double inner_product(const freq_map_t &d1, const freq_map_t &d2);
double vector_angle(const freq_map_t &d1, const freq_map_t &d2);


#endif
