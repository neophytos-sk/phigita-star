#ifndef FMRADIO_H
#define FMRADIO_H

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

#endif
