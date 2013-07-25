class StringArray
{
public :
 int len;
 const char * const *data;
 StringArray() : data(0), len(0) {}
 StringArray(const char * const *data, int len) : data(data), len(len) {}
 const char *operator[](int i) const { return data[i]; }
};
