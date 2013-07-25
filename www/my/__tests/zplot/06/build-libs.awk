# awk

($1 != "source") {
    print $0;
}

($1 == "source") {
    print "";
    print "    # begin including", $2;
    e = "cat "$2" | awk '{print \"   \", $0}'";
    system(e);
    print "    # end including", $2;
}
