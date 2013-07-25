#include <string>
#include <ext/hash_map>
#include <ext/hash_set>
#include <vector>
#include <cctype>
#include "common.h"
#include <set>
#include "math.h"

#ifdef __GNUC__
#if __GNUC__ < 3
#include <hash_map.h>
namespace Sgi { using ::hash_map; }; // inherit globals
#else
#include <ext/hash_map>
#if __GNUC_MINOR__ == 0
namespace Sgi = std;               // GCC 3.0
#else
namespace Sgi = ::__gnu_cxx;       // GCC 3.1 and later
#endif
#endif
#else      // ...  there are other compilers, right?
namespace Sgi = std;
#endif

#if 1
namespace __gnu_cxx
{
    
    template<> struct hash<std::string>
    {
	size_t operator()(const std::string& __x) const
	    {
		return __stl_hash_string(__x.c_str());
	    }
    };
}
#else
namespace __gnu_cxx
{
    using namespace std;
    
    template<>
	struct hash<string>
	{
	    size_t operator()(const string& s) const
		{
		    const collate<char>& c = use_facet<collate<char> >(locale::classic());
		    return c.hash(s.c_str(), s.c_str() + s.size());
		}
	};
}
#endif

class Cmp {
 public:
    bool operator()(string s1, string s2)
	{
	    return compareStrings(s1,s2) > 0;
	}
};

using namespace std;
typedef Sgi::hash_set<string> myset;

class DataPoint
{
    string article;
    unsigned int index;
    Sgi::hash_map<string,double> wordVector; 
    void parseArticle(myset* removeSet);
    void addNext(string word);
    void normalize();
 public:
    DataPoint(string Article, unsigned int Index, myset* removeSet);
    DataPoint();
    void add(DataPoint* dp, double weight);
    void add(DataPoint* dp);
    string getArticle();
    void overwriteArticle(string newArticle);
    double cosineDistance(DataPoint* dp1, DataPoint* dp2);
    double cosineDistance(DataPoint* dp);
    string toString();
    Sgi::hash_map<string,double> getWordVector();
    unsigned int getIndex();
};

