#! /bin/csh -f

set files = `cat regression.files`

foreach t ($files)
    echo "now viewing: ${t}.eps"
    gv --scale=3 Output/${t}.eps
end



