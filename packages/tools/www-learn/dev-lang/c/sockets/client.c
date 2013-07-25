#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <netdb.h>

#define BUF_SIZE 500

int main(int argc, char *argv[]) {
  struct addrinfo hints, *result, *rp;
  int sfd,s;
  ssize_t len, nsent, ret;
  char buf[BUF_SIZE];

  if (argc != 4) {
    fprintf(stderr, "Usage: %s HOST PORT MSG\n", argv[0]);
    exit(EXIT_FAILURE);
  }

  memset(&hints,0,sizeof hints);
  hints.ai_socktype = SOCK_STREAM;

  s = getaddrinfo(argv[1],argv[2], &hints, &result);

  if (s != 0) {
    fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(s));
    exit(EXIT_FAILURE);
  }

  for (rp = result; rp; rp = rp->ai_next) {
    sfd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
    if (sfd == -1)
      continue;
    if (connect(sfd, rp->ai_addr, rp->ai_addrlen) == 0)
      break;
    close(sfd);
  }

  freeaddrinfo(result);
  if(!rp) {
    fprintf(stderr, "Could not bind\n");
    exit(EXIT_FAILURE);
  }
  
  len = strlen(argv[3]);
  for (nsent = 0; nsent < len; nsent += ret) {
    ret = send(sfd,&argv[3][nsent], len - nsent, 0);
    if (ret <= 0) {
      if (ret < 0)
	perror("send");
      break;
    }
  }

  shutdown(sfd, SHUT_WR);

  while ((ret = recv(sfd, buf, sizeof buf, 0)) > 0)
    fwrite(buf, ret, 1, stdout);

  if (ret < 0)
    perror("send");

  close(sfd);
  return EXIT_SUCCESS;


}
