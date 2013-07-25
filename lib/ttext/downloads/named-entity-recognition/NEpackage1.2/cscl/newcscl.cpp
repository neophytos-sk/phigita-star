#include <iostream>
#include <fstream>
#include "Graph.h"
#include <string>

#define BIO_O 1
#define BIO_Borg 2
#define BIO_Bmisc 3
#define BIO_Bper 4
#define BIO_Iper 5
#define BIO_Bloc 6
#define BIO_Iorg 7
#define BIO_Imisc 8
#define BIO_Iloc 9


Graph g;

void BIOAddEdges(long node, long index,double activation)
{

  // B's can always happen in BIO
  g.AddEdge(node+index,(node+100)+BIO_Bper,activation);
  g.AddEdge(node+index,(node+100)+BIO_Bmisc,activation);
  g.AddEdge(node+index,(node+100)+BIO_Bloc,activation);
  g.AddEdge(node+index,(node+100)+BIO_Borg,activation);

  switch (index)
    {
    case BIO_O:

      //Outside
      g.AddEdge(node+index,(node+100)+BIO_O,activation);      
      break;

    case BIO_Borg:
    case BIO_Iorg:

      //Outside
      g.AddEdge(node+index,(node+100)+BIO_O,activation);
      //I-org
      g.AddEdge(node+index,(node+100)+BIO_Iorg,activation);
      break;

    case BIO_Bmisc:
    case BIO_Imisc:

      //Outside
      g.AddEdge(node+index,(node+100)+BIO_O,activation);
      //I-misc
      g.AddEdge(node+index,(node+100)+BIO_Imisc,activation);
      break;

    case BIO_Bper:
    case BIO_Iper:

      //Outside
      g.AddEdge(node+index,(node+100)+BIO_O,activation);
      //I-per
      g.AddEdge(node+index,(node+100)+BIO_Iper,activation);
      break;

    case BIO_Bloc:
    case BIO_Iloc:

      //Outside
      g.AddEdge(node+index,(node+100)+BIO_O,activation);
      //I-loc
      g.AddEdge(node+index,(node+100)+BIO_Iloc,activation);
      break;             
    }
  
}

main(int argc, char *argv[])
{
 
  if(argc<4)
    {
      cout<<"usage: "<<argv[0]<<" [classifiertype] corpus activactions"<<endl;
      exit(0);
    }
  
  string mode = string(argv[1]);
  string corpus = string(argv[2]);
  string activ = string(argv[3]);
 
  ifstream cfile(argv[2]);
  ifstream afile(argv[3]);

  if(mode=="-BIO")
    {
      cout<<"Mode: BIO"<<endl;
      // 2*4+1 possible states per word (4 entities)
      // 1: O
      // 2: B-ORG
      // 3: B-MISC
      // 4: B-PER
      // 5: I-PER
      // 6: B-LOC
      // 7: I-ORG
      // 8: I-MISC
      // 9: I-LOC
      //
      //code: word#*100 + state => 207 = before 2nd word, 7th label

      //get a sentence
      long index, debug_counter;
      double activation;
      long node=100;
      while(!afile.eof())
	{
	  //add initial node
	  for(int i=1;i<=9;i++)
	    g.AddEdge(1,100+i,0.0);
	  
	  while((index != -1) && (!afile.eof()))
	    {
	      for(int i=1;(i<=9)&&(index!=-1);i++)
		{
		  afile>>index;
		  if(index!=-1)
		    {
		      afile>>activation;
		      // take the inverse because graph class has 
		      // support for shortest path algorithm
		      activation = 0.1/activation;

		      // add to graph all valid paths
		      BIOAddEdges(node,index, activation);

		      cout<<index<<" "<<activation<<" "<<node<<endl;
	     
		    }
		}
	      if(index!=-1) 
		{
		  // cout<<"WORD DONE"<<endl;
		  node+=100;
		}
	    }
	  index=0;
	  // cout<<"SENTENCE DONE"<<endl;

	  //add final node
	  for(int i=1;i<=9;i++)
	    g.AddEdge((node-100)+i,node,0.0);

	  //find path
	  //cout<<node<<endl;
	  long path[300]; 
	  double length;
	  //long mincost = g.DAG_Short_Path(1,node,path,length); 
	  
          g.Print();
	  g.Clear();
	  g.AddEdge(101,203,3.0);
	  g.AddEdge(203,300,2.0);
	  long bla = g.DAG_Short_Path(101,300,path,length);
	  node=100;
	}
      

    } //end of BIO if
}
