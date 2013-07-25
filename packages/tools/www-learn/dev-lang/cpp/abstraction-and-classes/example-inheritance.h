
class X {
public:
  X(int myValue);
  virtual void display();
  void display2();
  virtual ~X();
private:
  int myValue_;
};

class Y : public X {
public:
  Y(int myValue, int mySecondValue);
  virtual void display();
  void display2();
  virtual ~Y();
private:
  int mySecondValue_;
};
