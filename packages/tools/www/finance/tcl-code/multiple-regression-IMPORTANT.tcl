package require math::linearalgebra
namespace eval multipleRegression {
    namespace export regressionCoefficients
    namespace import ::math::linearalgebra::*
 
    # Matrix inversion is defined in terms of Gaussian elimination
    # Note that we assume (correctly) that we have a square matrix
    proc invert {matrix} {
	solveGauss $matrix [mkIdentity [lindex [shape $matrix] 0]]
    }
    # Implement the Ordinary Least Squares method
    proc regressionCoefficients {y x} {
	matmul [matmul [invert [matmul $x [transpose $x]]] $x] $y
    }
}
namespace import multipleRegression::regressionCoefficients
# Simple helper just for this example
proc map {n exp list} {
    upvar 1 $n v
    set r {}; foreach v $list {lappend r [uplevel 1 $exp]}; return $r
}
 
# Data from wikipedia
set x {
    1.47 1.50 1.52 1.55 1.57 1.60 1.63 1.65 1.68 1.70 1.73 1.75 1.78 1.80 1.83
}
set y {
    52.21 53.12 54.48 55.84 57.20 58.57 59.93 61.29 63.11 64.47 66.28 68.10
    69.92 72.19 74.46
}
# Wikipedia states that fitting up to the square of x[i] is worth it

puts "EXPECTED OUTPUT: 128.81280358170625 -143.16202286630732 61.96032544293041"
puts "RETURNED OUTPUT: [regressionCoefficients $y [map n {map v {expr {$v**$n}} $x} {0 1 2}]]

### http://rosettacode.org/wiki/Multiple_regression#Tcl
