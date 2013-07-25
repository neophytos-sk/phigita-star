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
    -5 -4 -3 -2 -1 0 1 2 3 4 5
}
set y {
    0 0 0 1 1 1 0 0 0 0 0
}

puts "\n\nOCTAVE polytfit(x,y,10) RETURNS:   -4.4643e-05   8.2672e-06   2.3810e-03  -2.4802e-04  -4.2049e-02  -1.9097e-03   2.8904e-01   9.7388e-02  -7.4933e-01  -5.9524e-01   1.0000e+00"
puts "\n\nEXPECTED OUTPUT (it's the reverse list of the octave answer):\n\t  1.00000000006537 -0.5952380952367058 -0.7493253970208821 0.09738756613664074 0.28903769849979777 -0.0019097222220637658 -0.04204861112383787 -0.00024801587302550896 0.0023809523816675196 8.26719576738358e-6 -4.464285715618019e-5"
puts "\n\nRETURNED OUTPUT:\n\t [regressionCoefficients $y [map n {map v {expr {$v**$n}} $x} {0 1 2 3 4 5 6 7 8 9 10}]]"

puts "\n\n BETTER FITTING (OCTAVE):\n\t   -1.2821e-03   2.6224e-03   4.7786e-02  -9.4697e-02  -3.9965e-01   7.5291e-01"
puts "\n\n BETTER FITTING (TCL, reverse list first to compare with octave):\n\t [regressionCoefficients $y [map n {map v {expr {$v**$n}} $x} {0 1 2 3 4 5}]]"

### octave-least-squares-trefethen-and-bau-data.m
