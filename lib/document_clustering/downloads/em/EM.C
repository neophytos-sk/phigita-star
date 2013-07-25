#include "M.H"
#include <stdio.h>
#include <fcntl.h>
#include <vector>

int main(int argc, char **argv){

	srand(time(0));
	
	vector<V2> data;

	if(argc < 4){
		fprintf(stderr,"usage: %s <#classes> <#iterations> <datafile>\n", argv[0]);
		return -1;
	}
	
	int nclasses = atoi(argv[1]);
	int niteration = atoi(argv[2]);

	if(!nclasses){
		fprintf(stderr, "classes should be nonzero\n");
		return -1;
	}
	
	char * fname = argv[3];
	FILE * file = fopen(fname, "r");
	if(!file){
		fprintf(stderr, "could not open '%s'\n", fname);
		return -1;
	}

	char buffer[80];
	while(fgets(buffer, sizeof(buffer), file)){
		V2 p;
		int r = sscanf(buffer, "%lf  %lf", &p.x, &p.y);
		if(r == 2){
			data.push_back(p);
		}else{
			fprintf(stderr, "sscanf returned %d on '%s'\n", buffer);
		}
	}
	fprintf(stderr, "loaded %d datums\n", data.size());

	fclose(file);

	vector<M23> classes(nclasses);

	for(unsigned int cls=0; cls<classes.size(); ++cls){
		classes[cls].a = 5*(rand()/(double)RAND_MAX);
		classes[cls].b = 0;
		classes[cls].c = 30*(rand()/(double)RAND_MAX);
		classes[cls].d = 0;
		classes[cls].e = 5*(rand()/(double)RAND_MAX);
		classes[cls].f = 30*(rand()/(double)RAND_MAX);
	}

	vector<vector<double> > prob_cls;
	for(unsigned int i=0; i<data.size(); ++i){
		prob_cls.push_back(vector<double>(classes.size()));
	}

	int iteration = 0;
	while(1){
		fprintf(stderr, "iteration %d ...\n", iteration++);

		// compute probability of each datum being in each class
		for(unsigned int cls = 0; cls < classes.size(); ++cls){
			V2 mean = classes[cls].zv();
			M cov(2,2);
			cov(0,0) = classes[cls].a;
			cov(0,1) = classes[cls].b;
			cov(1,0) = classes[cls].d;
			cov(1,1) = classes[cls].e;

			M icov = inv(cov);
			double det = classes[cls].a * classes[cls].e - classes[cls].b * classes[cls].d;
			double p2 = 1.0 / (2*M_PI*sqrt(det));
			
			for(unsigned int inst = 0; inst < data.size(); ++inst){
				V2 x_minus_u = data[inst] - mean;
				double p1 = exp( -0.5 * ( tr((M)(x_minus_u)) * icov * ((M)x_minus_u)) );
				double p = p1*p2;
				prob_cls[inst][cls] = p;
			}
		}

		for(unsigned int inst = 0; inst < data.size(); ++inst){
			double s = 0;
			int b;
			double bv = 0;
			for(unsigned int cls = 0; cls < classes.size(); ++cls){
				s += prob_cls[inst][cls];
				if(prob_cls[inst][cls] > bv){
					bv = prob_cls[inst][cls];
					b = cls;
				}
			}
			for(unsigned int cls = 0; cls < classes.size(); ++cls){
				prob_cls[inst][cls] /= s;
			}
		}

		// compute mean, covariance statistics for each class

		for(unsigned int cls = 0; cls < classes.size(); ++cls){
			V2 mean;
			double q = 0;
			for(unsigned int inst = 0; inst < data.size(); ++inst){
				mean = mean + prob_cls[inst][cls] * data[inst];
				q += prob_cls[inst][cls];
			}
			mean = mean * (1/q);

			double xx=0, yy=0, xy=0;;
			
			for(unsigned int inst = 0; inst < data.size(); ++inst){
				double dx = data[inst].x-mean.x;
				double dy = data[inst].y-mean.y;
				xx += dx*dx * prob_cls[inst][cls];
				yy += dy*dy * prob_cls[inst][cls];
				xy += dx*dy * prob_cls[inst][cls];
			}
			xx /= q;
			yy /= q;
			xy /= q;

			printf("class %d new parameters: mean=(%.3f,%.3f) xx=%.3f yy=%.3f xy=%.3f\n",
					cls, mean.x, mean.y, xx, yy, xy);

			classes[cls].a = xx;
			classes[cls].b = xy;
			classes[cls].d = xy;
			classes[cls].e = yy;
			classes[cls].x = mean.x;
			classes[cls].y = mean.y;
		}
				

		if(iteration == niteration) break;
		
	}

	printf("\nplot");

	vector<FILE*> outputs(classes.size());
	for(unsigned int cls=0; cls<outputs.size(); ++cls){
		char buffer[50];
		sprintf(buffer, "cls%02d.txt", cls);
		outputs[cls] = fopen(buffer, "w");
		printf(" '%s',", buffer);
	}
	

	for(unsigned int inst = 0; inst < data.size(); ++inst){
		double s = 0;
		int b;
		double bv = 0;
		double r = rand()/(double)RAND_MAX;
		for(unsigned int cls = 0; cls < classes.size(); ++cls){
			if(r < prob_cls[inst][cls]){
				b = cls;
				break;
			}else{
				r += prob_cls[inst][cls];
			}
		}
		fprintf(outputs[b], "%f\t%f\n", data[inst].x, data[inst].y);
	}

	for(unsigned int cls=0; cls<outputs.size(); ++cls){
		fclose(outputs[cls]);
	}

	for(unsigned int cls=0; cls<outputs.size(); ++cls){
		char buffer[50];
		sprintf(buffer, "cls%02del.txt", cls);
		FILE * out = fopen(buffer, "w");

		V2 mean = classes[cls].zv();
		M cov(2,2);
		cov(0,0) = classes[cls].a;
		cov(0,1) = classes[cls].b;
		cov(1,0) = classes[cls].d;
		cov(1,1) = classes[cls].e;
		M icov = inv(cov);
		
		double det = classes[cls].a * classes[cls].e - classes[cls].b * classes[cls].d;

		for(double th=0; th<2*M_PI; th+=M_PI/128){
			  V2 v(cos(th),sin(th));

				double p = tr((M)(v)) * icov * ((M)v);
				v = v * (3/sqrt(p));

				fprintf(out, "%f\t%f\n", v.x+mean.x, v.y+mean.y);
		}
		fclose(out);
		printf(" '%s' with lines,", buffer);
	}
	printf("\n\n");

	return 0;
}
