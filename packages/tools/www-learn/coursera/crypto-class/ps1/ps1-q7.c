#include <stdio.h>
#include <string.h>

#define MAXLEN 100

int main(int argc, char *argv[]) {
  unsigned char str[] = "attack at dawn";
  unsigned char new_str[] = "attack at dusk";
  // unsigned char enc[] = "6c73d5240a948c86981bc294814d";
  unsigned char enc[] = "09e1c5f70a65ac519458e7e53f36";

  size_t len = strlen(str);

  int i;
  unsigned int enc_in_decimal[MAXLEN];
  unsigned int key[MAXLEN];
  unsigned int new_enc[MAXLEN];
  for(i=0;i<len;++i) {
    sscanf(enc+2*i,"%2x",&enc_in_decimal[i]);
    key[i] = ((unsigned int) str[i]) ^ enc_in_decimal[i];
    // printf("dec=%d key=%d ",dec[i],key[i]);
    new_enc[i] = key[i] ^ new_str[i];
    // new_enc[i] = key[i] ^ str[i];
    printf("%.2x", new_enc[i]);
  }
  printf("\n");

  return 0;
}
