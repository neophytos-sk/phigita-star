#define MAX_LEN 10000
#define SWAP(x,y) ((x)==(y)||((*x)-=(*y),(*y)+=(*x),(*x)=(*y)-(*x)))

char * reverseString ( char *S ) {
    char *p1=S,*p2=S;
    while(*p2 != '\0') {
        p2++;
        //if(p2-p1>MAX_LEN) return NULL;
    }
    p2--;
    while(p1 != p2) {
      SWAP(p1,p2);
      p1++;
      p2--;
    }
    return S;
}


int main() {
  char str[]="abcdefg";
  printf("%s\n",reverseString(str));
  return 0;
}
