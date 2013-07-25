#include <iostream>
#include <thread>  // C++0x header

void hello(){
  std::cout << "Hello Concurrent World!" << '\n';
}

int main(){
  std::thread t(hello);
  t.join();
  return 0;
}
