/*
 * This program computes the "distance" between two text files
 * as the angle between their word frequency vectors (in radians).
 *
 * For each input file, a word-frequency vector is computed as follows:
 *    (1) the specified file is read in
 *    (2) it is converted into a list of alphanumeric "words"
 *        Here a "word" is a sequence of consecutive alphanumeric
 *        characters.  Non-alphanumeric characters are treated as blanks.
 *        Case is not significant.
 *    (3) for each word, its frequency of occurrence is determined
 *    (4) the word/frequency lists are sorted into order alphabetically
 *
 * The "distance" between two vectors is the angle between them.
 * If x = (x1, x2, ..., xn) is the first vector (xi = freq of word i)
 * and y = (y1, y2, ..., yn) is the second vector,
 * then the angle between them is defined as:
 *    d(x,y) = arccos(inner_product(x,y) / (norm(x)*norm(y)))
 * where:
 *    inner_product(x,y) = x1*y1 + x2*y2 + ... xn*yn
 *    norm(x) = sqrt(inner_product(x,x))
 */

#include "document_distance.h"


/* Logarithmic Scaling: When adding an extra word, previously, we would just 
 * add one to that dimension. Now, dimension values, are updated by the 
 * following equation before normalizing the vector:
 *
 *    value = freq_map[*itr];
 *    value = value==0 ? 1 : ln(exp(value) + 1)
 *
 * So, when the same word is added, the vector length in that dimension
 * follows the sequence: 1, 1.31, 1.55, 1.74, 1.90, 2.04, ... This intuitively
 * makes sense. Supposing an article mentioning China 100 times is compared
 * to another article mentioning China only once. If one article mentions
 * China more than the other, it should be factored in. However, if one article
 * mentions China 100 times while a second mentions China 50 times, they should
 * be more similar than not. Logarithmic scaling makes that compromise.
 *
 * In C++, the function "log" computes the natural logarithm .
 *
 */
void count_frequency(const word_list_t &words, freq_map_t &freq_map) {

  word_list_t::const_iterator itr;
  const word_list_t::const_iterator stop = words.end();
  freq_map_t::iterator map_iter;
  const freq_map_t::const_iterator map_iter_stop = freq_map.end();
  for (itr=words.begin(); itr!=stop; ++itr) {
    map_iter = freq_map.find(*itr);
    if (map_iter==map_iter_stop)
      freq_map[*itr] = 1;
    else
      map_iter->second = log(exp(map_iter->second)+1);

  }
}


/*
 *   Inner product between two vectors, where vectors
 *   are represented as dictionaries of (word,freq) pairs.
 *
 *   Example: inner_product({"and":3,"of":2,"the":5},
 *                          {"and":4,"in":1,"of":1,"this":2}) = 14.0 
 */
double inner_product(const freq_map_t &d1, const freq_map_t &d2) {
  double sum = 0.0;
  freq_map_t::const_iterator itr1;
  freq_map_t::const_iterator itr2;
  const freq_map_t::const_iterator stop1 = d1.end();
  const freq_map_t::const_iterator stop2 = d2.end();
  for (itr1=d1.begin(); itr1!=stop1; ++itr1)
    if ( (itr2=d2.find(itr1->first)) != stop2)
      sum += itr1->second * itr2->second;

  return sum;
}


/*
 *   The input is a list of (word,freq) pairs, sorted alphabetically.
 *   Return the angle between these two vectors (using cosine distance equation).
 */
double vector_angle(const freq_map_t &d1, const freq_map_t &d2) {
  const double numerator = inner_product(d1,d2);
  const double denominator = sqrt( inner_product(d1,d1) *  inner_product(d2,d2) );
  return acos(numerator/denominator);
}

