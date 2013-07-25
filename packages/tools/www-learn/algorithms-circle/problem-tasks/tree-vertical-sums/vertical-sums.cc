//Vertical Sum of a Binary Tree
#include<iostream>
#include<map>
#include<cstring>
#include<cstdlib>
#include<cstdio>

using namespace std;

struct tree
{
  int data;
  struct tree* left;
  struct tree* right;
};

typedef struct tree Tree;

Tree* Node(int d)
{
   Tree* T=(Tree*)malloc(sizeof(Tree));
   T->data=d;
   T->left = T->right = NULL;
   return T;
}

map<int,int>verticalSum;

void get_Vertical_Sum(Tree* T,int i)
{
   if(T==NULL)
      return;
   else
   {
     verticalSum[i]+=T->data;
     get_Vertical_Sum(T->left,i-1);
     get_Vertical_Sum(T->right,i+1);
   }
}

int main()
{
  //Construct the Tree
   /*
     1
     2 3
     4 5 6 7
   */
   Tree* T=NULL;
   T = Node(1);
   T->left = Node(2);
   T->right = Node(3);
   T->left->left = Node(4);
   T->left->right = Node(5);
   T->right->left = Node(6);
   T->right->right = Node(7);

   verticalSum.clear();
   get_Vertical_Sum(T,0);
   for(map<int,int>::iterator it=verticalSum.begin();it!=verticalSum.end();it++)
   {
      cout << (*it).second << " ";
   }
   cout << endl;

   getchar();
   return 0;
}

