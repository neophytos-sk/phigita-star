#include <iostream>
#include <stack>

using namespace std;

struct node {
	node *left;
	node *right;
	int value;
	node():left(NULL),right(NULL),value(0){}
};


class tree {
	public:
		tree();
		~tree();
		void insert(int data);
		int find_kth(int k);
		void print();
		int lowest_common_ancestor(int a, int  b);
	private:
		node *root_;
};

tree::tree() : root_(NULL) {}
tree::~tree() { delete root_; }

void tree::insert(int data) {
	if (!root_) {
		root_ = new node();
		root_->value = data;
		return;
	}
	
	node *current = root_;
	while (current) {
		if (current->value >= data) {
			if (current->left) {
				current=current->left;
			} else {
				current->left = new node();
				current->left->value = data;
				return;
			}
		} else {
			if (current->right) {
				current=current->right;
			} else {
				current->right = new node();
				current->right->value = data;
				return;
			}
		}
	}
}


int tree::find_kth(int k) {
	stack<node*> s;  // declare and initialize stack
	node *current = root_;
	
	while(true) {
		while(current) {
			// move down left child field
			s.push(current);
			current=current->left;
		}
		if (!s.empty()) // stack is not empty
		{
			current = s.top();
			k--;
			if (k==0) 
				return current->value;
			else
			{
				s.pop();
				current=current->right;
			}
		} else 
			break;
	}
	
	return -1;
}

int tree::lowest_common_ancestor(int a, int  b) {
	if (a>b) return lowest_common_ancestor(b,a);
	
	if (!root_ || root_->value == a || root_->value == b) return -1;
	
	node *current = root_;
	while(current) {
		if (current->value > a && current->value > b) {
			current = current->left;
		} else if (current->value < a && current->value < b) {
			current = current->right;
		} else {
			// split/choice point - current->value between a and b
			return current->value;
		}
	}
	return -1;
}

void tree::print() {
	stack<node *> s;
	s.push(root_);
	while(!s.empty()) {
		node *current = s.top();
		s.pop();
		cout << current->value << endl;
		if (current->left) s.push(current->left);
		if (current->right) s.push(current->right);		
	}
}

int main(int argc, char *argv[]){
	tree *t = new tree;
	t->insert(5);
	t->insert(7);
	t->insert(3);
	t->insert(11);
	t->insert(2);
	t->insert(9);
	t->insert(6);
	t->insert(15);
	cout << "kth=" << t->find_kth(3) << endl;
	cout << "lca(7,11)=" << t->lowest_common_ancestor(7,11) << endl;
	//t->print();
	
	return 0;
}