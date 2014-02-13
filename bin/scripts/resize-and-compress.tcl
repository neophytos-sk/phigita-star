#!/usr/bin/tclsh

set maxwidth ""
set maxheight 80

set directory /web/data/books/cover/
set filelist [glob -directory $directory s*.jpg]
set geometry ${maxwidth}x${maxheight}
foreach infile $filelist {
    set outfile [file rootname $infile]-${geometry}.jpg
    exec -- /bin/sh -c "convert -resize $geometry $infile $outfile; jpegoptim --quiet --strip-all $outfile || exit 0" 2> /dev/null
    # if { 0 == [incr count] % 1000 } puts $count
}