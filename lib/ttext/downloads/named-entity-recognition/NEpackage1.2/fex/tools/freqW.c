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
  vector<int> doc_indices;

  bool operator<(const myRec & a) const {return (this->freq < a.freq);};
  bool operator>(const myRec & a) const {return (this->freq > a.freq);};
  bool operator<=(const myRec & a) const {return (this->freq <= a.freq);};
  bool operator>=(const myRec & a) const {return (this->freq >= a.freq);};

};


void main(int argc, char *argv[])
{
  if(argc!=5)
    {
      cout<<"Creates a list of words ranked in the order of # of occurrences in different documents"<<endl;
      cout<<"Used in the freqW Sensor.Assumes that zone info/doc index is in a column like TXT/3"<<endl;
      cout<<"Usage: freqW <word column #> <doc indec column #> <total column #> <corpus in column format>"<<endl;
      exit(0);
    }

  int column = atoi(argv[1]);
  int indexCol = atoi(argv[2]);
  int total = atoi(argv[3]);
  ifstream inFile;
  inFile.open(argv[4]);
  if(!inFile)
    {
      cerr<<"Could not open "<<argv[4]<<endl;
      exit(0);
    }

  string word;
  string docIndexStr;
  string tab;
  vector<myRec> histogram;
  int counter = 0;
  myRec rec;
  bool found=false;
  vector<int>::iterator it;
  
  cout<<"processing..."<<endl;
  while(!inFile.eof())
    {
      for(int i=0;i<total;i++)
	if(i==(column-1))
	  inFile>>word;
	else if (i==(indexCol-1))
	  inFile>>docIndexStr;
	else inFile>>tab;
      
      //extract document index
      int pos = docIndexStr.find("/");
      if(pos==string::npos)
	{
	  cerr<<"No slash character found in document index column"<<endl;
	  exit(0);
	}
      int doc_index = atoi((docIndexStr.substr(pos+1,docIndexStr.size()-pos-1)).c_str());

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

	      // see if index already exiss
	      it = find(histogram[i-1].doc_indices.begin(), histogram[i-1].doc_indices.end(),doc_index);
	      if(it==histogram[i-1].doc_indices.end())
		{
		  histogram[i-1].freq++;
		  histogram[i-1].doc_indices.push_back(doc_index);
		  // cout<<"increased freq of"<<histogram[i-1].word<<endl;
		}
	      

	      // cout<<"found"<<endl;  
	      
	    }
	  else 
	    {
	      rec.word=word;
	      rec.freq=1;
	      rec.doc_indices.push_back(doc_index);
	      histogram.push_back(rec);
	      //cout<<"added"<<endl;
	    }
      
	  found=false;
	  counter++;
	  if((counter % 1000)==0) cout<<"word #"<<counter<<endl;
	  
	}
  // cout<<word<<endl;
  ofstream output;
  output.open("freqW.list");
  sort(histogram.begin(), histogram.end());
  cout<<"Writing to file,  vectorsize: "<<histogram.size()<<endl;

  for(int i=0;i<histogram.size();i++)
    output<<histogram[i].word<<"\t"<<histogram[i].freq<<endl;

  // last one is counted one more time than it exist, thus this hack
  //  output<<histogram[histogram.size()-1].word<<"\t"<<histogram[histogram.size()-1].freq-1<<endl;

  output.close();
  inFile.close();
}
