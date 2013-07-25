class IntArray
{
public :
 int len;
 const int *data;
 IntArray() : data(0), len(0) {}
 IntArray(const int *data, int len) : data(data), len(len) {}
 int operator[](int i) const { return data[i]; }
};
