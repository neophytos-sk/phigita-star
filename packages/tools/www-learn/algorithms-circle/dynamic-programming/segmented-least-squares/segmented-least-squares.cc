/* Task: Segmented Least Squares Problem 
 *
 * Problem Description: Given a set P of points in the plane, partition P into
 * some number of segments (each segment is a subset of P that represents a
 * contiguous set of x-coordinates) such that it minimizes the penalty.
 *
 * The penalty of a partition is defined to be a sum of the following terms:
 *  (i) The number of segments into which we partition P, times a fixed given
 *      multiplier C > 0
 * (ii) For each segment, the error value of the optimal line through that
 *      segment.
 *
 */

#include <cstdio>
#include <cstdlib>
#include <vector>
#include <fstream>
#include <algorithm>
#include <cmath>
#include <limits>

using std::vector;
using std::ifstream;
using std::sort;
using std::numeric_limits;


typedef struct pointT {
  double x;
  double y;
  pointT(double arg_x, double arg_y) : x(arg_x), y(arg_y) {}
} point_t;

template <typename T>
struct less_than {
  bool operator()(const T p1, const T p2) const {
    return p1.x < p2.x;
  }
};



#define MAX 1000


/*
 * This function computes a linear model for a set of given data.
 *
 * PROBLEM DESCRIPTION:
 *  The method of least squares is a standard technique used to find
 *  the equation of a straight line from a set of data. Equation for a
 *  straight line is given by 
 *	 y = mx + b
 *  where m is the slope of the line and b is the y-intercept.
 *
 *  Given a set of n points {(x1,y1), x2,y2),...,xn,yn)}, let
 *      SUMx = x1 + x2 + ... + xn
 *      SUMy = y1 + y2 + ... + yn
 *      SUMxy = x1*y1 + x2*y2 + ... + xn*yn
 *      SUMxx = x1*x1 + x2*x2 + ... + xn*xn
 *
 *  The slope and y-intercept for the least-squares line can be 
 *  calculated using the following equations:
 *        slope (m) = ( SUMx*SUMy - n*SUMxy ) / ( SUMx*SUMx - n*SUMxx ) 
 *  y-intercept (b) = ( SUMy - slope*SUMx ) / n
 *
 */
double least_squares_error(const vector<point_t>::const_iterator &begin,
			   const vector<point_t>::const_iterator &end,
			   int n) {

  double sum_x, sum_y, sum_xy, sum_xx, sum_res, res, slope, 
         y_intercept, y_estimate;

  sum_x = 0; sum_y = 0; sum_xy = 0; sum_xx = 0;

  vector<point_t>::const_iterator it;
  for (it = begin; it != end; ++it) {

    sum_x += it->x;
    sum_y += it->y;
    sum_xy += (it->x) * (it->y);
    sum_xx += (it->x) * (it->x);
  }
  slope = (sum_x*sum_y - n*sum_xy) / (sum_x*sum_x - n*sum_xx);
  y_intercept = (sum_y - slope*sum_x) / n;

  sum_res = 0;  // residual sum
  for (it = begin; it != end; ++it) {	
    y_estimate = slope * (it->x) + y_intercept;
    res = (it->y) - y_estimate;
    sum_res += res*res;
  }

  return sum_res;

}

// for all pairs i<=j, compute the least squares error e[i][j] 
// for the segment points[i],...,points[j]
void compute_lse_matrix(const vector<point_t>& points, double error[MAX][MAX]) {

  for (int j=1;j<=points.size();++j) {
    for (int i=1; i<j;++i) {

      int n = j-i+1;
      error[i][j] = least_squares_error(points.begin()+(i-1),
					points.begin()+j,
					n);

    }
  }

}


double SegmentedLeastSquares(const vector<point_t>& points, double C) {
  size_t n = points.size();
  double error[MAX][MAX];

  compute_lse_matrix(points, error);

  double M[n+1];
  int back[n+1];
  double penalty;
  M[0] = 0;
  for (int j=1; j<=n; ++j) {

    /* compute optimal (least) error for any of the line segments ending at j */
    M[j] = numeric_limits<double>::max();
    for(int i=1; i<=j; ++i) {
      penalty = error[i][j] + C + M[i-1];
      if (M[j] > penalty) {
	M[j] = penalty;
	back[j] = i;	// keep track of i, boundary of segment
      }
    }
  }


  // print error matrix
  for (int i=0;i<=n;++i) {
    for (int j=0;j<n;++j) {
      printf("%10.3f ",error[i][j]);
    }
    printf("\n");
  }



  // Find Segments
  printf("Segment/Split at the following vector indices:\n");
  int j=n;
  while (j>1) {
    printf("Adding line from point %d to %d with error %f\n",j,back[j],M[j]);
    j = back[j];
  }




  return M[n];
}



int main(int argc, char *argv[]) {



  if (argc != 3) {
    fprintf(stderr,"Usage: %s [penalization_factor=0.2] [file=unsorted_data.txt]\n",argv[0]);
    return 1;
  }


  /* penalization factor */
  double C = atof(argv[1]);  // by tuning C we can penalize the use of 
                             // additional lines to a greater or lesser extent

  char *filename = argv[2]; // e.g. unsorted_data.txt

  vector<point_t> points;


  // Example (average heights and weights for American women aged 30-39)
  // Data collected from http://en.wikipedia.org/wiki/Ordinary_least_squares 
  ifstream infile;
  //infile.open("data.txt");

  if (1) {
    infile.open(filename);
    double x,y;
    while (infile >> x >> y)
      points.push_back(point_t(x,y));
    infile.close();
  } else {
    for (int ix = 1; ix<=10; ++ix) {
      //double iy = pow(ix,3) + pow(ix,2) + ix + 3;
      double iy = pow(ix,2);
      points.push_back(point_t(ix,iy));
    }
  }



  sort(points.begin(),points.end(),less_than<point_t>());

  for(vector<point_t>::iterator it = points.begin();
      it != points.end();
      ++it) {
    //printf("%f,%f; ",it->x,it->y);
    printf("(%f,%f)\n",it->x,it->y);
  }
  printf("\n");
  
  
  double min_penalty = SegmentedLeastSquares(points,C);
  printf("min_penalty=%f\n",min_penalty);


  return 0;

}

