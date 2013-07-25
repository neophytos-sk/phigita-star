  #include <stdio.h>
#include <string.h>

 	
  int main()
  {
	char str1[100], str2[100];
scanf("%s %s",str1,str2);
printf("%d",strcmp(str1,str2));
printf("%s: %s first char:%c\n","Νεόφυτος Δημητρίου", str1, str1[0]);
    return 0;
  }
