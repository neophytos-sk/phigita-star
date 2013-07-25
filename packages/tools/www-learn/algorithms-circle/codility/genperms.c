#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define SWAP(a, b) do { typeof(a) temp = a; a = b; b = temp; } while (0)


void swap(char *a, char *b) {
  char temp;
  temp=*a;
  *a=*b;
  *b=temp;
}


void sort(char a[],int n) {

  int i,j;
  for(i=0;i<n;i++)
    for (j=i+1;j<n;j++)
      if(a[i]>a[j])
	SWAP(a[i],a[j]);

}

// expects sorted string a
int noduplicates(char a[], int n) {
  int i,j;
  for(i=0;i<n-1;i++)
    if(a[i]==a[i+1])
      for(j=i+1;j<n;j++)
	a[j]=a[j+1];

  // j iterates over the delimiter, i.e. '\0'
  return strlen(a);
}

void genperms(char a[], int depth, int n, int used[], char perm[]) {

  if (depth==n)
    perm[n]='\0',printf("%s\n",perm);

  int i;
  for(i=0;i<n;i++) { 
    if (!used[i]) {
      used[i] = 1;
      perm[depth]=a[i];
      genperms(a,depth+1,n,used,perm);
      used[i] = 0;
    }
  }

}

void genperms_of_length(char a[], int depth, int n, char used[], char perm[], int k) {
  
  if (depth==k)
    perm[k]='\0',printf("%s\n",perm);

  int i;
  for(i=0;i<n;i++) {
    if (depth && a[i]<perm[depth-1]) continue;
    if (!used[a[i]-'a']) {
      used[a[i]-'a']=1;  // no duplicates
      perm[depth]=a[i];
      genperms_of_length(a,depth+1,n,used,perm,k);
      used[a[i]-'a'] = 0;
    }
  }

}

void gencombs_of_length(char a[], int depth, int n, char used[], char perm[], int k) {
  sort(a,n);
  printf("sorted = %s\n",a);

  n = noduplicates(a,n);
  genperms_of_length(a,depth,n,used,perm,k);
}



int main() {
  int n;
  printf("please enter length of string, n = ");
  scanf("%d",&n);
  char *str = malloc(n*sizeof(char));

  printf("please enter the string, str = ");
  scanf("%s",str);
  int *used = malloc(n*sizeof(int));
  char *perm = malloc((n+1)*sizeof(char));
  memset(used,0,n);
  memset(perm,0,n);

  genperms(str,0,n,used,perm);

  printf("please enter permutation/combination length, k = ");
  int k;
  scanf("%d",&k);
  char used_char[26];
  // char *p = str;
  // while(p) *p = tolower(*p),p++;
  // printf("%s\n",str);
  genperms_of_length(str,0,n,used_char,perm,k);

  printf("generating combinations of length k\n");
  gencombs_of_length(str,0,n,used_char,perm,k);  

  free(used);
  free(perm);
  return 0;
}
