#include <stdio.h>
#include <stdlib.h>

#define MAX_N 1000
#define MIN(x,y) ((x)<(y)?(x):(y))
#define SWAP(x,y) ((&(x))==(&(y))||((x)-=(y),(y)+=(x),(x)=(y)-(x)))

void init_data(int a[], int n) {

  int i;
  for(i=0;i<n;++i) 
    a[i] = rand() % 100;

}

void print_data(int a[],int n) {
  int i;
  for(i=0;i<n;++i)
    printf("%d ",a[i]);
  printf("\n");
}

void copy_data(int b[],int a[],int n) {
  int i;
  for(i=0;i<n;++i)
    b[i]=a[i];
}


void test(const char *name, int a[], int n, void(*sortFn)(int a[], int)) {
  int b[MAX_N];
  copy_data(b,a,n);

  printf("%s: ",name);
  sortFn(b,n);
  print_data(b,n);
}


void bubble_sort(int a[],int n) {
  int i,j;
  for(i=0;i<n;++i) {
    for(j=i;j<n;++j) {
      if (a[i]>a[j]) {
	SWAP(a[i],a[j]);
      }
    }
  }
}

void insertion_sort(int a[],int n) {
  int i,j;
  for(i=1;i<n;++i) {
    for(j=i-1;j>=0;--j) {
      if (a[j+1]<a[j]) {
	SWAP(a[j+1],a[j]);
      }
    }
  }
}

void selection_sort(int a[],int n) {
  int i,j;
  for(i=0;i<n;++i) {
    int selectedIndex = i;
    for(j=i+1;j<n;++j) {
      if (a[j]<a[selectedIndex]) {
	selectedIndex = j;
      }
    }
    if (i!=selectedIndex) {
      SWAP(a[i],a[selectedIndex]);
    }
  }
}

void merge(int a[], int n) {
  int i=0,middle = n/2,j=middle;
  int current=0;
  int b[MAX_N];
  while (i<middle && j<n) {
    if (a[i]<=a[j]) {
      b[current] = a[i];
      ++i;
    } else {
      b[current] = a[j];
      ++j;
    }
    ++current;
  }

  // copy remaining items from first half
  while(i<middle) { b[current]=a[i]; ++i; ++current; }

  // copy remaining items from second half
  while(j<n) { b[current]=a[j]; ++j; ++current; }

  // copy values from the temporary to the given array
  copy_data(a,b,n);
}

void merge_sort(int a[],int n) {
  if (n==1) return;
  merge_sort(a,n/2);
  merge_sort(a+n/2,n-n/2);
  merge(a,n);
}

int partition(int a[], int n) {
  int pivot = a[0];
  int left = 0;
  int right = n-1;

  int l = left;
  int r = right;
  while (l<r) {
    while (a[l]<=pivot && l<=right) ++l;
    while (a[r]>pivot && r>=left) --r;
    if (l<r) {
      SWAP(a[l],a[r]);
    }    
  }
  int middle = r;
  SWAP(a[left],a[middle]);
  return middle;
}

int select_pivot_index(int n) {
  return rand() % n;
}

void quick_sort(int a[],int n) {
  if (n<=1) return;

  int pivotIndex = select_pivot_index(n);
  SWAP(a[0],a[pivotIndex]);
  int middle = partition(a,n);
  quick_sort(a,middle);
  quick_sort(a+middle+1,n-middle-1);
}

int binary_search(int a[], int n, int value) {
  if (n==1) return a[0]==value?0:-1;

  int middle = n/2;
  if (value < a[middle]) {
    return binary_search(a,middle,value);
  } else if (value > a[middle]) {
    int index = binary_search(a+middle,n-middle,value);
    return index==-1?-1:middle+index;
  } else {
    // if equal
    return middle;
  }
}

int main(int argc, char *argv[]) {

  srand(time(NULL));

  int a[MAX_N];
  int n = argc>1?MIN(atoi(argv[1]),MAX_N):20;

  init_data(a,n);
  test("Bubble Sort",a,n,&bubble_sort);
  test("Insertion Sort",a,n,&insertion_sort);
  test("Selection Sort",a,n,&selection_sort);
  test("Merge Sort",a,n,&merge_sort);
  test("Quick Sort",a,n,&quick_sort);

  quick_sort(a,n);
  printf("Binary Search for %d: ",12);
  int index = binary_search(a,n,12);
  if (-1==index) {
    printf("not found\n");
  } else {
    printf("found at index: %d\n",index);
  }

  return 0;
}
