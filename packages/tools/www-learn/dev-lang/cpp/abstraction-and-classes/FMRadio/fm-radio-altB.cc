#include <iostream>
#include <map>
#include <iterator>
#include <assert.h>

using namespace std;

class FMRadio {
public:
  FMRadio();
  FMRadio(double freq, int volume);

  double getFrequency();
  void setFrequency(double newFreq);

  int getVolume();
  void setVolume(int newVolume);

  void setPreset(int index, double freq);
  bool presetExists(int index);
  double getPreset(int index);

private:
  void checkFrequency(double freq);
  void checkPreset(int index);
  void initialize(double freq, int volume);

  double frequency;
  int volume;
  double presets[6];
};

FMRadio::FMRadio() {
  initialize(87.5,5);
}

FMRadio::FMRadio(double freq, int volume) {
  initialize(freq,volume);
}

void FMRadio::initialize(double freq, int volume) {
  for (size_t i=0; i<6; ++i)
    presets[i] = 0.0;
  setFrequency(freq);
  setVolume(volume);
}

void FMRadio::checkFrequency(double freq) {
  assert(freq >= 87.5 && freq <= 108.0);
}

void FMRadio::checkPreset(int index) {
 assert(index >= 1 && index <= 6);
}

double FMRadio::getFrequency() {
  return frequency;
}

void FMRadio::setFrequency(double newFreq) {
  checkFrequency(newFreq);
  frequency = newFreq;
}

int FMRadio::getVolume() {
  return volume;
}

void FMRadio::setVolume(int newVolume) {
  assert(newVolume>=0 && newVolume<=10);
  volume = newVolume;
}

void FMRadio::setPreset(int index,double freq) {
  checkPreset(index);
  checkFrequency(freq);
  presets[index] = freq;
}

bool FMRadio::presetExists (int index) {
  checkPreset(index);
  return presets[index-1] != 0.0; // -1 maps [1,6] to [0,5];
}

double FMRadio::getPreset(int index) {
  assert(presetExists(index));
  return presets[index];
}

int main(){
  FMRadio myRadio(88.5,5);
  if (myRadio.presetExists(1))
    cout << "Preset 1: " << myRadio.getPreset(1) << endl;
  else
    cout << "Preset 1 not programmed." << endl;

  return 0;
}
