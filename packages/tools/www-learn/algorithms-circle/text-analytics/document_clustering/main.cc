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



/* compute_clusters

   Input: 
     int k;
     list<string> data;
     word_hash_set_t stopwords;
   Output:
     vector<double>& stats;

     ----------



   Evaluator *eval = new Evaluator();

   datapoint_list_t dps;
   create_datapoint_list(data,dps);

   // consider using k-means++ to computer the k initial cluster centers
   double threshold = compute_threshold(dps, k); //    Threshold threshold;


   datamap dmap(eval,threshold);
   vector<datapoint>::const_iterator itr=dps.begin();
   const vector<datapoint>::const_iterator stop=dps.end();
   for(; itr!=stop; ++itr)
     dmap.insert_datapoint(*itr);

   stats->push_back(eval->getLow());
   stats->push_back(eval->getHigh());
   stats->push_back(eval->getAverage());
   stats->push_back(eval->getOutAvg());
   stats->push_back(eval->getInAvg());
   stats->push_back(eval->getStdev());
   stats->push_back(eval->getOutStdev());

   mp.decrease_weights();
   return dmap.get_clusters();

 */

void read_stopwords(const char *filename, word_hash_set_t& stopwords) {
  std::ifstream infile;
  infile.open(filename);
  std::string word;
  while (infile >> word)
    stopwords.insert(word);

}

void pretty_print(const cluster_vector_t& clusters,char *argv[]) {
  cluster_vector_t::const_iterator iter = clusters.begin();
  const cluster_vector_t::const_iterator stop = clusters.end();
  for(; iter != stop; ++iter) {
    std::list<int> ids = iter->get_identities();
    std::list<int>::const_iterator cluster_iter;
    std::list<int>::const_iterator cluster_stop = ids.end();
    cluster_iter = ids.begin();
    for(; cluster_iter != cluster_stop; ++cluster_iter) {
      printf("%d %s\n", *cluster_iter, argv[*cluster_iter]);
    }
    printf("\n\n");
  }
}


int main(int argc, char *argv[]) {
  if (argc < 3) {
    fprintf(stderr, "Usage: %s k file1 ... fileN\n", argv[0]);
    return 1;
  }
  
  int k = atoi(argv[1]);

  word_hash_set_t stopwords;
  read_stopwords("commonwords",stopwords);

  datapoint_vector_t dps;
  for (int i=2; i<argc; ++i) {
    word_list_t word_list;
    read_words_from_file(argv[i], word_list, stopwords);
    dps.push_back(datapoint(i,word_list));
  }

  printf("dps.size()=%zd\n",dps.size());

  datamap mapper;
  mapper.analyze(dps,k);
  cluster_vector_t clusters;
  mapper.get_clusters(clusters);
  pretty_print(clusters,argv);

  return 0;

  /*
  freq_map_t word_freq_1;
  freq_map_t word_freq_2;
  word_frequencies_for_file(argv[1], word_freq_1,stopwords);
  word_frequencies_for_file(argv[2], word_freq_2,stopwords);

  printf("The angle between the documents is: %0.6f (radians)\n",vector_angle(word_freq_1,word_freq_2));


  word_list_t word_list_1, word_list_2;
  read_words_from_file(argv[1],word_list_1,stopwords);
  read_words_from_file(argv[2],word_list_2,stopwords);

  datapoint dp1(1,word_list_1);
  datapoint dp2(2,word_list_2);

  printf("The distance between the documents is: %0.6f\n", dp1.cosine_distance_from(dp2));
  printf("The angle between the documents is: %0.6f\n", dp1.vector_angle_from(dp2));

  datapoint_vector_t dps;
  dps.push_back(dp1);
  dps.push_back(dp2);
  datamap dm;
  dm.analyze(dps,2);

  return 0;
  */
}
