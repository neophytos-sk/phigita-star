#include <iostream>
#include <string>
#include <stdio.h>

using namespace std;

class Number {
public:
	// 2. define a public static accesor func
	static Number *instance();
	static void setType(string t) {
		type_ = t;
		delete instance_;
		instance_ = 0;
	}
	virtual void setValue(int in) {
		value_ = in;
	}
	virtual int getValue() {
		return value_;
	}
protected:
	int value_;
	// 4. define all ctors to be protected
	Number() {
		cout << "ctor: ";
	}
// 1. define a private static attribute
private:
	static string type_;
	static Number *instance_;
};

string Number::type_ = "decimal";
Number *Number::instance_ = 0;

class Octal : public Number {
// 6. Inheritance can be supported
public:
	friend class Number;
	void setValue(int in) {
		char buf[10];
		sprintf(buf,"%o",in);
		sscanf(buf,"%d",&value_);
	}
protected:
	Octal(){};
};

Number *Number::instance() {
	if (!instance_) 
		if (type_=="octal")
			// 3. do "lazy initialization in the accessor function
			instance_ = new Octal();
		else
			instance_ = new Number();
	return instance_;
}

int main() {
	// Number myinstance : - error: cannot access protected constructor
	// 5. Clients may only use the accessor fucntion to manipulate the Singleton
	Number::instance()->setValue(42);
	cout << "value is " << Number::instance()->getValue() << endl;
	Number::setType("octal");
	Number::instance()->setValue(64);
	cout << "value is " << Number::instance()->getValue() << endl;
	return 0;
}