#include <iostream>
#include <map>
#include <iterator>
#include <assert.h>

using namespace std;

class FMRadio {
public:
  double getFrequency();
  void setFrequency(double newFreq);

  int getVolume();
  void setVolume(int newVolume);

  void setPreset(int index, double freq);
  bool presetExists(int index);
  double getPreset(int index);

private:
  double frequency;
  int attenuation;  // 0 is no attenuation, 10 is maximum attenuation
  double presets[6];
};

double FMRadio::getFrequency() {
  return frequency;
}

void FMRadio::setFrequency(double newFreq) {
  assert(newFreq >= 87.5 && newFreq <= 108.0);
  frequency = newFreq;
}

int FMRadio::getVolume() {
  return 10 - attenuation;
}

void FMRadio::setVolume(int newVolume) {
  assert(newVolume>=0 && newVolume<=10);
  attenuation = 10 - newVolume; // convert from volume to attenuation level
}

void FMRadio::setPreset(int index,double freq) {
  assert(index >= 1 && index <= 6);
  assert(freq >= 87.5 && freq <= 108.0);
  presets[index] = freq;
}

bool FMRadio::presetExists (int index) {
  assert(index >= 1 && index <= 6);
  return presets.find(index) != presets.end();
}

double FMRadio::getPreset(int index) {
  assert(presetExists(index));
  return presets[index];
}

int main(){
  FMRadio myRadio; // declare a new variable of type FMRadio
  double f = myRadio.getFrequency(); // query the radio for its frequency

  myRadio.setVolume(8);
  cout << myRadio.getVolume() << endl;
  return 0;
}
