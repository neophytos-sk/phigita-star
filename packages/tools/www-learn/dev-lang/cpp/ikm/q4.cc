int main(){
#define language 300            //Line 1
#if language < 400
#undef language                 //Line 2
#else                           //Line 3
#define language 850            //Line 4
#ifdef language                 //Line 5
   printf("%d", language);      //Line 6
#endif
#endif


}
