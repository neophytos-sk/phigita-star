
typedef long long int64;
typedef unsigned long long uint64;
typedef unsigned int uint;
typedef unsigned short ushort;
typedef unsigned char uchar;
typedef pair<int,int> ipair;
typedef vector<int> VI;
typedef vector<string> VS;

#define two(X) (1<<(X))
#define contain(S,X) ((S&two(X))!=0)
#define SIZE(A) ((int)A.size())
#define LENGTH(A) ((int)A.length())
#define MP(A,B) make_pair(A,B)

const double pi=acos(-1.0);
const double eps=1e-11;

template<class T> inline void ckmin(T &a,const T &b) { if (b<a) a=b; }
template<class T> inline void ckmax(T &a,const T &b) { if (b>a) a=b; }
template<class T> inline T sqr(const T &a) { return a*a; }
template<class T> inline string toString(const T &a) { ostringstream sout; sout<<a; sout.flush(); return sout.str(); }
template<class T> inline int toInt(string s) { int v; istringstream sin(s); sin>>v; return v; }
template<class T> inline int toInt64(string s) { int64 v; istringstream sin(s); sin>>v; return v; }
template<class T> inline T lowbit(const T &n) { return (n^(n-1))&n; }
template<class T> int countbit(const T &n) { return (n==0)?0:(1+countbit(n&(n-1))); }

template<class T> inline T gcd(const T &a,const T &b) { return (b==0)?abs(a):gcd(b,a%b); }
template<class T> inline T lcm(const T &a,const T &b) { return a*(b/gcd(a,b)); }
int64 euclide(int64 a,int64 b,int64 &x,int64 &y) { if (b==0) { x=1; y=0; return a; } else { int64 d=euclide(b,a%b,x,y); int64 t=x; x=y; y=t-(a/b)*y; return d; } }

template<class T> void out(vector<T> a,int n=-1) { if (n<0) n=SIZE(a); ckmin(n,SIZE(a)); cout<<"{"; for (int i=0;i<n;i++) cout<<a[i]<<", "; cout<<"}"<<endl; }
template<class T> void out(T *a,int n) { if (n<0) n=0; cout<<"{"; for (int i=0;i<n;i++) cout<<a[i]<<", "; cout<<"}"<<endl; }
void out(string s) { cout<<s<<endl; }

const int maxsize=300+5;
int64 oo=1000000000LL*1000000000LL; 
