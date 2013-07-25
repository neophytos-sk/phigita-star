/*

Write a function to generate all possible n pairs of balanced parentheses.

For example, if n=1
{}
for n=2
{}{}
{{}}

Algorithm:
Keep track of counts of open and close brackets. Initialize these counts as 0. 
Recursively call the _printParenthesis() function until open bracket count is 
less than the given n. If open bracket count becomes more than the close 
bracket count, then put a closing bracket and recursively call for the remaining 
brackets. If open bracket count is less than n, then put an opening bracket and 
call _printParenthesis() for the remaining brackets.

*/

#include<stdio.h>
#include<stdlib.h>
#define MAX_SIZE 100
 
void _printParenthesis(int pos, int n, int open, int close);
 
/* Wrapper over _printParenthesis()*/
void printParenthesis(int n)
{
  if(n > 0)
     _printParenthesis(0, n, 0, 0);
  return;
}    
 
void _printParenthesis(int pos, int n, int open, int close)
{
  static char str[MAX_SIZE];    
 
  if(close == n)
  {
    printf("%s \n", str);
    return;
  }
  else
  {
    if(open > close) {
        str[pos] = '}';
        _printParenthesis(pos+1, n, open, close+1);
    }
    if(open < n) {
       str[pos] = '{';
       _printParenthesis(pos+1, n, open+1, close);
    }
  }
}
 
/* driver program to test above functions */
int main(int argc, char *argv[])
{
  if (argc < 2) {
	  printf("Usage: %s n\n",argv[0]);
	  return 1;
  }
  int n = atoi(argv[1]);
  printParenthesis(n);
  return 0;
}