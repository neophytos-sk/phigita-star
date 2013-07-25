// This program is identical to
// listing2.cpp except that it
// uses Boost.Bind to simplify
// the creation of a thread that
// takes data.

#include <boost/thread/thread.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/bind.hpp>
#include <iostream>

boost::mutex io_mutex;

void count(int id)
{
  for (int i = 0; i < 10; ++i)
  {
    boost::mutex::scoped_lock
      lock(io_mutex);
    std::cout << id << ": " <<
      i << std::endl;
  }
}

int main(int argc, char* argv[])
{
  boost::thread thrd1(
    boost::bind(&count, 1));
  boost::thread thrd2(
    boost::bind(&count, 2));
  thrd1.join();
  thrd2.join();
  return 0;
}
