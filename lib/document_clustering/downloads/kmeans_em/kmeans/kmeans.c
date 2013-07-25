/**
 *
 *	Data Mining 4TF3
 *	k-means implementation
 *	George A. Papayiannis
 *
 *	Inputs: <infile> <#observations> <#clusters>
 *	Output: To screen the clusters
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>

/**
 *	Structure used to hold the points in the dataset
 *	x,y are the 2D values
 *	c is the cluster the point is currently part of
 *	d is the ditance to the nearest cluster
 */

typedef struct values {
	int x, y;
	int c;
	int d;
} point;

/**
 *	Function definitions
 */

int distance(point a, point b);

/**
 *	Main function
 */

int main(int argc, char *argv[]) {
	// check to ensure proper number of inputs provided
	if(argc < 3) {
		printf("USAGE: kmeans <infile> <#observations> <#clusters>\n");
		return -1;
	}
	//
	int num_points = atoi(argv[2]);
	int lcount = 0;
	int i, j, rand_x, rand_y, dist, done;
	int max_x = 0; 
	int max_y = 0;
	int num_clusters = atoi(argv[3]);
	//
	FILE *infile;
	point dataset[num_points];
	point centers[num_clusters];
	point old_centers[num_clusters];
	//
    char *str1;
	char line[100];
	//
	printf("\n---------------------------------------------\n");
	printf("k-means: processing input\n");
	printf("---------------------------------------------\n");
	printf("\nk-means: number of clusters %i\n",num_clusters);
	printf("k-means: number of points %i\n\n",num_points);
	//
	// initialize the dataset to -1
	//
	for (i=0; i<num_points; i++) {
		point value;
		value.x = -1;
		value.y = -1;
		value.c = -1;
		value.d = RAND_MAX;
		dataset[i] = value;
	}
	//	
	// open the file - if NULL is returned there was an error
	//
	if((infile = fopen(argv[1], "r")) == NULL) {
		printf("k-means: error opening file\n");
		exit(1);
	}
	//
	// read the file - set the dataset with the actual values
	//
	while( fgets(line, sizeof(line), infile) != NULL ) {
		point temp;
		temp = dataset[lcount];
		//
        str1 = strtok(line, " ");
		temp.x = atoi(str1);
		//	
		str1 = strtok(NULL, " ");
		temp.y = atoi(str1);
		//
		// find the maximums
		if (temp.x > max_x) {
			max_x = temp.x;
		}
		if (temp.y > max_y)	{
			max_y = temp.y;
		}
		//
		dataset[lcount] = temp;
		lcount++;
		printf("k-means: line %d - %i %i\n", lcount, temp.x, temp.y);	
	}
	// close the handle on the infile
	fclose(infile);
	//
	// seed the random generator with the time
	//
	srand(time(0));
	printf("\n---------------------------------------------\n");
	printf("k-means: random centers found\n");
	printf("---------------------------------------------\n\n");
	//
	// randomly create the centers
	//
	for (i=0; i<num_clusters; i++ ) {
		point center;
		center.x = rand_x = (double)(rand() / (double)RAND_MAX) * max_x;
		center.y = rand_y = (double)(rand() / (double)RAND_MAX) * max_y;
		center.c = i;
		centers[i] = center;
		printf("k-means: center %i (%i,%i)\n",center.c,center.x,center.y);
	}
	//
	// cluster the dataset - loop until done
	//
	printf("\n---------------------------------------------\n");
	printf("k-means: iterating till centers don't change..\n");
	printf("---------------------------------------------\n\n");

	int iteration = 0;
	while(1) {
		// cluster the data based on the centers[]

		printf("k-means: iteration %i\n", iteration);
		for (i=0; i<num_clusters; i++ ) {
			for (j=0; j<num_points; j++ ) {
				point rt;
				rt = dataset[j];
				dist = distance(centers[i],rt);
				if (dist < rt.d) {
					rt.d = dist;
					rt.c = i;
					dataset[j] = rt;
				}
			}				
		}
		//
		// compute the new center for each cluster
		//
		int new_x;
		int new_y;
		int count;
		for (i=0; i<num_clusters; i++ ) {
			new_x = 0;
			new_y = 0;
			count = 0;
			for (j=0; j<num_points; j++ ) {
				point rt;
				rt = dataset[j];
				if (rt.c == i) {
					new_x = new_x + rt.x;
					new_y = new_y + rt.y;
					count++;
				}
			}
			point center;
			center = centers[i];
			old_centers[i] = center;
			center.x = new_x/count;
			center.y = new_y/count;
			centers[i] = center;
		}
		//
		// check to see if the centers are the same
		// all centers must be the same as the previous
		// for us to exit
		//
		done = 0;
		for (i=0; i<num_clusters; i++ ) {
			point curr_cent;
			point old_cent;
			curr_cent = centers[i];
			old_cent = old_centers[i];
			if ((curr_cent.x == old_cent.x) && (curr_cent.y == old_cent.y)) {
				//
				//
			} else {
				done = 1;
			}
		}

		if (done == 0){
			break;
		}
		iteration++;
	}
	//
	// output clusters
	//
	printf("\n---------------------------------------------\n");
	printf("k-means: clustering complete\n");
	printf("---------------------------------------------\n");
	for (i=0; i<num_clusters; i++ ) {
		point center = centers[i];
		printf("\nk-means: cluster %i final center (%i,%i)\n", i,center.x,center.y);
		for (j=0; j<num_points; j++ ) {
			point rt;
			rt = dataset[j];
			// output based on cluster
			if (rt.c == i) {
				printf("k-means: cluster %i point (%i,%i)\n",rt.c,rt.x,rt.y);
			}
		}						
	}
}

/**
 *	Used to calculate the distance between 2 points
 */

int distance(point a, point b) {
	return sqrt(pow((b.x - a.x),2) + pow((b.y - a.y),2));
}
