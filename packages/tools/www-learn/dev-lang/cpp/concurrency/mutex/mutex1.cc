#include <list>
#include <mutex>
#include <algorithm>
#include <thread>
#include <iostream>

std::list<int> some_list;
std::mutex some_mutex;

void add_to_list(int new_value) 
{
  std::lock_guard<std::mutex> guard(some_mutex);
  some_list.push_back(new_value);
}
bool list_contains(int value_to_find) 
{
  std::lock_guard<std::mutex> guard(some_mutex);
  return std::find(some_list.begin(),some_list.end(),value_to_find) != some_list.end();
}

void hello()
{
  while(true) {
    int value = rand() % 100;
    add_to_list(value);  
    std::cout << value << std::endl;
    sleep(1);
  }
}

void world()
{
  while(true) {
   int value = rand() % 100;
   if (list_contains(value)) {
     std::cout << "contains " << value << std::endl;
   } else {
     std::cout << "not found " << value << std::endl;
   }
  sleep(1);
  } 
}

int main() {
	srand(time(NULL));
   std::thread t1(hello);
   std::thread t2(world);
   t1.join();
   t2.join();
   return 0;
}

