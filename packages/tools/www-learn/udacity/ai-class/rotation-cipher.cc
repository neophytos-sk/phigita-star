#include <iostream>
#include <string>
#include <algorithm>

using namespace std;

#define islower(c) ((c)>='a' && (c)<='z')
#define isupper(c) ((c)>='A' && (c)<='Z')

char incr_char(char c,int incr) {
  
  if (c == ' ' || c == '.') return c;

  char newc = c + incr;

  // if (!islower(newc) && !isupper(newc)) return '+';

  if (isupper(c) && newc < 'A') return 'Z' - ('A'-newc-1);
  if (islower(c) && newc < 'a') return 'z' - ('a'-newc-1);

  //if (isupper(c) && newc > 'Z') return 'A' + (newc - 'Z'-1);
  //if (islower(c) && newc > 'z') return 'a' + (newc - 'z'-1);

  return newc;

}

void rotate(string& secret, int len,int incr) {
  for(int i=0;i<len;i++) {
    secret[i] = incr_char(secret[i], incr);
  }
}

void decipher(const string& secret) {

  int len = secret.size();
  for(int i=-26;i<=26;i++) {
    string text(secret);
    rotate(text,len,i);
    cout << i << ": " << text << '\n';
  }

}

void cipher(string& secret,int n) {

  int len = secret.size();
  for(int i=0;i<n;i++) {
    rotate(secret,len,1);
  }
}


int main(int argc, const char *argv[]) {

  string s("Esp qtcde nzyqpcpynp zy esp ezatn zq Lcetqtntlw Tyepwwtrpynp hld spwo le Olcexzfes Nzwwprp ty estd jplc.");

  // std::transform(s.begin(), s.end(), s.begin(), ::toupper);

  decipher(s);

  // string answer("1955");
  // cipher(answer,11);
  // cout << answer << '\n';

  return 0;
}

