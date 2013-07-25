
#define fi(a, b) for(int i=((int)(a)); i < ((int)(b)); i++)
#define fie(a, b) for(int i=((int)(a)); i <= ((int)(b)); i++)
#define fj(a, b) for(int j=((int)(a)); j < ((int)(b)); j++)
#define fje(a, b) for(int j=((int)(a)); j <= ((int)(b)); j++)
#define fk(a, b) for(int k=((int)(a)); k < ((int)(b)); k++)
#define fl(a, b) for(int l=((int)(a)); l < ((int)(b)); l++)
#define di(a) for(int i=(int)((a)-1); i>=0; i--)
#define dj(a) for(int j=(int)((a)-1); j>=0; j--)
#define die(a) for(int i=(int)(a); i>=0; i--)
#define dje(a) for(int j=(int)(a); j>=0; j--)
#define fdi(a, b) for(int i=((int)(a)); i > ((int)(b)); i--)
#define fdj(a, b) for(int j=((int)(a)); j > ((int)(b)); j--)
#define fdk(a, b) for(int k=((int)(a)); k > ((int)(b)); k--)
#define fdl(a, b) for(int l=((int)(a)); l > ((int)(b)); l--)
#define ri(b) for(int i=0; i < ((int)(b)); i++)
#define rie(b) for(int i=0; i <= ((int)(b)); i++)
#define rj(b) for(int j=0; j < ((int)(b)); j++)
#define rje(b) for(int j=0; j <= ((int)(b)); j++)
#define rk(b) for(int k=0; k < ((int)(b)); k++)
#define rke(b) for(int k=0; k < ((int)(b)); k++)
#define rl(b) for(int l=0; l < ((int)(b)); l++)
 
#define itadj for(int adx=-1; adx<=1; adx++) for(int ady=-1; ady<=1; ady++)
#define chkadj(i, j, n, m) ((i)>=0&&(j)>=0&&(i)<n&&(j)<m)
 
#define fe(v,it) for(__typeof(v.begin()) it=v.begin(); it != v.end(); it++)
 
typedef int i32;
typedef unsigned int u32;
typedef long long i64;
typedef long long ll;
typedef unsigned long long u64;
typedef string str;
typedef double dbl;
 
#define bz(a) memset(a,0,sizeof(a))
#define sq(x) ((x)*(x))
 
typedef vector< i32 > vi;
typedef vector< str > vs;
typedef vector< i64 > vl;
typedef vector< vi  > vvi;
typedef vector< vs  > vvs;
typedef vector< dbl > vd;
typedef vector< vd  > vvd;
 
typedef set< i32 > si;
typedef set< str  > ss;
 
typedef vi::iterator  itri;
typedef vvi::iterator itrvi;
typedef vs::iterator  itrs;
typedef vvs::iterator itrvs;
typedef vd::iterator  itrd;
typedef vvd::iterator itrvd;
 
#define ffof   find_first_of
#define ffnof  find_first_not_of
 
#define MAX(a,b) ((a)>(b)?(a):(b))
#define MIN(a,b) ((a)>(b)?(b):(a))
#define ABS(a)   MAX((a),-(a))
#define DIST(a,b) ABS((a)-(b))
 
#define vp(v,a)  (v).push_back(a)
#define vpb(v,a) (v).push_back(a)
#define vpf(v,a) (v).push_front(a)
#define vpob(v) (v).pop_back()
#define vpof(v) (v).pop_front()
 
#define va(v) (v).begin(), (v).end()
#define vf(v,a) find(va(v),(a))
#define ve(v,a) (vf(v,a)!=(v).end())
#define vins(v,a) do { if (!ve(v,a)) vpb(v, a); } while(0)
#define vind(v,a) (ve(v,a)?(vf(v,a)-v.begin()):-1)
#define vdel(v,a) v.erase(remove(va(v),a),v.end())
 
inline i64 gcd(i64 a, i64 b) { if (b==0) return a; return gcd(b, a%b); }
inline i64 lcm(i64 a, i64 b) { return (a*b)/gcd(a,b);                  }
 
#define sz size()
 
#define mp(x, y) make_pair(x, y)
#define mt(x, y, z) mp(mp(x,y),z)
 
#define pfst(p) (p).first
#define pscd(p) (p).second
 
#define tfst(t) (t).first.first
#define tscd(t) (t).first.second
#define tthd(t) (t).second
 
typedef pair<int, int> pii;
typedef pair<int, str> pis;
typedef pair<str, int> psi;
typedef pair<str, str> pss;
 
typedef pair< pii, int > tii;
typedef pair< pss, str > tss;
 
#define pq priority_queue
 
#define dbg_vint(v) do { copy(va(v),ostream_iterator<int>(cout,"\t")); cout << endl; } while(0)
#define dbg_vstr(v) do { copy(va(v),ostream_iterator<str>(cout,"\n")); cout << endl; } while(0)
#define dbg_vdbl(v) do { copy(va(v),ostream_iterator<dbl>(cout,"\t")); cout << endl; } while(0)
 