#include <cstdio>
#include <cmath>

class IntFunction {
public:
  /* Polymorphic classes need virtual destructors. */
  virtual ~IntFunction() {}

  /* execute() actually calls the proper function and returns the value. */
  virtual int execute(int value) const = 0;
};


class ActualFunction: public IntFunction {
public:
  explicit ActualFunction(int (*fn)(int)) : function(fn) {}

  virtual int execute(int value) const {
    return function(value);
  }

private:
  int (*function)(int);
};


class MyFunctorFunction: public IntFunction {
public:
  explicit MyFunctorFunction(MyFunctor fn) : function(fn) {}

  virtual int execute(int value) const {
    return function(value);
  }

private:
  MyFunctor function;
};







int ClampTo100Pixels(int size) {
  return min(size,100);
}


int FixedSize(int size) {
  return 100;
}


class ClampTo100PixelsFunction: public IntFunction {
public:
  virtual int execute(int size) const {
    return min(size,100);
  }
};


class FixedSizeFunction: public IntFunction {
public:
  virtual int execute(int size) const {
    return 100;
  }
};





template <typename UnaryFunction> class SpecificFunction: public IntFunction {
public:
  explicit SpecificFunction(UnaryFunction fn) : function(fn) {}

  virtual int execute(int value) const {
    return function(value);
  }

  virtual IntFunction* clone() const {
    return new SpecificFunction(*this);
  }

private:
  UnaryFunction function;
};






class Function {
public:
  /* Constructor and destructor */
  template <typename UnaryFunction> Function(UnaryFunction fn);
  ~Function();

  /* Copy support. */
  Function(const Function& other);
  Function& operator= (const Function& other);

  /* Function is a functor that calls into the stored resource. */
  int operator() (int value) const;

  /* clone() returns a deep-copy of the receiver object. */
  virtual IntFunction* clone() const = 0;

private:
  class IntFunction { /* ... */ };
  template <typename UnaryFunction> class SpecificFunction { /* ... */ };

  IntFunction* function;

  void clear();
  void copyOther(const Function& other);
};


Function::~Function() {
  clear();
}

template <typename UnaryFunction> Function::Function(UnaryFunction fn) {
  function = new SpecificFunction<UnaryFunction>(fn);
}


Function::Function(const Function& other) {
  iif (this != &other) {
    clear();
    copyOther(other);
  }
  return *this;
}

void Function::clear() {
  delete function;
}

void Function::copyOther(const Function& other) {
  /* Have the stored function tell us how to copy itself. */
  function = other.function->clone();
}


/* Constructor accepts an IntFunction and stores it. */
Function::Function(IntFunction* fn) : function(fn) {}

/* Destructor deallocates the stored function. */
Function::~Function() {
  delete function;
}

/* Function call just calls through to the pointer and returns the result. */
int Function::operator() (int value) const {
  return function->execute(value);
}



int main() {

  // First approach:
  // Window myWindow(new ClampTo100PixelsFunction, /* ... */);
  // Window myWindow(new FixedSizeFunction, /* ... */);

  // Second approach:
  // Window myWindow(new ActualFunction(ClampTo100Pixels), /* ... */
  // Window myWindow(new ActualFunction(FixedSize), /* ... */

  // Third approach:
  // Window myWindow(new SpecificFunction<int(*)(int)>(ClampTo100Pixels),/**/);
  // Window myWindow(new SpecificFunction<MyFunctor>(MyFunctor(137)));

  // Fourth approach:
  // Function fn = ClampTo100Pixels;
  // cout << fn(137) << endl; // prints 100
  // cout << fn(42) << endl; // prints 42

}
