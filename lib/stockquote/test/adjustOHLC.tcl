proc read_splits {} {
    set fp [open ibm-splits-clean.txt]
    set data [read $fp]
    close $fp
    return $data
}

proc read_dividends {} {
    set fp [open ibm-dividends-clean.txt]
    set data [read $fp]
    close $fp
    return $data
}


# Loop over split vectors from newest period to oldest
# Carry newer ratio value backward

puts "\nSplits (date, numerator, denominator, fraction, split_ratio, acc_split_ratio)\n"

set acc_split_ratio "1.0"
foreach p [read_splits] {
    lassign $p date split_fraction
    # 2:1 is "two for one" split
    # 1:3 is "1 for three" reverse split
    lassign [split $split_fraction {:}] denominator numerator
    set split_ratio [expr { double($numerator) / double($denominator) }]
    set acc_split_ratio [expr { $acc_split_ratio * double($split_ratio) }]
    puts [list $date $numerator $denominator $split_fraction $split_ratio $acc_split_ratio]
}

# Loop over split vectors from newest period to oldest
# Carry newer ratio value backward

puts "\nDividends\n"

set acc_dividend_ratio "1.0"
foreach p [read_dividends] {
    set close_price "1.0" ;# fictitious data - this must come from actual data
    lassign $p date dividend_ratio
    set acc_dividend_ratio [expr {$acc_dividend_ratio * (1.0 - $dividend_ratio / $close_price)}]
    puts [list $date $dividend_ratio $acc_dividend_ratio]
}