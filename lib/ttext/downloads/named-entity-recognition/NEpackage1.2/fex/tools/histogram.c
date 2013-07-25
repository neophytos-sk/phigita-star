#include <stdio.h>
#include <iostream.h>
#include <string>
#include <fstream.h>
#include <stdlib.h>
#include <vector>
#include <algorithm>


class  myRec 
{

 public:
  string word;
  int freq;

  bool operator<(const myRec & a) const {return (this->freq < a.freq);};
  bool operator>(const myRec & a) const {return (this->freq > a.freq);};
  bool operator<=(const myRec & a) const {return (this->freq <= a.freq);};
  bool operator>=(const myRec & a) const {return (this->freq >= a.freq);};

};


void main(int argc, char *argv[])
{
  if(argc!=4)
    {
      cout<<"Creates a histogram of word frequency."<<endl;
      cout<<"Usage: histogram <word column #> <total column #> <corpus in column format>"<<endl;
      exit(0);
    }

  int column = atoi(argv[1]);
  int total = atoi(argv[2]);
  ifstream inFile;
  inFile.open(argv[3]);
  if(!inFile)
    {
      cerr<<"Could not open "<<argv[3]<<endl;
      exit(0);
    }

  string word;
  string tab;
  vector<myRec> histogram;
  int counter = 0;
  myRec rec;
  bool found=false;
  
  cout<<"processing..."<<endl;
  while(!inFile.eof())
    {
      for(int i=0;i<total;i++)
	if(i==(column-1))
	  inFile>>word;
	else inFile>>tab;
      
      //find element
      int i=0;
      while(i<histogram.size() && !found)
	{
	  if(histogram[i].word == word)
	    { 
	      found=true;
	      // cout<<"found! "<<word<<" "<<counter<<endl;
	      //  cout<<"size: "<<histogram.size()<<endl;}
	    }
	  i++;
	}
	  
	  if(found)
	    {
	      // cout<<"changing "<<i-1<<endl;
	      histogram[i-1].freq++;
	      // cout<<"found"<<endl;  
	      
	    }
	  else 
	    {
	      rec.word=word;
	      rec.freq=1;
	      histogram.push_back(rec);
	      //cout<<"added"<<endl;
	    }
      
	  found=false;
	  counter++;
	  if((counter % 1000)==0) cout<<"word #"<<counter<<endl;
	  
	}
  // cout<<word<<endl;
  ofstream output;
  output.open("word.hist");
  sort(histogram.begin(), histogram.end());
  cout<<"Writing to file,  vectorsize: "<<histogram.size()<<endl;

  for(int i=0;i<histogram.size()-1;i++)
    output<<histogram[i].word<<"\t"<<histogram[i].freq<<endl;

  // last one is counted one more time than it exist, thus this hack
  output<<histogram[histogram.size()-1].word<<"\t"<<histogram[histogram.size()-1].freq-1<<endl;

  output.close();
  inFile.close();
}
