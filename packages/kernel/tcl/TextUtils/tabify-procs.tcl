proc untabify { string { num 8 } } {
    return [string map [list \t [string repeat " " $num]] $string]
}
