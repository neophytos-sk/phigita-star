/* Book: Algorithm Design by John Kleinberg and Eva Tardos
 *
 * Task: Weighted Interval Scheduling
 *
 * Goal: Accept as large a set of non-overlapping intervals as possible. Each
 * interval has a certain value (or weight) and we want to accept a set of
 * maximum value.
 *
 * Problem Description: We have n requests labeled 1,...,n with each request i
 * specifying a start time s[i] and a finish time f[i]. Each interval i
 * also has a value, or weight v[i]. Two intervals are compatible if they do
 * not overlap. The goal of our current problem is to select a subset
 * S \subseteq {1,...,n} of mutually compatible intervals, so as to maximize
 * the sum of the values of the selected intervals \sum_{i \in S}{v[i]}
 */

#include <algorithm>  // for sort
#include <cstdio>     // for printf
#include <vector>


using std::sort;
using std::vector;


typedef struct requestT {
  int start;
  int finish;
  int value;
  requestT(int arg_start, int arg_finish, int arg_value)
    : start(arg_start), finish(arg_finish), value(arg_value) {}

  bool operator==(const requestT& r) { 
    return this->start == r.start && 
      this->finish == r.finish && 
      this->value == r.value;
  }
} request_t;


bool compare_finish_time(request_t r1, request_t r2) {
  return r1.finish < r2.finish;
};

bool between(int x, int lower, int upper) {
  return (lower <= x && x <= upper);
}

bool overlap(request_t r1, request_t r2) {
  return (between(r1.start, r2.start, r2.finish) || 
	  between(r1.finish, r2.start, r2.finish) ||
	  between(r2.start, r1.start,r1.finish) ||
	  between(r2.finish,r1.start,r1.finish));
}

// Recursively compute optimal schedule
int ComputeSchedule_M1(const vector<request_t>& reqs,
		       const int prev[],
		       int back[],
		       int j) {

  if (j == 0)
    return 0;

  int included_sum = 0, excluded_sum = 0;

  // jth request is included
  included_sum = reqs[j-1].value + ComputeSchedule_M1(reqs,prev,back,prev[j]);

  // jth request is excluded
  excluded_sum = ComputeSchedule_M1(reqs, prev, back,j-1);

  if (included_sum > excluded_sum) {
    back[j] = prev[j];
    return included_sum;
  } else {
    back[j] = j-1;
    return excluded_sum;
  }
}


int ComputeSchedule_M2(const vector<request_t>& reqs, const int prev[],
		       int back[], int n) {

  int opt[1+n];

  opt[0] = 0;
  for (int j=1; j<=n; ++j) {

    int value = reqs[j-1].value; // reqs indices start from 0

    if (value + opt[prev[j]] > opt[j-1]) {
      opt[j] = value + opt[prev[j]];
      back[j] = prev[j];
    } else {
      opt[j] = opt[j-1];
      back[j] = j-1;
    }

  }

  return opt[n];
}

int ComputeOpt(const vector<request_t>& reqs, vector<request_t>& solution) {
  int prev[reqs.size()];
  int k;
  for (int j=1; j<=reqs.size(); ++j) {
    k=j;
    while(k>0 && overlap(reqs[j-1],reqs[k-1])) --k;
    prev[j] = k;
    printf("prev[%d]=%d\n",j,k);
  }

  int back[1+reqs.size()];
  int max_sum = 0;

  //max_sum = ComputeSchedule_M1(reqs, prev, back, reqs.size());
  max_sum = ComputeSchedule_M2(reqs, prev, back, reqs.size());

  k = back[reqs.size()];
  while (k>0) {
    solution.push_back(reqs[k-1]);
    k=back[k];
  }


  return max_sum;
}


int main(int argc, char *argv[]) {


  vector<request_t> reqs;

  reqs.push_back(request_t(1,4,2));
  reqs.push_back(request_t(2,6,4));
  reqs.push_back(request_t(5,7,4));
  reqs.push_back(request_t(3,10,7));
  reqs.push_back(request_t(8,11,2));
  reqs.push_back(request_t(9,12,1));

  // make sure requests are sorted in order of non-decreasing finish time
  sort(reqs.begin(), reqs.end(), compare_finish_time);


  vector<request_t> solution;
  int max_sum = ComputeOpt(reqs, solution);

  printf("max_sum = %d\n",max_sum);
  for (vector<request_t>::iterator it = solution.begin();
       it != solution.end();
       ++it) {

    printf("%d..%d of value %d\n",it->start,it->finish,it->value);

  }


  return 0;
}
