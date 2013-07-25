#include <iostream>
#include <thread>

struct test {
  int i_;
  test(int i) : i_(i) {}
 
  void operator()() 
  {
    std::cout << "hello world\n" << i_ << '\n';
  }
};

int main(){
  test test1(123);
  test test2(456);
  std::thread t1(test1);
  std::thread t2(test2);
  t1.join();
  t2.join();
  return 0;
}
