#ifndef M_H
#define M_H

#include <stdio.h>
#include <math.h>
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <GL/gl.h>
using namespace std;

class M {
 public:
  unsigned short w, h;
  double * d;

  inline static M eye(int s){
    M o(s,s);
    for(int i=0; i<s; ++i){ o(i,i) = 1; }
    return o;
  }
  
  inline M(int h_, int w_) : w(w_), h(h_) {
    d = new double[w*h];
    memset(d,0x00,w*h*sizeof(double));
  }

  inline M(int h_) : w(1), h(h_) {
    d = new double[w*h];
    memset(d,0x00,w*h*sizeof(double));
  }

  inline M() : w(1), h(1) {
    d = new double[w*h];
    memset(d,0x00,w*h*sizeof(double));
  }

  inline ~M(){
    delete [] d;
  }
  
  inline M(const M & m0){
    w = m0.w; h = m0.h;
    d = new double[w*h];
    memcpy(d, m0.d, sizeof(double) * w * h);
  }

  inline M operator=(const M & m0){
    if(h != m0.h || w != m0.w){
      delete [] d;
      w = m0.w; h = m0.h;
      d = new double[w*h];
    }
    memcpy(d, m0.d, sizeof(double) * w * h);
    return *this;
  }
    
  inline double & operator()(int r, int c){
    assert(r >= 0 && r < h);
    assert(c >= 0 && c < w);
    return d[r*w+c];
  }

  inline const double & operator()(int r, int c) const {
    assert(r >= 0 && r < h);
    assert(c >= 0 && c < w);
    return d[r*w+c];
  }

  inline double & operator()(int i){
    assert(i >= 0 && i < w*h);
    return d[i];
  }
  
  inline const double & operator()(int i) const {
    assert(i >= 0 && i < w*h);
    return d[i];
  }

  inline double length(){
    assert(w == 1 || h == 1);
    double sum = 0;
    for(int i=0; i<w*h; ++i) sum += d[i]*d[i];
    return sqrt(sum);
  }

  inline M operator*=(double c){
    for(int i=0; i<w*h; ++i){
      d[i] *= c;
    }
    return *this;
  }
  
  inline operator double(){
    assert(w == 1 && h == 1);
    return d[0];
  }

  inline M row(int r){
    M o(1,w);
    for(int c=0; c<w; ++c) o(c) = (*this)(r,c);
    return o;
  }

  inline M col(int c){
    M o(h,1);
    for(int r=0; r<h; ++r) o(r) = (*this)(r,c);
    return o;
  }

  inline double sum(){
    double ss = 0;
    for(int i=w*h-1; i>=0; --i) ss += d[i];
    return ss;
  }
  
};

inline M map(M m, double (*fun)(double)){
  for(int i=m.w*m.h-1; i>=0; --i) m(i) = (*fun)(m(i));
  return m;
}

inline M operator+(M left, M right){
  assert(left.h == right.h && left.w == right.w);
  for(int i=left.w*left.h-1; i >= 0; --i) left.d[i] += right.d[i];
  return left;
}

inline M operator-(M left, M right){
  assert(left.h == right.h && left.w == right.w);
  for(int i=left.w*left.h-1; i >= 0; --i) left.d[i] -= right.d[i];
  return left;
}


inline M operator/(M left, M right){
  if(right.w != 1 || right.h != 1){
    assert(0);
  }
  left *= 1./right.d[0];
  return left;
}

inline M operator*(M left, M right){
  assert(left.w == right.h);
  
  M o(left.h, right.w);

  for(int c = 0; c < right.w; ++c){
    for(int r = 0; r < left.h; ++r){
      double s = 0;
      for(int i=0; i < right.h; ++i){
        s += left(r, i) * right(i, c);
      }
      o(r,c) = s;
    }
  }
  return o;
}

inline M operator*(M m, double v){
  M o(m);
  o *= v;
  return o;
}
inline M operator*(double v, M m){
  M o(m);
  o *= v;
  return o;
}



inline M tr(M orig){
  
  M o(orig.w, orig.h);

  for(int r=0; r<orig.h; ++r){
    for(int c=0; c<orig.w; ++c){
      o(c,r) = orig(r,c);
    }
  }
  return o;
}

inline ostream & operator<<(ostream & o, M m){
  

  if(m.h == 1 || m.w == 1){
    o << "<";
    for(int i=0; i<m.w*m.h; ++i){
      if(i) o << ",";
      o << m.d[i];
    }
    o << ">";
    if(m.h != 1) o << "'";
  }else{
    for(int i=0; i<m.h; ++i){
      o << "[";
      for(int j=0; j<m.w; ++j){
        if(j) o << ",";
        o << m(i,j);
      }
      o << "]\n";
    }  
  }
  return o;
}

typedef M V;

#define V2NAN 666

class V2 {
 public:
  union {
    double d[2];
    struct {
      double x;
      double y;
    };
  };

  inline double lengthSqr() const { return x*x+y*y; }
  inline double length() const { return sqrt(x*x+y*y); }
  inline double atan() const { return atan2(y,x); }
  
	inline V2(int i_){
		assert(i_ == V2NAN);
		x = y = sqrt(-1.0);
	}
	inline bool isFinite(){
		return isfinite(x) && isfinite(y);
	}
	
  inline V2(double x_, double y_) : x(x_), y(y_) { }
  inline V2() : x(0), y(0) { }
  inline V2(M m){
    assert(m.w == 2 && m.h == 1 || m.w == 1 && m.h == 2);
    x = m.d[0];
    y = m.d[1];
  }
  
  inline operator M() const{
    M m(2);
    m(0) = x;
    m(1) = y;
    return m;
  }

  inline V2 rot90() const { return V2(-y,x); }
  inline V2 rot180() const { return V2(-y,-x); }
  inline V2 rot270() const { return V2(y,x); }

  inline void nml(){
    double f = length();
    x /= f;
    y /= f;
  }
  
};


inline V2 operator+(const V2 & l, const V2 & r){
  return V2(l.x+r.x, l.y+r.y);
}
inline V2 operator-(const V2 & l, const V2 & r){
  return V2(l.x-r.x, l.y-r.y);
}

inline V2 operator*(const V2 & v, double d){
  return V2(v.x*d, v.y*d);
}
inline V2 operator*(double d, const V2 & v){
  return V2(v.x*d, v.y*d);
}

// this is a compact representation 
#define CHARV2SCALEF 0.01
class charV2 {
 public:
  char x, y;

  charV2() : x(0), y(0) { }
  ~charV2() { }
  charV2(const charV2 & o) : x(o.x), y(o.y) { }
  
  charV2(const V2 & o){
    int xi = (int) round(o.x/CHARV2SCALEF);
    int yi = (int) round(o.y/CHARV2SCALEF);
    if(xi > 127) xi = 127; if(xi < -128) xi = -128;
    if(yi > 127) yi = 127; if(yi < -128) yi = -128;
    x = xi;
    y = yi;
  }

  inline operator V2() const {
    return V2(x*CHARV2SCALEF, y*CHARV2SCALEF);
  }
};

inline int distsqr(const charV2 & l, const charV2 & r){
  return (l.x-r.x)*(l.x-r.x)+(l.y-r.y)*(l.y-r.y);
}

inline charV2 avg(const charV2 & l, const charV2 & r){
  charV2 a;
  a.x = ((int)l.x+(int)r.x)/2;
  a.y = ((int)l.y+(int)r.y)/2;
  return a;
}

inline void glVertex(const charV2 & v){
  glVertex3f(v.x*CHARV2SCALEF, v.y*CHARV2SCALEF, 0);
}

inline void glVertex(const V2 & v){ glVertex3f(v.x,v.y,0); }
//inline void glVertex(V2 v){ glVertex3f(v.x,v.y,0); }
inline void glTranslate(const V2 & v){ glTranslated(v.x,v.y,0); }
inline void glRotate(const V2 & v){
  glRotated(180.0/M_PI*v.atan(), 0, 0, 1);
}

inline double dot(const V2 & a, const V2 & b){
  return a.x*b.x+a.y*b.y;
}








inline void swap(M & a, M & b, int r1, int r2){
  if(r1 == r2) return;
//  fprintf(stderr, "swapping rows %d and %d\n", r1, r2);
  double t;
  for(int c=0; c<a.w; ++c){
    t = a(r1,c);
    a(r1,c) = a(r2,c);
    a(r2,c) = t;
  }
  for(int c=0; c<b.w; ++c){
    t = b(r1,c);
    b(r1,c) = b(r2,c);
    b(r2,c) = t;
  }
}

inline void addsome(M & a, M & b, int to, int from, double howmuch){
  if(howmuch == 0.0) return;
//  fprintf(stderr, "adding %e of row %d to row %d\n", howmuch, from, to);
  for(int c=0; c<a.w; ++c){
    a(to,c) += a(from,c) * howmuch;
  }
  for(int c=0; c<b.w; ++c){
    b(to,c) += b(from,c) * howmuch;
  }
}

inline void mul(M & a, M & b, int r, double by){
  if(by == 1.0) return;
//  fprintf(stderr, "multiplying row %d by %e\n", r, by);
  for(int c=0; c<a.w; ++c){
    a(r,c) *= by;
  }
  for(int c=0; c<b.w; ++c){
    b(r,c) *= by;
  }
}


inline M inv(M o){
  M orig = o;
  assert(o.w == o.h);
  M i(o.h,o.w);
  for(int z=0; z<i.h; ++z){ i(z,z) = 1; }

  // zero columns
  for(int c=0; c<o.w; ++c){
    // column c
    // find largest
    double mv = 0;
    int mr = -1;
    for(int r=c; r<o.h; ++r){
      if(fabs(o(r,c))>mv){ mv = fabs(o(r,c)); mr = r; }
    }
    assert(mv != 0.0);
    swap(o,i,c,mr);
    
    for(int r=c+1; r<o.h; ++r){ addsome(o,i,r,c,-o(r,c)/o(c,c)); }
    mul(o,i,c,1/o(c,c));
  }

//  cerr << "after ref phase.\no=" << o << "i=" << i;
  
  for(int r=0; r<o.h; ++r){
    for(int c=r+1; c<o.w; ++c){
      addsome(o,i,r,c,-o(r,c));
    }
  }
  
//  cerr << "after final phase.\no=" << o << "i=" << i;

  if((orig*i-M::eye(i.w)).sum() > 1e-5){
    fprintf(stderr, "MATRIX INVERSION FAILED.\n");
    cerr << "orig=" << orig << "\n";
    cerr << "out=" << i << "\n";



    assert(0);
  }
  
  return i;
}














inline M operator^(M base, double ex){
  if(base.w != 1 && base.h != 1){
    cerr << "doing cellwise power, not what you want!!\n";
  }
  for(int i=base.h*base.w-1; i>=0; --i){
    base(i) = pow(base(i), ex);
  }
  return base;
}


#define M23NAN 666

class M23 {
 public:
  union {
    double v[6];   
    struct {
      double a;
      double b;
      union{ double c; double x; };
      double d;
      double e; 
      union{ double f; double y; };
    };
  };
  inline M23(){ b = c = d = f = 0.0; a = e = 1.0; }

	inline M23(int n){
		assert(n == M23NAN);
		a = b = c = d = e = f = sqrt(-1.0);
	}

  /*
  inline M23(const M & m){
    a = m(0,0);
    b = m(0,1);
    c = m(0,2);
    d = m(1,0);
    e = m(1,1);
    f = m(1,2);
  }*/
    
  inline operator M() const {
    M m(3,3);
    m(0,0)=a;
    m(0,1)=b;
    m(0,2)=c;
    m(1,0)=d;
    m(1,1)=e;
    m(1,2)=f;
    m(2,2)=1;
    return m;
  }
  
  inline M23(const M & m){
    assert(m.w == 3 && (m.h == 2 || m.h == 3));
    a = m(0,0);
    b = m(0,1);
    c = m(0,2);
    d = m(1,0);
    e = m(1,1);
    f = m(1,2);
  }

  static inline M23 rotate(double radians){
    M23 m;
    m.a = m.e = cos(radians);
    m.b = -(m.d = sin(radians));
    m.x = m.y = 0;
    return m;
  }

  static inline M23 translate(const V2 & v){
    M23 m;
    m.x = v.x;
    m.y = v.y;
    return m;
  }

  inline V2 zv() const { return V2(x,y); }
  
  inline static void moveToM23(double left, double right, double radius, M23 & xf);

  inline double atan() const;

  
  /*
  M23(const XF & xf){
    c = xf.x;
    f = xf.y;
    a = e = cos(xf.th);
    b = - (d = sin(xf.th));
  }
  */

  void glMult(){
    double m[16];
    memset(m, 0x00, sizeof(m));
    m[0] = a;
    m[4] = b;
    m[12] = c;
    m[1] = d;
    m[5] = e;
    m[13] = f;
    m[10] = 1;
    m[15] = 1;
    glMultMatrixd(m);
  }

	bool isFinite() const {
		return isfinite(a) &&
			     isfinite(b) &&
			     isfinite(c) &&
			     isfinite(d) &&
			     isfinite(e) &&
			     isfinite(f);
	}
	
};

inline V2 operator*(M23 m, V2 v){
  return V2(
    v.x*m.a + v.y*m.b + m.c,
    v.x*m.d + v.y*m.e + m.f);
}

inline V2 vmul(M23 m, V2 v){
  return V2(
    v.x*m.a + v.y*m.b ,
    v.x*m.d + v.y*m.e );
}
  
inline double M23::atan() const {
  return vmul((*this),V2(1,0)).atan();
}


// this is cheating on m.c = n.r but who cares.
// we know why we're using 2x3 matrices anyway right.
inline M23 operator*(M23 l, M23 r){
  M23 o;
  o.a = l.a*r.a + l.b*r.d;
  o.b = l.a*r.b + l.b*r.e;
  o.c = l.a*r.c + l.b*r.f + l.c;
  o.d = l.d*r.a + l.e*r.d;
  o.e = l.d*r.b + l.e*r.e;
  o.f = l.d*r.c + l.e*r.f + l.f;
  return o;
}
  
inline M eigenvectors(M m){
  assert(m.w == m.h);
  M eigs(m.w,m.w);
  M qux = m;
  
  for(int c=0; c<m.w; ++c){
    M v(m.w);
    for(int i=0; i<v.h; ++i) v(i) = rand()/(double)RAND_MAX;
    for(int i=0; i<1000; ++i){ v = qux * v; v *= 1. / v.length(); }
    double vl = tr(v)*qux*v/(tr(v)*v);
    qux = qux - vl*v*tr(v);
    for(int r=0; r<m.w; ++r) eigs(r,c) = v(r);
  }  
  return eigs;
}

inline double eigenvalue(M m, M v){
  return tr(v)*m*v/(tr(v)*v);
}

inline void M23::moveToM23(double left, double right, double radius, M23 & xf){

  //double left = d->left * pixels_per_meter;
  //double right = d->right * pixels_per_meter;
  //double radius = d->radius * pixels_per_meter;

  xf = M23();
  
  double slope = (right-left)/(2*radius);
  if(slope == 0.0){
    xf.x = left;
    //fprintf(stderr, "mode 1\n");
  }else{
    //fprintf(stderr, "mode 2\n");
    double rads;
    V2 center;
    
    if(fabs(left+right) < 0.00001){
      rads = (right-left)/radius/2.0;
      center = V2();
    }else{ 
      /* right + (x-radius)*slope = 0 */
      /* x-radius = -right/slope */
      /* x = radius-right/slope */
      double y = radius-right/slope;
      center = V2(0,-y);
      rads = -((left+right)/2.0) / y;
    }

    M23 trans;
    trans.x = center.x;
    trans.y = center.y;
    M23 untrans;
    untrans.x = -center.x;
    untrans.y = -center.y;
    M23 rot;
    rot.a = rot.e = cos(rads);
    rot.b = -sin(rads);
    rot.d =  sin(rads);
    xf = trans * rot * untrans;

  }

}

class color {
 public:
  unsigned char r,g,b;
  color(){ r=g=b=128; }
  color(const color & o){ r = o.r; g = o.g; b = o.b; }
  color(int r_, int g_, int b_){ r=r_; g=g_; b=b_; }
  color(double rd, double gd, double bd){
    r = 255*rd > 255.0 ? 255 : 255*rd < 0.0 ? 0 : (int)(255*rd);
    g = 255*gd > 255.0 ? 255 : 255*gd < 0.0 ? 0 : (int)(255*gd);
    b = 255*bd > 255.0 ? 255 : 255*bd < 0.0 ? 0 : (int)(255*bd);
  }
};

inline void glColor(const color & c){ glColor3ub(c.r,c.g,c.b); }

inline double randu(){
	return rand()/(double)RAND_MAX;
}

inline double randn(){
	const double S = 0.449871, T = -0.386595,
				A = 0.19600, B = 0.25472,
				R1 = 0.27597, R2 = 0.27846;

	double U, V, X, Y, Q;

l50:
	
	U = randu();
	V = randu();
	V = 1.7156 * (V - 0.5);
	X = U - S;
	Y = fabs(V) - T;
	Q = X*X + Y*(A*Y-B*X);

	if(Q < R1) goto l100;
	if(Q > R2) goto l50;
	if( (V*V) > (-4.0*log(fabs(U))*U*U) ) goto l50;
l100:
	
	return V/U;
}

#endif
