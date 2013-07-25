#include <iostream>
#include <thread>  // C++0x header

void hello(){
  std::cout << "Hello Concurrent World!" << '\n';
}

void hello2(){
  std::cout << "hey hey!!!\n";
}

int main(){
  std::thread t1(hello);
  std::thread t2(hello2);
  t1.join();
  t2.join();
  return 0;
}
