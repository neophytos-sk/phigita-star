#include <curl/curl.h>

int
main(void)
{
  CURLcode rc;
  CURL *curl;

  curl = curl_easy_init();
  curl_easy_setopt(curl, CURLOPT_URL, "http://httpbin.org/gzip");
  curl_easy_setopt(curl, CURLOPT_ACCEPT_ENCODING, "gzip");
  curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);

  rc = curl_easy_perform(curl);

  curl_easy_cleanup(curl);

  return (int) rc;
}
