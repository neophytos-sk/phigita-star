/* You have only the stack class with you. Implement a queue
 * careercup.com: google
 */

#include <iostream>
#include <stack>

using namespace std;


template <typename T>
class Queue {
public:
	bool empty() {
		return stack_.empty();
	}
	void enque(T x) {
		stack_.push(x);
	}
	T deque() {
		T x = stack_.top();
		stack_.pop();
		if (stack_.empty()) {
			return x;
		} else {
			T retval = deque();
			stack_.push(x);
			return retval;
		}
	}
private:
	stack<T> stack_;
};


int main() {
	Queue<int> q;
	q.enque(5);
	q.enque(10);
	q.enque(20);
	while (!q.empty()) {
		cout << q.deque() << endl;
	}
	return 0;
}