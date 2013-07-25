import sys
import profile

############### Auxiliary functions #####################
def find_column_global_max(matrix, x, y0, y1):
    """ Finds global maximum of column x between rows y0 and y1 (inclusive). """
    best_y = y0
    best_h = matrix[x][best_y]
    for y in range(y0+1, y1+1):
        h = matrix[x][y]
        if best_h < h:
            best_y = y
            best_h = h
    return (best_y, best_h)            

def find_row_global_max(matrix, x0, x1, y):
    """ Finds global maximum of row y between columns x0 and x1 (inclusive). """
    best_x = x0
    best_h = matrix[best_x][y]
    for x in range(x0+1, x1+1):
        h = matrix[x][y]
        if best_h < h:
            best_x = x
            best_h = h
    return (best_x, best_h)            

def find_global_max(matrix, x0, x1, y0, y1):
    """ Finds global maximum of sub-matrix between columns x0 and x1 and rows y0 and y1 (inclusive). """
    best_x = x0
    best_y = y0
    best_h = matrix[best_x][best_y]
    for x in range(x0, x1+1):
        for y in range(y0, y1+1):
            h = matrix[x][y]
            if(best_h < h):
                best_x = x
                best_y = y
                best_h = h
    return (best_x, best_y, best_h)

############################################################


####################### Algorithms Implementation #########################

"""Find a peak of a mountain range.

The mountain range is a 2-dimensional matrix of integers values,
indexed by closed intervals [x0,x1] and [y0,y1].

A peak is defined as a location which is at least as high as the adjacent
locations (two locations are adjacent if they share a common edge).

Keyword arguments:
matrix -- a matrix of altitudes
x0 -- an integer which is the leftmost index of the range
x1 -- an integer which is the rightmost index of the range
y0 -- an integer which is the bottom-most index of the range
y1 -- an integer which is the topmost index of the range

Return value: a pair of coordinates (x, y) of any local maximum location

"""

def quick_find_2d_peak(matrix, x0, x1, y0, y1):
    """
    Implement O(n) solution given in lecture.
    """
    
    ########### WRITE YOUR IMPLEMENTATION HERE ############
    
    return (x0, y0) # Change this to return your solution.
    #######################################################


def medium_find_2d_peak(matrix, x0, x1, y0, y1):
    """
    Implements O(n log(n)) solution given in lecture.
    """
    
    while x0 < x1: 

        mid_x = (x0+x1)/2 # If the width of the range is even,
                          # this picks the cell slightly to the left of the middle
 
        mid_col_glob_max = find_column_global_max(matrix, mid_x, y0, y1)
        right_col_glob_max = find_column_global_max(matrix, mid_x + 1, y0, y1)

        if right_col_glob_max[1] > mid_col_glob_max[1]:
            x0 = mid_x + 1 # choose the right half
        else:
            x1 = mid_x # choose the left half
             
    max_y_and_value = find_column_global_max(matrix, x0, y0, y1)
    return (x0, max_y_and_value[0])


def slow_find_2d_peak(matrix, x0, x1, y0, y1):
    """
    Implements O(n^2) solution given in lecture.
    """
    result = find_global_max(matrix, x0, x1, y0, y1)
    return (result[0], result[1])
##########################################################################


########################## Input Reading ##############################
def count_peaks(n, matrix):
    """
    Counts the number of peaks in an array of size n*n
    """
    peaks = 0
    for x in range(0, n):
        for y in range(0, n):
           if is_a_peak(n, matrix, (x, y)):
              peaks += 1
    return peaks

def read_input(filename):
    """
    Reads an array from the file filename.
    Returns a pair (n,array) where array is an array of size n*n
    """
    # Read the input file
    try:
        fp = open(filename)
        content = fp.read()
    except IOError:
        print "Error opening or reading input file: ", filename
        sys.exit()
    # Convert the input into words
    words = content.split()
    # Convert all words into integers
    try:
        numbers = map(int, words)
    except ValueError:
        print "Error: the input file doesn't consist of integers"
    # make sure the file is not empty
    if len(words) == 0:
        print "Error: the input file is empty"
        sys.exit()
    n = numbers[0]
    if len(numbers) != n*n + 1:
        print "Error: the file contains an incorrect number of integers"
        sys.exit()
    matrix = [[numbers[i + j*n + 1] for i in range(0, n)] for j in range(0, n)]
    peaks = count_peaks(n, matrix)
    print "Read file %s with n = %d and %d peaks" %(filename, n, peaks)
    # construct array
    return (n, matrix)
#######################################################################


############################# Testing #################################
def is_a_peak(n, matrix, (x, y)):
    """
    Checks if a given location (x,y) is a peak in an array of size n*n
    """
    value = matrix[x][y]
    if x > 0 and matrix[x-1][y] > value:
        return False
    if y > 0 and matrix[x][y-1] > value:
        return False
    if x < n - 1 and matrix[x+1][y] > value:
        return False
    if y < n - 1 and matrix[x][y+1] > value:
        return False
    return True

def test(n, matrix):
    """
    Runs quick, medium and slow 2d peak finding algorithms
    on a given matrix of size n and checks their correctness.
    """
    
    (x_peak, y_peak) = quick_find_2d_peak(matrix,0,n-1,0,n-1)
    print "quick:", x_peak, y_peak, matrix[x_peak][y_peak]
    print "correct solution:", is_a_peak(n, matrix, (x_peak, y_peak))
    print
    
    (x_peak, y_peak) = medium_find_2d_peak(matrix,0,n-1,0,n-1)
    print "medium:", x_peak, y_peak, matrix[x_peak][y_peak]
    print "correct solution:", is_a_peak(n, matrix, (x_peak, y_peak))
    print
    
    (x_peak, y_peak) = slow_find_2d_peak(matrix,0,n-1,0,n-1)
    print "slow:", x_peak, y_peak, matrix[x_peak][y_peak] 
    print "correct solution:", is_a_peak(n, matrix, (x_peak, y_peak))
    print

def test_from_file(filename):
    """ Performs test on an input from a file """
    print "test", filename, "\n"
    (n, matrix) = read_input(filename)
    test(n, matrix)
    print "\n"
#######################################################################


if __name__ == "__main__":
    test_from_file("1_small_random.txt")
    test_from_file("2_medium_random.txt")
    test_from_file("3_big_random.txt")
    test_from_file("4_two_mountains.txt")
    test_from_file("5_20_mountains.txt")
    test_from_file("6_100_mountains.txt")
    test_from_file("7_small_spiral.txt")
    test_from_file("8_medium_spiral.txt")
    test_from_file("9_big_spiral.txt")
