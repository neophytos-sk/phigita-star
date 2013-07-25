// NEunigram.c by Jakob Metzler
// takes a corpus in column format and for each NE class, creates a histogram
// file consisting of single words (unigrams) preceding the NE for use in the NEunigram feature in fex

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
  if(argc!=6)
    {
      cout<<"takes a corpus in column format and for each NE class, creates a histogram file"<<endl;
      cout<<"consisting of single words (unigrams) preceding the NE for use in the NEunigram feature in fex"<<endl;
      cout<<"Usage: NEunigram <ne column #> <word column #> <total column #> <corpus in column format>";
      cout<<" <NE-starting string>*"<<endl;
      cout<<"-----"<<endl;
      cout<<"* a string that signals the beginning  of an NE, e.g. 'B-' for BIO, 'O-' for OC"<<endl;
      exit(0);
    }

  int ne_col =atoi(argv[1]);
  int column = atoi(argv[2]);
  int total = atoi(argv[3]);
  ifstream inFile;
  inFile.open(argv[4]);
  string ne_start = argv[5];
  if(!inFile)
    {
      cerr<<"Could not open "<<argv[4]<<endl;
      exit(0);
    }

  string ne;
  string word, previous_word;
  previous_word="";
  string tab;
  //for each ne a histogram
  vector< vector<myRec> > histogram;
  vector<string> ne_type;
  int counter = 0;
  myRec rec;
  bool found_word=false;
  bool found_type=false;
  bool valid;
  
  cout<<"processing..."<<endl;
  while(!inFile.eof())
  {
      for(int i=0;i<total;i++)
          if(i==(column-1))   
              inFile>>word;
          else if(i==(ne_col-1))
              inFile>>ne;
          else inFile>>tab;
      
      
      //find element
      int i=0;
      int j=0;
      int x = ne.find(ne_start);
      string the_type;

      valid=false;
      // make sure no number is there and at least one letter
      for(int index=0;index<previous_word.length();index++)
          if(!(previous_word[index]>='0' && previous_word[index]<='9') &&
             ((previous_word[index]>='a' && previous_word[index]<='z')||
              (previous_word[index]>='A' && previous_word[index]<='Z'))
              )
              valid=true;
      
      if(x!=string::npos && valid) // dont do anything if its not the start of an NE or word has a number
      {
          //extract the ne type
          the_type = string(ne, x+ne_start.length(), ne.length()-1);
          
          
          while(i<ne_type.size() && !found_type)  // find the correct NE class
          {
              if(ne_type[i] == the_type)
              { 
                  found_type=true;
                  //      cout<<"found! "<<the_type<<" at "<<(i)<<endl;
                  //  cout<<"size: "<<histogram.size()<<endl;}
              }
              i++;
          }
          
          if(!found_type)
          {
              //ne type didnt exist, so add it as a new category
              ne_type.push_back(the_type);
              vector<myRec> next_type;
              histogram.push_back(next_type);
              // cout<<"NEW NETYPE:"<<the_type<<endl;
              i=histogram.size();
              
          }
                    
          //now try to find it among all the entries of this tpye
          
              
          while(j<histogram[i-1].size() && !found_word)
          {
              if(histogram[i-1][j].word==previous_word)
                  found_word=true;
              j++;
          }
          
          if(found_word)
          {
              
              // cout<<"changing "<<i-1<<endl;
              histogram[i-1][j-1].freq++;
              // cout<<"found"<<endl;  
          }
          else if(previous_word!="")
          {
              rec.word=previous_word;
              rec.freq=1;
              histogram[i-1].push_back(rec);
            //   cout<<"added "<<previous_word<<"to "<<ne_type[i-1]<<" at i="<<(i-1)<<" size:"<<histogram[i-1].size()<<endl;
            //  cout<<"types:";
           //    for(int k = 0;k<ne_type.size();k++) cout<<" "<<ne_type[k]<<" ";
          }
          // else cout<<"hmm "<<previous_word<<endl;

      }
      

      found_word=false;
      found_type=false;
      previous_word=word;
      counter++;
      //  if((counter % 1000)==0) cout<<"word #"<<counter<<endl;
	  //if(ne.find(ne_start)!=string::npos) cout<<word<<" "<<ne<<endl;
      
  }

  // we finished gathering all the information. now decide which words to keep in the lists
  // we need to consider each word, and see what information content it has about its NE class
  // in this case the frequency of a word in its class must be at least > threshold (e.g. at least as big as the frequencies of
  // all other ne classes for this word combined

  cout<<"filtering out high entropy words..."<<endl;
  myRec candidate;
  int sum=0;
  int NEindex=0;
  bool found=false;  
  int l=0;
  int **filtermask;
  filtermask = new int*[ne_type.size()];
  for(int x=0;x<ne_type.size();x++)
  {
    filtermask[x] = new int[histogram[x].size()]; 
  }

  for (int i=0;i<ne_type.size(); i++)
  {
    sort(histogram[i].begin(), histogram[i].end());
    for(int j=0; j<histogram[i].size();j++)
    {
      candidate = histogram[i][j];
      sum=0;
      // now sum up all the other freqs of this word
      for(int k=0;k<ne_type.size();k++)
      {
        // omit the candidate class
        if(k!=i)
        {
          found=false;
          l = 0;
          while((!found) && (l<histogram[k].size()))
          {
	    if(histogram[k][l].word==candidate.word)
      	      found=true;
	    //if(found) cout<<"found a match for "<<candidate.word<<endl;
	    l++;
	  }
          l--;
          if(found) sum += histogram[k][l].freq;
        }
      }
 //     if(candidate.word=="the") cout<<"sum:"<<sum<<" freq:"<<candidate.freq<<endl;

      if(sum>candidate.freq)
      {// cout<<"sum:"<<sum<<" freq:"<<candidate.freq<<endl;
      filtermask[i][j]=0;
      //cout<<"filtered out "<<candidate.word<<endl; 
      } else filtermask[i][j]=1; 
    }
    
  }


  ofstream output;
  output.open("SensorNEunigramPre.lst");
  for(int i=0;i<ne_type.size();i++)
  {
      output<<endl;
      output<<"*NETYPE* "<<ne_type[i]<<endl<<endl;
      sort(histogram[i].begin(), histogram[i].end());
      for(int j=histogram[i].size()-1;j>=0;j--)
      {
          if(histogram[i][j].freq>=3 && filtermask[i][j])
          output<<histogram[i][j].word<<endl;
      }
  }

  output.close();
  inFile.close();
  delete [] filtermask;  
} 
