#! /bin/csh -f

set dir = $argv[1]

set files = `awk '($1 == "source") {print $2}' libs.tcl `

echo "source: $files"

foreach f ($files) 
    echo "diff: $f"
    if (-f $f) then
	if (-f $dir/$f) then
	    diff $f $dir/$f
	else
	    echo "$dir/${f}: does not exist"
	endif
    else
	echo "${f}: does not exist"
    endif
end



