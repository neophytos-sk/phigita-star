/*
 * Grade Maximization
 *
 * Dynamic Programming Solution: Let O[n][H] be the
 * maximum possible grade for at most n projects 
 * and H hours.
 *
 * OPT[n][H] = max_{0<h<H} { OPT[n-1][H-h] + G[i][h] }
 * OPT[i][j] = max_{0<k<j} { OPT[i-1][j-k] + G[i][k] }
 *
 * Time Complexity: O(nH^2)
 *
 */

#include <stdio.h>

/* max number of projects */
#define MAX_N 100

/* max number of hours */
#define MAX_H 100


int grade(int G[MAX_N][MAX_H],int i,int h) {
  int j,sum=0;
  for(j=1;j<=h;j++)
    sum += G[i-1][j-1];
  return sum;
}


int main() {

  int n=3;
  int H=3;

  /* for every project i, we are given an array G[i][H] so that, if we spend k
   * hours on project i, our grade for that project will be grade(G,i,k)
   */
  int G[MAX_N][MAX_H] = {{70,10,20},{30,70,0},{35,40,25}};


  int OPT[MAX_N][MAX_H];
  int best[MAX_N][MAX_H];
  int i,j,k;


  /* boundary conditions */
  for(j=0;j<=H;j++) { OPT[0][j]=0; best[0][j]=0; }


  /* grade maximization */
  for(i=1;i<=n;i++) {
    for(j=1;j<=H;j++) {
      for(k=0;k<=j;k++) {
	int this_grade = OPT[i-1][j-k]+grade(G,i,k);
	if (OPT[i][j] < this_grade) {
	  OPT[i][j] = this_grade;
	  best[i][j] = k;
	}
      }
    }
  }
  
  printf("Max Grade=%d\n",OPT[n][H]);

  i=n;j=H;
  while(i!=0) {
    printf("project %d: %d hours\n",i,best[i][j]);
    j=j-best[i][j];
    i=i-1;
  }

  /*
  for(i=0;i<=n;i++) {
    for(j=0;j<=H;j++) {
      printf("(%d,%d) ",best[i][j],OPT[i][j]);
    }
    printf("\n");
  }
  */

  return 0;

}

// k2pts@phigita.net
