if [ $# -lt 3 ]; then
    echo "$0 oldfile newfile new-patch"
else
    OLDFILE=$1
    NEWFILE=$2
    PATCHFILE=$3
    diff -Naur $OLDFILE $NEWFILE > $PATCHFILE
fi


