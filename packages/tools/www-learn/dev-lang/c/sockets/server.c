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
  int sfd, sock, s;
  ssize_t nread, nsent, ret;
  char buf[BUF_SIZE];

  if (argc != 2) {
    fprintf(stderr, "Usage: %s PORT\n", argv[0]);
    exit(EXIT_FAILURE);
  }

  memset(&hints, 0, sizeof hints);
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags = AI_PASSIVE;

  s = getaddrinfo(NULL,argv[1], &hints, &result);

  if (s != 0) {
    fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(s));
    exit(EXIT_FAILURE);
  }

  for (rp = result; rp; rp=rp->ai_next) {
    sfd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
    if (sfd == -1)
      continue;
    if (bind(sfd, rp->ai_addr, rp->ai_addrlen) == 0)
      break;
    close(sfd);
  }

  freeaddrinfo(result);
  if (!rp) {
    fprintf(stderr, "Could not bind\n");
    exit(EXIT_FAILURE);
  }

  if (listen(sfd,10) == -1) {
    perror("listen");
    close(sfd);
    exit(EXIT_FAILURE);
  }

  sock = accept(sfd,NULL,NULL);
  if (sock == -1) {
    perror("accept");
    close(sfd);
    exit(EXIT_FAILURE);
  }

  while((nread = recv(sock, buf, sizeof buf, 0)) > 0) {
    for (nsent = 0; nsent < nread; nsent += ret) {
      //printf("%.*s\n",nread-nsent,&buf[nsent]);
      ret = send(sock, &buf[nsent], nread - nsent, 0);
      if (ret <= 0) {
	if (ret < 0)
	  perror("send");
	break;
      }
    }
  }

  close(sock);
  close(sfd);
  return EXIT_SUCCESS;
}
