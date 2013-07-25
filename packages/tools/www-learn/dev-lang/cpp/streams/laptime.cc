#include <iostream>
#include <iomanip>
#include <sstream>

using std::cout;
using std::stringstream;
using std::string;
using std::setw;
using std::setfill;

int laptime_to_seconds(const std::string& laptime) {
  stringstream converter;
  converter << laptime;
  int hours;
  int minutes;
  int seconds;
  char remaining;
  
  if (converter >> hours) {
    if (converter >> remaining) {
      if (remaining != ':') {
        cout << "unexpected character: " << remaining << '\n';
      } else {
        if (converter >> minutes) {
          if (converter >> remaining) {
	    if (remaining != ':') {
              cout << "unexpected character: " << remaining << '\n';
              return -1;
            } else {
              if (converter >> seconds) {
                return hours*3600+minutes*60+seconds;
              } else {
                cout << "expected an integer number of seconds" << '\n';
                return -1;
              }
            }
          } else {
            cout << "expected a semicolon" << '\n';
            return -1;
          }
        } else {
          cout << "expected an integer number of minutes" << '\n';
          return -1;
        }
      }
    } else {
      cout << "expected a semicolon" << '\n';
      return -1;
    }
  } else {
      cout << "expected an integer number of hours" << '\n';
      return -1;
  }
}

std::string seconds_to_laptime(int x) {
  stringstream converter;
  int hours = x / 3600;
  x = x % 3600;
  int minutes = x / 60;
  x = x % 60;
  int seconds = x;
  
  converter << setfill('0') << setw(2) << hours << ':';
  converter << setfill('0') << setw(2) << minutes << ':';
  converter << setfill('0') << setw(2) << seconds;
  
  string result;
  converter >> result;
  return result;
}

int main(int argc, char *argv[]) {
  if (argc<3) {
    cout << "Usage: " << argv[0] << "lap_time_1 lap_time_2" << '\n';
    return 1;
  }
  
  int secs_1 = laptime_to_seconds(argv[1]);
  int secs_2 = laptime_to_seconds(argv[2]);
  if (secs_1 == -1 || secs_2 == -1) {
    return 1;
  }
  int avg_secs = (secs_1 + secs_2) / 2;
  cout << seconds_to_laptime(avg_secs) << '\n';

  return 0;  
}
