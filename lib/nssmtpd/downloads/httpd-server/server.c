/* A simple server in the internet domain using TCP
   The port number is passed as an argument */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>

void error(const char *msg)
{
    perror(msg);
    exit(1);
}

int main(int argc, char *argv[])
{
     int sockfd, newsockfd, portno;
     socklen_t clilen;
     char buffer[256];
     struct sockaddr_in serv_addr, cli_addr;
     int n;
     if (argc < 2) {
         fprintf(stderr,"ERROR, no port provided\n");
         exit(1);
     }
     sockfd = socket(AF_INET, SOCK_STREAM, 0);
     if (sockfd < 0) 
        error("ERROR opening socket");
     bzero((char *) &serv_addr, sizeof(serv_addr));
     portno = atoi(argv[1]);
     serv_addr.sin_family = AF_INET;
     serv_addr.sin_addr.s_addr = INADDR_ANY;
     serv_addr.sin_port = htons(portno);
     if (bind(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) 
       error("ERROR on binding");
     listen(sockfd,5);
     clilen = sizeof(cli_addr);
     newsockfd = accept(sockfd, (struct sockaddr *) &cli_addr, &clilen);
     if (newsockfd < 0) 
          error("ERROR on accept");


     char greeting[] = "220 localhost SMTP 1.0 12334567890 \r\n";
     n = write(newsockfd,greeting,strlen(greeting));
     if (n < 0) error("ERROR writing to socket");

     while(1) {

       bzero(buffer,256);
       n = read(newsockfd,buffer,255);
       if (n < 0) error("ERROR reading from socket");
       printf("Here is the message: %s\n",buffer);

       if (buffer[0]=='Q' && !strncasecmp(buffer, "QUIT", 4)) {
	 char goodbye[] = "221 Bye\r\n";
	 n = write(newsockfd,goodbye,strlen(goodbye));
	 break;
       }

        if (buffer[0]=='H' && !strncasecmp(buffer, "HELP", 4)) {
	  char help[] = "214- This SMTPD version 1.0\r\n214- Supported commands:\r\n214- HELO EHLO MAIL RCPT DATA\r\n214- RSET NOOP QUIT HELP VRFY\r\n";
	  n = write(newsockfd,help,strlen(help));
	}

       // n = write(newsockfd,"I got your message",18);
       //if (n < 0) error("ERROR writing to socket");
     }

     close(newsockfd);
     close(sockfd);
     return 0; 
}
