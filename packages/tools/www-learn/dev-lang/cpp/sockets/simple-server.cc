#include <cstdio>
#include <cstdlib> 
#include <sys/socket.h> // for socket
#include <netinet/in.h> // for sockaddr_in
#include <string>
#include <cstring> // for memset

using std::string;


class http {
public:
  http(int port) : port_(port), cs_(0), ss_(0) {}
  void setup();
  bool wait(int timeout = 0);
  void simple_recv();
private:
  int port_;
  int ss_; // server socket
  int cs_; // client socket
};

void http::setup() {

  try {
    // socket(domain,type,protocol);
    ss_ = socket(AF_INET, SOCK_STREAM, 0);
    if (ss_ == -1) {
      fprintf(stderr,"http socket error\n");
      throw;
    }

    struct sockaddr_in addr;
    memset((void*)&addr, 0, sizeof addr);
    addr.sin_family=AF_INET;
    addr.sin_port=htons(port_);
    addr.sin_addr.s_addr=INADDR_ANY;

    if (bind(ss_, (struct sockaddr*)&addr, sizeof addr) == -1) {
      fprintf(stderr, "http bind error\n");
      throw;
    }

    if (listen(ss_,1) == -1) {
      fprintf(stderr, "http listen error\n");
      throw;
    }
  } catch (...) {
    if (ss_ > 0) close(ss_);
    ss_=0;
    throw;
  }
}

bool http::wait(int timeout) {

  if (!ss_) setup();

  struct timeval tmout;
  struct timeval *ptmout;

  if (timeout) {
    tmout.tv_sec = timeout /1000;
    tmout.tv_usec = (timeout%1000)*1000;
    ptmout=&tmout;
  }

  fd_set rset;
  FD_ZERO(&rset);
  FD_SET(ss_, &rset);

  if (select(ss_ + 1, &rset, 0, 0, ptmout) > 0) {
    struct sockaddr_in client_addr;
    socklen_t addrsize(sizeof client_addr);
    if (( cs_ = accept(ss_, (struct sockaddr*)&client_addr, &addrsize)) == -1)
      fprintf(stderr, "http accept error\n");
    
    return true;

  } else {
    return false;
  }
  
}


void http::simple_recv() {
  string data;
  char c;
  while (read(cs_,&c,1)) {
    data += c;
  }
  printf("%s",data.c_str());
}

int main(int argc, char *argv[]) {

  if (argc < 3) {
    fprintf(stderr, "Usage: %s host port\n", argv[0]);
    return 1;
  }

  string host = argv[1];
  int port = atoi(argv[2]);

  http server(port);
  //server.setup();

  while (server.wait()) {
    /* ... */
    
    server.simple_recv();

    printf("beep :)\n");

  }

}
