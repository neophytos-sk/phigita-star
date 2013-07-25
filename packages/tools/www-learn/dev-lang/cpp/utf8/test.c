  #include <stdio.h>
  #include <locale.h>

  int main()
  {
    if (!setlocale(LC_CTYPE, "")) {
      fprintf(stderr, "Can't set the specified locale! "
              "Check LANG, LC_CTYPE, LC_ALL.\n");
      return 1;
    }
    printf("%ls\n", L"Schöne Grüße");
	printf("%ls\n",L"Νεόφυτος Δημητρίου");
printf("%s\n","Νεόφυτος Δημητρίου");
    return 0;
  }
