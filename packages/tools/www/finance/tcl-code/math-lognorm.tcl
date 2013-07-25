##
## Lognormal income distributions
##
# Copyright 2007 Eric Kemp-Benedict
# Released under the BSD license under any terms
# that allow it to be compatible with tcllib
#
# "Lognormal Income Distributions":http://wiki.tcl.tk/19702

 package provide math::lognorm 0.1

 package require math::statistics

 namespace eval math::lognorm {
    # Maximum iterations for finding inverse normal
    variable maxiter 100
    variable epsilon 1.0e-9

    namespace export norminv gini2sdlog sdlog2gini \
        medmean_ratio L headcount gap cutoff

 }

 proc math::lognorm::quicknorminv {p} {
    variable epsilon

    if {$p < $epsilon || $p > 1-$epsilon} {
        error "Value out of bounds for inverse normal: $p"
        return 0
    }

    set sign -1
    if {$p > 0.5} {
        set p [expr {1 - $p}]
        set sign 1
    }

    set t [expr {sqrt(-2.0 * log($p))}]

    set a0 2.30753
    set a1 0.27061
    set b1 0.99229
    set b2 0.04481

    set num [expr {$a0 + $a1 * $t}]
    set denom [expr {1 + $b1 * $t + $b2 * $t * $t}]

    return [expr {$sign * ($t - $num/$denom)}]

 }

 proc math::lognorm::norminv {p} {
    variable maxiter
    variable epsilon

    set deltax [expr {100 * $epsilon}]

    # Initial value for x
    set x [quicknorminv $p]

    set niter 0
    while {abs([::math::statistics::pnorm $x] - $p) > $epsilon} {
        set pstar [::math::statistics::pnorm $x]
        set pl [::math::statistics::pnorm [expr {$x - $deltax}]]
        set ph [::math::statistics::pnorm [expr {$x + $deltax}]]

        set x [expr {$x + 2.0 * $deltax * ($p - $pstar)/($ph - $pl)}]

        incr niter
        if {$niter == $maxiter} {
            error "Inverse normal distribution did not converge after $niter iterations"
            return {}
        }
    }

    return $x

 }

 # Gini must be 0..1
 proc math::lognorm::gini2sdlog {gini} {
    set p [expr {0.5 * (1.0 + $gini)}]
    return [expr {sqrt(2.0) * [norminv $p]}]
 }

 proc math::lognorm::sdlog2gini {sdlog} {
    set x [expr {$sdlog/sqrt(2.0)}]
    return [expr {2.0 * [::math::statistics::pnorm $x] - 1.0}]
 }

 # Ratio of median to mean
 proc math::lognorm::medmean_ratio {gini} {
    set sdlog [gini2sdlog $gini]
    return [expr {exp(-0.5 * $sdlog * $sdlog)}]
 }

 # Lorenz curve
 proc math::lognorm::L {x gini} {
    variable epsilon

    if {$x < $epsilon || $x > 1.0 - $epsilon} {
        return $x
    }
    set p [norminv $x]
    set sdlog [gini2sdlog $gini]
    return [::math::statistics::pnorm [expr {$p - $sdlog}]]
 }

 proc math::lognorm::headcount {yc yave gini} {
    variable epsilon

    set sdlog [gini2sdlog $gini]
    set z [expr {1.0 * $yc / $yave}]
    if {$z < $epsilon} {
        return 0.0
    }
    set x [expr {(1.0/$sdlog) * log($z) + 0.5 * $sdlog}]
    return [::math::statistics::pnorm $x]
 }

 # Analogous to poverty gap
 proc math::lognorm::gap {yc yave gini} {
    variable epsilon

    if {$yc < $epsilon * $yave} {
        return 0.0
    }
    set hc [headcount $yc $yave $gini]
    set Lhc [L $hc $gini]
    return [expr {$hc - (1.0 * $yave/$yc) * $Lhc}]
 }

 # Inverse of headcount
 proc math::lognorm::cutoff {p yave gini} {
    variable epsilon

    if {$p < $epsilon} {
        return 0.0
    }
    set sdlog [gini2sdlog $gini]
    set x [norminv $p]
    return [expr {$yave * exp($sdlog * ($x - 0.5 * $sdlog))}]
 }
