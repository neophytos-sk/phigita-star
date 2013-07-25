#include <stdio.h>


int main() {
	printf("number 23 converted in the binary system (in reverse order)\n");
	int x= 23;
	while(x) {
		printf("%d ",x & 1);
		x >>=1;
	}
	return 0;
}