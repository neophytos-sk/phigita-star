#include <string>
#include <vector>
#include <set>

class File {
public:
  File(std::string p_name) : name(p_name) {};
  std::string name;
  std::vector<File*> deps;
};


void topological_sort_aux(const File *f, std::set<std::string>& visited) {

  printf("%s\n",f->name.c_str());
  visited.insert(f->name);

  std::vector<File*>::const_iterator itr;
  for (itr = f->deps.begin(); itr != f->deps.end(); ++itr) {
    if (!visited.count((*itr)->name)) {
      topological_sort_aux(*itr, visited);
    }
  }

}


void topological_sort(const File *f) {
  std::set<std::string> visited;
  topological_sort_aux(f,visited);
}

int main() {

  File a("A");
  File b("B");
  File c("C");
  File d("D");

  a.deps.push_back(&b);
  a.deps.push_back(&d);
  b.deps.push_back(&c);
  d.deps.push_back(&c);
  d.deps.push_back(&a);


  topological_sort(&a);

  return 0;
}
