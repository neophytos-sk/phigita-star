def quick_find_1d_peak(array):
    """Finds a peak of a mountain range.

    The mountain range is a 1-dimensional array of values. A peak is
    defined as a location which is at least as high as the adjacent
    locations. Returns the index in the array of some peak.

    Keyword arguments:
    array -- an array containing the values

    returns the location x0 of the peak

    """

    ############## IMPLEMENT the O(log n) time algorithm here ############
    x0 = 1
    
    return x0
    
    ##################################################################

def slow_find_1d_peak(array):
    best_x = 0
    best_h = array[0]
    for x in range(1, len(array)):
        h = array[x]
        if best_h < h:
            best_x = x
            best_h = h
    return best_x


################ IO ####################

def my_function(x):
    v = 1
    for i in range(x%37):
        v = (v*137) % 203
    return v

def get_array(f, n):
    array = []
    for x in range(n):
        array.append(f(x))
    return array


if __name__ == "__main__":
    n = 100000
    array = get_array(my_function, n)
    import profile
    profile.run("print 'slow:', slow_find_1d_peak(array)")
    profile.run("print 'quick:', quick_find_1d_peak(array)")
