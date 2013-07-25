#include <iostream>
#include <stack>
#include <string>
#include <vector>
#include <algorithm>

using namespace std;

enum color {WHITE,GRAY,BLACK};

class File {
public:
  File(string name) : name_(name),color_(WHITE), prev_(NULL), finishing_time_(0) {}
  string name_;
  vector<File*> deps_;
  color color_;
  File *prev_;
  int finishing_time_;
  static int finishing_time;
};


int File::finishing_time = 0;

void dfs_visit(File *start) {

  cout << "---" << "dfs-visit " << start->name_ << endl;

  start->color_ = GRAY;
  File::finishing_time++;
  //start->distance_ = File::finishing_time;

  /*
  stack<File*> s;
  s.push(start);
  while (!s.empty()) {
    File *u = s.top();
    s.pop();
  */
  File *u=start;

    vector<File*>::const_iterator it = u->deps_.begin();
    const vector<File*>::const_iterator end=u->deps_.end();
    for(;it!=end;++it) {
      File *v = *it;
      if (v->color_ == WHITE) {
	v->color_ = GRAY;
	v->prev_ = u;
	//s.push(v);
	dfs_visit(v);
      } else if (v->color_ == GRAY && v->prev_ != u) {
	cout << "cycle exists u=" << u->name_ << " v=" << v->name_ << endl;
      }
    }
    
    u->color_ = BLACK;
    File::finishing_time++;
    u->finishing_time_ = File::finishing_time;
    // cout << u->name_ << endl;
    /*
  }
    */
}

void dfs(const vector<File*>& vertices) {

  vector<File*>::const_iterator it = vertices.begin();
  const vector<File*>::const_iterator end = vertices.end();

  for(;it!=end;++it)
    (*it)->color_ = WHITE;

  it = vertices.begin();
  for(;it!=end;++it)
    if ((*it)->color_ == WHITE)
      dfs_visit(*it);

}



struct compare_files {
  bool operator()(const File *lhs, const File *rhs) const { return (*lhs).finishing_time_ < (*rhs).finishing_time_; }
};

void topological_sort(vector<File*>& files) {

  dfs(files);
  sort(files.begin(),files.end(),compare_files());
  
  cout << "===" << endl;
  for (vector<File*>::const_iterator it =files.begin(); it!=files.end(); ++it) {
    cout << (*it)->name_ << endl;
  }


}

int main() {

  File A("A");
  File B("B");
  File C("C");
  File D("D");

  A.deps_.push_back(&B);
  B.deps_.push_back(&C);
  A.deps_.push_back(&D);
  D.deps_.push_back(&C);
  //D.deps_.push_back(&A);  // test circular dependencies

  vector<File*> vertices;
  vertices.push_back(&A);
  vertices.push_back(&B);
  vertices.push_back(&C);
  vertices.push_back(&D);

  topological_sort(vertices);

}
