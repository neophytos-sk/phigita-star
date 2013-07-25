/**
 *
 *	Data Mining 4TF3
 *	em implementation
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
 *	Mean structure
 */

typedef struct mu_values {
	double mu_x;
	double mu_y;
} mu_stats;

/**
 *	Standard deviation structure
 */

typedef struct sd_values {
	double sd_x;
	double sd_y;
} sd_stats;

/**
 *	Probability structure
 */

typedef struct p_values {
	float p_x;
	float p_y;
} p_stats;

/**
 *	Cluster structure
 */

typedef struct cluster_values {
	mu_stats mu;
	sd_stats sd;
	p_stats p;
	p_stats e;
} cluster_stat;

/**
 *	Structure used to hold the points in the dataset
 *	x,y are the 2D values
 *	c is the cluster the point is currently part of
 *	p is the probability the given point is part of c
 */

typedef struct values {
	int x, y;
	int c;
	p_stats p;
} point;


/**
 *	Function definitions
 */

double normdist(int pt, double mu, double sd);
mu_stats calc_mu(point ds[], int num_points, int cluster);
sd_stats calc_sd(point ds[], int num_points, int cluster, mu_stats mu);
p_stats calc_p(point ds[], int num_points, int cluster);
p_stats calc_error(point ds[], int num_points, int cluster);

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
	int i, j, rand_x, rand_y, done;
	int max_x = 0; 
	int max_y = 0;
	int num_clusters = atoi(argv[3]);
	//
	FILE *infile;
	//
	point dataset[num_points];
	cluster_stat cluster_arr[num_clusters];
	cluster_stat old_cluster_arr[num_clusters];
	//
    char *str1;
	char line[100];
	//
	printf("\n---------------------------------------------\n");
	printf("em: processing input\n");
	printf("---------------------------------------------\n");
	printf("\nem: number of clusters %i\n",num_clusters);
	printf("em: number of points %i\n\n",num_points);
	//
	// initialize the dataset to -1
	//
	for (i=0; i<num_points; i++) {
		point value;
		value.x = -1;
		value.y = -1;
		value.c = -1;
		value.p.p_x = 0.01;
		value.p.p_y = 0.01;
		dataset[i] = value;
	}
	//	
	// open the file - if NULL is returned there was an error
	//
	if((infile = fopen(argv[1], "r")) == NULL) {
		printf("em: error opening file\n");
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
		printf("em: line %d - %i %i\n", lcount, temp.x, temp.y);	
	}
	// close the handle on the infile
	fclose(infile);
	//
	// seed the random generator with the time
	//
	srand(time(0));
	printf("\n---------------------------------------------\n");
	printf("em: randomly divide the dataset into %i clusters\n", num_clusters);
	printf("---------------------------------------------\n\n");
	//
	// randomly create the centers
	//
	int partition = num_points / num_clusters;
	int temp_count = 0;
	
	point temp_point;
	point temp_ds[partition];
	mu_stats mu_result;

	for (i=0; i<num_clusters; i++ ) {
		temp_count = 0;
		for (j=(partition*i); j<partition*(i+1); j++) {
			temp_point = dataset[j];
			temp_point.c = i;
			//temp_ds[temp_count] = temp_point;
			dataset[j] = temp_point;
			temp_count++;
		}	
		mu_result = calc_mu(dataset, num_points, i);
		sd_stats sd_result = calc_sd(dataset, num_points, i, mu_result);
		cluster_stat cluster;
		cluster.mu = mu_result;
		cluster.sd = sd_result;
		cluster.p = calc_p(dataset,num_points,i);
		cluster.e = calc_error(dataset,num_points,i);
		cluster_arr[i] = cluster;
		printf("em: cluster %i mu %f %f sd %f %f p %f %f e %f %f\n", i, cluster.mu.mu_x, cluster.mu.mu_y, cluster.sd.sd_x, cluster.sd.sd_y, cluster.p.p_x, cluster.p.p_y, cluster.e.p_x, cluster.e.p_y);
	}
	//
	// cluster the dataset - loop until done
	//
	printf("\n---------------------------------------------\n");
	printf("em: iterating till mu and sd close enough..\n");
	printf("---------------------------------------------\n\n");

	int iteration = 0;
	while(1) {
		// check which cluster a point should be a part of
		printf("em: iteration %i\n", iteration);
		for (i=0; i<num_clusters; i++ ) {
			for (j=0; j<num_points; j++ ) {
				point rt;
				cluster_stat ct;
				p_stats pr;
				ct = cluster_arr[i];
				rt = dataset[j];
				pr.p_x = ct.p.p_x * normdist(rt.x, ct.mu.mu_x, ct.sd.sd_x);
				pr.p_y = ct.p.p_y * normdist(rt.y, ct.mu.mu_y, ct.sd.sd_y);
				rt.p = pr;
				if (pr.p_x > ct.p.p_x && pr.p_y > ct.p.p_y){
					//printf("%i\n",i);
					rt.c = i;
				}
				dataset[j] = rt;
				// printf("%f\n",temp_result_x * temp_result_y);
			}				
		}
		//
		// detemine the new mixture, calculate the error
		//
		done = 1;
		for (i=0; i<num_clusters; i++ ) {
			cluster_stat cluster;
			cluster = cluster_arr[i];
			cluster.p = calc_p(dataset,num_points,i);
			cluster.mu = calc_mu(dataset, num_points, i);
			cluster.sd = calc_sd(dataset, num_points, i, mu_result);
			p_stats ce = calc_error(dataset,num_points,i);
			//printf("%f, %f, %f \n", ce.p_x, cluster.e.p_x, abs(ce.p_x) - abs(cluster.e.p_x));
			cluster.e = ce;
			cluster_arr[i] = cluster;
			printf("em: cluster %i mu %f %f sd %f %f p %f %f e %f %f\n", i, cluster.mu.mu_x, cluster.mu.mu_y, cluster.sd.sd_x, cluster.sd.sd_y, cluster.p.p_x, cluster.p.p_y, cluster.e.p_x, cluster.e.p_y);
			if ( (abs(ce.p_x) - abs(cluster.e.p_x)) < 1.0) {
				done = 0;
			}
			//	printf("error: %f\n",abs(ce.p_x - cluster.e.p_x));
				
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
	printf("em: clustering complete\n");
	printf("---------------------------------------------\n");
	for (i=0; i<num_clusters; i++ ) {
		cluster_stat cluster = cluster_arr[i];
		printf("em: final cluster %i mu %f %f sd %f %f p %f %f e %f %f\n", i, cluster.mu.mu_x, cluster.mu.mu_y, cluster.sd.sd_x, cluster.sd.sd_y, cluster.p.p_x, cluster.p.p_y, cluster.e.p_x, cluster.e.p_y);
		for (j=0; j<num_points; j++ ) {
			point rt;
			rt = dataset[j];
			// output based on cluster
			if (rt.c == i) {
				printf("em: cluster %i point (%i,%i)\n",rt.c,rt.x,rt.y);
			}
		}						
	}
}

/**
 *	Density function for normal distribution
 */

double normdist(int pt, double mu, double sd) {
	double result = 0.0;
	result = 1/(sqrt(2*M_PI)*sd);
	result = result * exp( (pow((double)pt - mu, 2.0)) / (2.0 * pow(sd,2.0)));
	return result;
}

/**
 *	Calculate mu of the given cluster.  The probability of each point
 *	being part of that given cluster will be used as a weight for that point.
 *	This is following what was said in DM: PMLTaT - WF
 */

mu_stats calc_mu(point ds[], int num_points, int cluster) {
	//
	int i = 0;
	p_stats prob;
	//
	point temp;
	mu_stats result;
	//
	result.mu_x = 0.0;
	result.mu_y = 0.0;
	prob.p_x = 0.0;
	prob.p_y = 0.0;
	//
	for (i=0; i<num_points; i++) {
		temp = ds[i];
		//printf("\n%i %i %i %i",start_index, end_index, temp.c, i);
		if (temp.c == cluster) {
			
			//printf("\nsanity: %i %i %i %i",temp.x,temp.y,temp.c, i);

			result.mu_x = result.mu_x + (temp.x*temp.p.p_x);
			result.mu_y = result.mu_y + (temp.y*temp.p.p_y);
			prob.p_x = prob.p_x + temp.p.p_x;
			prob.p_y = prob.p_y + temp.p.p_y;

		}
	}
	//
	result.mu_x = result.mu_x/prob.p_x;
	result.mu_y = result.mu_y/prob.p_y;
	//
	return result;
}

/**
 *	Calculate sd of the given cluster, based on the mu.  The probability of each point
 *	being part of that given cluster will be used as a weight for that point.
 *	This is following what was said in DM: PMLTaT - WF
 */

sd_stats calc_sd(point ds[], int num_points, int cluster, mu_stats mu) {
	int i = 0;
	p_stats prob;
	//
	point temp;
	sd_stats result;
	//
	result.sd_x = 0.0;
	result.sd_y = 0.0;
	prob.p_x = 0.0;
	prob.p_y = 0.0;

	//
	for (i=0; i<num_points; i++) {
		temp = ds[i];
		if (temp.c == cluster) {
			result.sd_x = result.sd_x + (temp.p.p_x * pow((temp.x - mu.mu_x),2));
			result.sd_y = result.sd_y + (temp.p.p_y * pow((temp.y - mu.mu_y),2));
			prob.p_x = prob.p_x + temp.p.p_x;
			prob.p_y = prob.p_y + temp.p.p_y;
		}
	}
	//
	result.sd_x = result.sd_x/prob.p_x;
	result.sd_y = result.sd_y/prob.p_y;
	//
	return result;
}

/**
 *	Calculates the probability of a given cluster
 */

p_stats calc_p(point ds[], int num_points, int cluster) {
	int i=0;
	int count = 0;
	p_stats result;
	result.p_x = 0.0;
	result.p_y = 0.0;
	
	point temp;

	for (i=0; i<num_points; i++) {
		temp = ds[i];
		if (temp.c == cluster) {
			result.p_x = result.p_x + temp.p.p_x;
			result.p_y = result.p_y + temp.p.p_y;
			count++;
		}
	}
	//
	result.p_x = result.p_x / count;
	result.p_y = result.p_y / count;
	//
	return result;

}

/**
 *	Calculates the error of a given cluster
 */

p_stats calc_error(point ds[], int num_points, int cluster) {
	int i=0;
	p_stats result;
	result.p_x = 0.0;
	result.p_y = 0.0;
	
	point temp;

	for (i=0; i<num_points; i++) {
		temp = ds[i];
		if (temp.c == cluster) {
			result.p_x = result.p_x + log(temp.p.p_x);
			result.p_y = result.p_y + log(temp.p.p_y);
		}
	}
	//
	return result;
}
