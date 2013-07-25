##::xo::ns::array2set
##::xo::ns::set2array
##::xo::ns::exec
##::xo::ns::findset
##::xo::ns::set2attributes
##::xo::ns::set2map
##::xo::ns::set2query
##::xo::ns::uniqueset --- This procedure takes an ns_set id as an argument, makes all the keys unique and returns the setid. To do this, we combine all the keys with the same case-sensitive name into one key with the values of all the keys stored as a list with each element separated by the specified separator (, is the default).
## i.e. if separator is , key1=value1 key1=value2 key2=value3 becomes: key1=value1,value2 key2=value3
