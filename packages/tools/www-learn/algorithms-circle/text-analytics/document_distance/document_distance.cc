/* Copyright 2010 PHIGITA LTD
 * Author: Neophytos Demetriou
 *
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

std::string strip_punctuation(std::string input) {
  input.erase(std::remove_if(input.begin(),input.end(),ispunct),input.end());
  return input;
}

/*
 * Read the text file with the given filename;
 * return a list of the lines of text in the file.
 */
std::list<std::string> read_file(const char *filename) {

  std::list<std::string> result;

  std::ifstream infile(filename);
  if (!infile.is_open()) {
    fprintf(stderr,"Cannot open file: %s", filename);
    return result;
  }

  std::string line;
  while (getline(infile,line)) {
    result.push_back(strip_punctuation(line));
  }
  return result;
}


/*
 * Parse the given list L of text lines into words.
 * Return list of all words found.
 */
std::list<std::string> get_words_from_lines_list(const std::list<std::string> &lines) {
  std::list<std::string> result;
  std::list<std::string>::const_iterator itr;
  for (itr=lines.begin(); itr!=lines.end(); ++itr) {

    // words_in_line = get_words_from_string(*itr);
    // word_list.extend(words_in_line);
    std::stringstream ss;
    ss << *itr;
    std::string word;
    while (ss >> word) {
      result.push_back(word);
    }
  }
  return result;
}


std::tr1::unordered_map<std::string,int> count_frequency(const std::list<std::string> &words) {
  std::tr1::unordered_map<std::string,int> result;
  std::list<std::string>::const_iterator itr;
  for (itr=words.begin(); itr!=words.end(); ++itr) {
    ++result[*itr];
  }
  return result;
}


std::tr1::unordered_map<std::string,int> word_frequencies_for_file(const char *filename) {
  const std::list<std::string> lines = read_file(filename);
  const std::list<std::string> word_list = get_words_from_lines_list(lines);
  const std::tr1::unordered_map<std::string,int> freq_mapping = count_frequency(word_list);

  printf("#lines: %zd\n#words: %zd\n#dinstict_words: %zd\n",lines.size(), word_list.size(),freq_mapping.size());

  /*
  std::tr1::unordered_map<std::string,int>::const_iterator itr;
  for (itr=freq_mapping.begin(); itr!=freq_mapping.end(); ++itr)
    printf("%s: %d\n",itr->first.c_str(),itr->second);
  */
  return freq_mapping;
}


/*
 *   Inner product between two vectors, where vectors
 *   are represented as dictionaries of (word,freq) pairs.
 *
 *   Example: inner_product({"and":3,"of":2,"the":5},
 *                          {"and":4,"in":1,"of":1,"this":2}) = 14.0 
 */
long inner_product(std::tr1::unordered_map<std::string,int> &d1, std::tr1::unordered_map<std::string,int> &d2) {
  long sum = 0;
  std::tr1::unordered_map<std::string,int>::const_iterator itr1;
  std::tr1::unordered_map<std::string,int>::const_iterator itr2;
  for (itr1=d1.begin(); itr1!=d1.end(); ++itr1)
    if ( (itr2=d2.find(itr1->first)) != d2.end())
      sum += static_cast<long>(itr1->second) * static_cast<long>(itr2->second);
    
  return sum;
}


/*
 *   The input is a list of (word,freq) pairs, sorted alphabetically.
 *   Return the angle between these two vectors (using cosine distance equation).
 */
double vector_angle(std::tr1::unordered_map<std::string,int> &d1, std::tr1::unordered_map<std::string,int> &d2) {
  double numerator = static_cast<double>(inner_product(d1,d2));
  double denominator = sqrt(static_cast<double>(inner_product(d1,d1))*static_cast<double>(inner_product(d2,d2)));
  printf("numerator=%f denominator=%f division=%f\n",numerator,denominator,numerator/denominator);
  return acos(numerator/denominator);
}


int main(int argc, char *argv[]) {
  if (argc != 3) {
    fprintf(stderr, "Usage: %s file1 file2\n", argv[0]);
    return 1;
  }

  std::tr1::unordered_map<std::string,int> word_freq_1 = word_frequencies_for_file(argv[1]);
  std::tr1::unordered_map<std::string,int> word_freq_2 = word_frequencies_for_file(argv[2]);

  //printf("inner product: %d\n",inner_product(sorted_word_list_1,sorted_word_list_2));
  printf("The distance between the documents is: %0.6f (radians)\n",vector_angle(word_freq_1,word_freq_2));

  return 0;
}
