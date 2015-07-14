#include <curl/curl.h>

int
main(int argc, char **argv)
{
  CURLcode rc;
  CURL *curl;

  if (argc != 2) {
      printf("usage: %s url\n",argv[0]);
      exit(1);
  }

  char *url = argv[1];

  curl = curl_easy_init();
  //curl_easy_setopt(curl, CURLOPT_URL, "http://httpbin.org/gzip");
  curl_easy_setopt(curl, CURLOPT_URL, url);
  curl_easy_setopt(curl, CURLOPT_ACCEPT_ENCODING, "gzip");
  curl_easy_setopt(curl, CURLOPT_USERAGENT, "curl/7.41.0");
  curl_easy_setopt(curl, CURLOPT_HEADER, 1L);
  curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);

  rc = curl_easy_perform(curl);

  curl_easy_cleanup(curl);

  return (int) rc;
}
