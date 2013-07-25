#include <stdio.h>

void sub(int *a) {
	int b;

	if (&b > a) {
		printf("Stack grows up.");
	} else {
		printf("Stack grows down.");
	}
}

main () {
	int a;
	sub(&a);
}
