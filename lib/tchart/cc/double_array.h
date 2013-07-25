class DoubleArray
{
public :
 int len;
 const double *data;
 DoubleArray() : data(0), len(0) {}
 DoubleArray(const double *data, int len) : data(data), len(len) {}
 double operator[](int i) const { return data[i]; }
};
