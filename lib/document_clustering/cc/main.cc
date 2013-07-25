#include "document_distance.h"
#include "datapoint.h"
#include "datamap.h"

#include <algorithm>          // For remove_if
#include <cstdio>
#include <cctype>
#include <cstdlib>
#include <fstream>
#include <sstream>


void strip_punctuation(std::string& input) {
  input.erase(std::remove_if(input.begin(),input.end(),ispunct),input.end());
}

/*
 * Read the text file with the given filename;
 * return a list of the words of text in the file.
 */
void read_words_from_file(const char *filename, word_list_t& word_list, const word_hash_set_t& stopwords) {

  std::ifstream infile(filename);
  if (!infile.is_open()) {
    fprintf(stderr,"cannot open file %s\n",filename);
    return /*ERROR*/;
  }

  std::string line, word;
  while (getline(infile,line)) {
    strip_punctuation(line);
    std::stringstream ss;
    ss << line;
    while (ss >> word)
      if (!stopwords.count(word))
	word_list.push_back(word);
  }
}


void word_frequencies_for_file(const char *filename, freq_map_t& freq_map, const word_hash_set_t& stopwords) {

  word_list_t word_list;
  read_words_from_file(filename, word_list,stopwords);
  count_frequency(word_list, freq_map);

  //printf("#words: %zd\n#dinstict_words: %zd\n",word_list.size(),freq_map.size());

}


void read_stopwords(const char *filename, word_hash_set_t& stopwords) {
  std::ifstream infile;
  infile.open(filename);
  std::string word;
  while (infile >> word)
    stopwords.insert(word);

}


void pretty_print(const vector<cluster>& clusters,char *argv[]) {
  std::ifstream infile;
  vector<cluster>::const_iterator iter = clusters.begin();
  const vector<cluster>::const_iterator stop = clusters.end();
  for(; iter != stop; ++iter) {
    std::set<int> ids = iter->get_identities();
    std::set<int>::const_iterator cluster_iter;
    std::set<int>::const_iterator cluster_stop = ids.end();
    cluster_iter = ids.begin();
    for(; cluster_iter != cluster_stop; ++cluster_iter) {
      int index = *cluster_iter + 3; // skipping over parameters and executable file
      infile.open(argv[index]);
      std::string buf;
      getline(infile,buf);
      printf("%d %s %s\n", *cluster_iter, argv[index],buf.c_str());
      infile.close();
    }
    printf("\n\n");
  }
}


int main(int argc, char *argv[]) {
  if (argc < 4) {
    fprintf(stderr, "Usage: %s k num_iter file1 ... fileN\n", argv[0]);
    return 1;
  }
  
  int k = atoi(argv[1]);
  int num_iter = atoi(argv[2]);

  word_hash_set_t stopwords;
  read_stopwords("commonwords",stopwords);

  vector<datapoint> dps;
  for (int i=3; i<argc; ++i) {
    word_list_t word_list;
    read_words_from_file(argv[i], word_list, stopwords);
    dps.push_back(datapoint(i-3,word_list));
  }

  // printf("dps.size()=%zd\n",dps.size());


  /* --------------------------------------- */

  datamap mapper;
  vector<cluster> clusters;
  double cost, min_cost = std::numeric_limits<double>::max();
  for(int i=0;i<num_iter;++i) {
    mapper.kmeans(dps,k);

    evaluator *e = mapper.get_evaluator();
    cost = e->getInSqrSum();
    if (cost < min_cost) {
      min_cost = cost;
      mapper.get_clusters(clusters);
    }
  }

  printf("k=%d min_cost - InSqrSum: %.4f\n", k, min_cost);
  pretty_print(clusters,argv);



  return 0;

}
