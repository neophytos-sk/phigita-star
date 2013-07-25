#include<stdio.h>
#include<math.h>

void hanoi(int x, char from,char to,char aux)
{

  if(x==1) {
      printf("Move Disk From %c to %c\n",from,to);
  } else {
    hanoi(x-1,from,aux,to);
    printf("Move Disk From %c to %c\n",from,to);
    hanoi(x-1,aux,to,from);
  }

}


int main()
{
  int disk;
  int moves;

  printf("Enter the number of disks you want to play with:");
  scanf("%d",&disk);
  moves=pow(2,disk)-1;
  printf("\nThe No of moves required is=%d \n",moves);
  hanoi(disk,'A','C','B');

  return 0;
}
