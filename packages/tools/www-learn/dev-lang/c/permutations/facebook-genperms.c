#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_LEN 1000


void generate_combinations(char *in, char *out, int length, int depth, int k, int start) {

    if (depth == k) {
        printf("%s\n",out);
        return;
    }

    int i;
    for(i=start;i<length;i++) {
        /* nothing else needed here */
        out[depth]=in[i];
        generate_combinations(in,out,length,depth+1,k,i+1);
    }
}

void generate_permutations(char *in, char *out, int used[], int length, int depth, int k) {

    if (depth == k) {
        printf("%s\n",out);
        return;
    }

    int i;
    for(i=0;i<length;i++) {
        //if(!used[i]) {
            out[depth]=in[i];
            // used[i]=1;
            generate_permutations(in,out,used,length,depth+1,k);
            // used[i]=0;
        //}
    }
}


int main() {
    char s[] = "abc";
    int length = strlen(s);    
    char *out = malloc(length*sizeof(char)+1);
    out[length]='\0';
    int used[MAX_LEN];
	printf("permutations\n");
    generate_permutations(s,out,used,length,0,2);
	printf("combinations\n");
    generate_combinations(s,out,length,0,2,0);
}
