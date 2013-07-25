package require md5
proc randomCode {size} {
    set data [list 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N P Q R S T U V W X Y Z]
    set code [list]
    for {set n 0} {$n < $size} {incr n} {
        lappend code "[lindex $data [expr {int(rand()*[llength $data])}]] "
    }
    return [join $code ""]
}

proc genCaptcha {code} {
    set key $code
    set stamp [clock seconds]
    set hash [md5::md5 $key]
    set target [acs_root_dir]/data/captcha/$hash-$stamp.png
    exec convert -antialias -size 150x50 null: -gravity center -pointsize 24 -fill \#c0c0c0 -annotate 0 $code -blur 0 -wave 5x45 -swirl 15  png:$target
    return $target
}


set target [genCaptcha [randomCode 6]]
ad_returnfile_background 200 [ns_guesstype $target] $target

#tile:acs_root_dir]/packages/calendar/www-global/captcha_bg_2.gif