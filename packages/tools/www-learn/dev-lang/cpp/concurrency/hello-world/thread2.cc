#include <iostream>
#include <thread>


class Hello {
  std::thread m_thread;

public:
  Hello(){}
  ~Hello(){}
  void start(){
    m_thread = std::thread (&Hello::func,this);
  }
  void func(){
    while(true) {
      std::cout << "hello world" << std::endl;
      sleep(1);
    }
  }
  void join() {
    m_thread.join();
  }
};

int main() {
  Hello h;
  h.start();
  h.join();
  return 0;
}
