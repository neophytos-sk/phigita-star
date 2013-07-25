#! /bin/csh -f

set dir = ~/Desktop/Zdraw

# go there
cd $dir

# get date
set tdate = ` date +"%m:%d:%y:%T" `

# tar it up
set file = /tmp/zdraw-${tdate}.tgz 
echo "tarring into $file ..."
tar cvzf $file * | awk '{printf("%s ", $0)} END {print ""}'
if ($status != 0) then
    echo "tar failed."
    exit 1
endif

# send it over
echo "sending it over ..."
scp $file remzi@claudio.cs.wisc.edu:Projects/Tcl/Zdraw
if ($status != 0) then
    echo "scp failed."
    exit 1
endif

echo "transfer: done."

echo "md5sum check"
echo "local:"
md5sum $file
echo "remote:"
ssh remzi@claudio.cs.wisc.edu md5sum Projects/Tcl/Zdraw/zdraw-${tdate}.tgz 






