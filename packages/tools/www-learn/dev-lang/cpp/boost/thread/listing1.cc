//   Listing 1 illustrates a very simple use of the boost::thread class. A new thread is created that simply writes "Hello World" out to std::cout, while the main thread waits for it to complete.
  



  
#include <boost/thread/thread.hpp>
#include <iostream>


void hello() {
  std::cout << "Hello world, I'm a thread!" << '\n';
}

int main(int argc, char* argv[]) {
  boost::thread thrd(&hello);
  thrd.join();
  return 0;
}
