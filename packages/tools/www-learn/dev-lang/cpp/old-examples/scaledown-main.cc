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


double RandomNumber() {
  return rand() / (RAND_MAX + 1.0);
}


/* default learning_rate = 0.01 */
double loc[1000][2];
void scaledown(vector<datapoint>& dps, double learning_rate) {

  int num_dimensions=2;

  srand(time(NULL));

  const int n = dps.size();

  /* the real distances between every pair of items */
  double realdist[n][n];
  for(int i=0;i<n;++i)
    for(int j=0;j<n;++j)
      realdist[i][j]=dps.at(i).cosine_distance_from(dps.at(j));

  double outersum=0.0;
  
  /* Randomly initialize the starting points of the locations in 2D */
  for(int i=0;i<n;++i)
    for(int j=0;j<n;++j)
      loc[i][0]=RandomNumber(), loc[i][1]=RandomNumber();


  double fakedist[n][n];
  int lasterror = std::numeric_limits<double>::max();
  for(int m=0;m<1000;++m) {
    for(int i;i<n;++i) {
      for(int j;j<n;++j) {
	double sum=0;
	for(int x=0;x<num_dimensions;++x)
	  sum+=pow(loc[i][x]-loc[j][x],2);
	fakedist[i][j]=sqrt(sum);
      }
    }


    /* move points */
    int grad[n][2];

    double totalerror=0;
    for(int k=0;k<n;++k) {
      for(int j=0;j<n;++j) {
	if (j==k) continue;
	
	/* the error is percent defiference between the distances */
	double errorterm = (fakedist[j][k]-realdist[j][k])/realdist[j][k];

	/* each point needs to be moved away from or towards the other
	 * point in proportion to how much error it has
	 */
	grad[k][0] += ((loc[k][0]-loc[j][0])/fakedist[j][k])*errorterm;
	grad[k][1] += ((loc[k][1]-loc[j][1])/fakedist[j][k])*errorterm;

	/* keep track of the total error */
	totalerror += abs(errorterm);

      }
    }

    printf("total error: %.2f\n", totalerror);

    /* if the answer got worse by moving the points, we are done */
    if (lasterror < totalerror) break;
    lasterror = totalerror;

    /* move each of the points by the learning rate times the gradient */
    for(int k=0;k<n;++k) {
      loc[k][1] -= learning_rate*grad[k][0];
      loc[k][1] -= learning_rate*grad[k][1];
    }

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

  printf("dps.size()=%zd\n",dps.size());





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


  /* --------------------------------------- */

  scaledown(dps,0.01);

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
      printf("%d \t %.2f \t %.2f \t %s\n",iter->get_centroid().get_id(), loc[index][0], loc[index][1],buf.c_str());
      //printf("%d %s %s\n", *cluster_iter, argv[index],buf.c_str());
      infile.close();
    }
    // printf("\n\n");
  }


  return 0;

}
