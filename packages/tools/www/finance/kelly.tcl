# "A Kelly Strategy Calculator":http://www.albionresearch.com/kelly/


::xo::kit::pretend_user 814

package require critcl

# b is the net odds received on the wager
# p is the probability of winning
# q is the probability of losing, which is 1 - p
critcl::cproc kelly {double oddsWin double oddsLose double p} double {
    double b = oddsWin / oddsLose;
    double q = 1 - p;
    return (b*p-q)/b;
}

proc kelly_bet {oddsWin oddsLose probWin} {
    return [kelly $oddsWin $oddsLose $probWin]
}


set oddsWin 7
set oddsLose 4
set probWin 0.40

set fraction_to_wager [kelly_bet $oddsWin $oddsLose $probWin]


set capital 1000
set betMultiple "1.0"
set betMinimum "10.0" ;# not implemented yet

set result ""
if { $fraction_to_wager > 0 } {
    set percentWin [expr { 100 * $probWin}]
    set percentToWager [expr { 100 * $fraction_to_wager }]
    set stake [expr { $capital * $fraction_to_wager }]
    set half_kelly_stake [expr { 0.5 * $stake }]

    set stake [expr { $stake -  fmod($stake, $betMultiple) }]
    set half_kelly_stake [expr { $half_kelly_stake -  fmod($half_kelly_stake, $betMultiple) }]

    set gain [expr { double($stake) * (double($oddsWin) / double($oddsLose)) }]
    lappend result "The odds are in your favor, but read the following carefully:"
    lappend result "* According to the Kelly criterion your optimal bet is about [format "%.2f" $percentToWager]% of your capital, or $stake."
    lappend result "* On [format "%.2f" ${percentWin}]% of similar occasions, you would expect to gain $gain in addition to your stake of $stake being returned."
    lappend result "* But on those occasions when you lose, you will lose your stake of $stake"
    lappend result "* Bets have been rounded down to the nearest multiple of $betMultiple"
    lappend result "* If you do not bet exactly $stake, you should bet less than $stake."
    lappend result "* The outcome of this bet is assumed to have no relationship to any other bet you make. "
    lappend result "* The Kelly criterion is maximally aggressive — it seeks to increase capital at the maximum rate possible. Professional gamblers typically take a less aggressive approach, and generally won't bet more than about 2.5% of their bankroll on any wager. In this case that would be [expr { 0.25 * $capital }]."
    lappend result "* A common strategy (see discussion below) is to wager half the Kelly amount, which in this case would be $half_kelly_stake."
    lappend result "* If your estimated probability of 40% is too high, you will bet too much and lose over time. Make sure you are using a conservative (low) estimate."

    lappend result "* fraction of bankroll to wager = $fraction_to_wager"
} elseif { $fraction_to_wager < 0 } {
    lappend result "The odds are against you - you should not bet"
} else {
    lappend result "f = zero = $fraction_to_wager"
}


doc_return 200 text/plain [join $result \n]