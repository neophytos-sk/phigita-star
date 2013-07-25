#! /bin/csh -f

set f = $argv[1]

# awk '($1 != "source") && (NF>0) {printf("echo %s", $0);} ($1 == "source") && (NF==2) { print "cat", $2; echo ""; echo ""; }' $f > /tmp/x
# chmod +x /tmp/x
# /tmp/x




