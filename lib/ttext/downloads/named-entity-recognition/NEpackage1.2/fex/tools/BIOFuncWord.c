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
  if(argc!=5)
    {
      cout<<"Creates a histogram of functional words for NER"<<endl;
      cout<<"(=lowercase words in a NE from a corpus)"<<endl;
      cout<<"Usage: BIOFuncWords <NE column> <word column> <total # of columns><corpus in column format>"<<endl;
      cout<<"Note: corpus must be BIO"<<endl;
      exit(0);
    }

  int columnNE = atoi(argv[1]);
  int columnWord = atoi(argv[2]);
  int total = atoi(argv[3]);
  ifstream inFile;
  inFile.open(argv[4]);
  if(!inFile)
    {
      cerr<<"Could not open "<<argv[4]<<endl;
      exit(0);
    }

  string word;
  string NE;
  string tab;
  vector<myRec> histogram;
  int counter = 0;
  myRec rec;
  bool found=false;
  
  cout<<"processing..."<<endl;
  while(!inFile.eof())
    {
      //get the NE tag & word
      for(int i=0;i<total;i++)
	if(i==(columnNE-1))
	  inFile>>NE;
	else if(i==(columnWord-1))
	  inFile>>word;
	else inFile>>tab;
      
      //dont use it if the word is not in an NE && upper case
      if(NE!="O" && (word[0] == tolower(word[0])) && (word[0]<'0' || word[0]>'9'))
	{
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
	}
	  found=false;
	  counter++;
	  if((counter % 1000)==0) cout<<"word #"<<counter<<endl;
	  
	}
  // cout<<word<<endl;
  ofstream output;
  output.open("SensorFunctionalWord.lst");
  sort(histogram.begin(), histogram.end());
  cout<<"Writing to file,  vectorsize: "<<histogram.size()<<endl;

  for(int i=0;i<histogram.size();i++)
    output<<histogram[i].word<<"\t"<<histogram[i].freq<<endl;
  
  output.close();
  inFile.close();
}
