#include <stdio.h>


int is_heavy(int A) {
    int sum=0,num_digits=0;
    while(A) {
        sum+=A%10;
        A=A/10;
        num_digits++;
    }
    printf("sum=%d,num_digits=%d,avg=%d\n",sum,num_digits,sum/num_digits);
    return (sum/num_digits)>=7 ? (sum%num_digits);
}

int heavy_decimal_count ( int A,int B ) {
    int count=0;
    int i;
    for(i=A;i<=B;i++) {
        if (is_heavy(i)) count++;
    }
    return count;
}

int main() {
  printf("%d\n",heavy_decimal_count(8675,8689));
  return 0;
}
