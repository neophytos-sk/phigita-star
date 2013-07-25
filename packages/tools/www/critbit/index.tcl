::xo::lib::require critbit_tree

#set libdir [acs_root_dir]/packages/tools/lib/
#source [file join $libdir critbit/tcl/module-critbit.tcl]

#source [file join $libdir critcl/tcl/module-critcl-utils.tcl



set result ""
#set tree [critbit0_create]
set tree [cbt::create $::cbt::STRING_KEYS]  
append result "\n tree=$tree"
append result "\n insert(neophytos) = [::cbt::insert $tree "neophytos"]"
append result "\n insert(the answer to the universe) = [::cbt::insert $tree "the answer to the universe"]"
append result "\n delete(neophytos) = [::cbt::delete $tree "neophytos"]"
append result "\n delete(neophytos) = [::cbt::delete $tree "neophytos"]"
append result "\n insert(abba) = [::cbt::insert $tree "abba"]"
append result "\n insert(abba) = [::cbt::insert $tree "abba"]"
append result "\n insert(abba) = [::cbt::insert $tree "abba"]"
append result "\n insert(anomaly) = [::cbt::insert $tree "anomaly"]"


foreach text {ab test hello "asdf qwerty" aba neo abba dem} {
    append result "\n contains $text = [::cbt::contains $tree $text]"
}

append result "\n contains(neophytos)=[::cbt::contains $tree "neophytos"]"
append result "\n contains(the answer to the universe)=[::cbt::contains $tree "the answer to the universe"]"

doc_return 200 text/plain $result
return

append result "\n\n ==TEST ::cbt::allprefixed=="
#set new_tree [::cbt::allprefixed $tree "the"]
set new_tree [::cbt::extend [cbt::create $::cbt::STRING_KEYS] [::cbt::allprefixed $tree "ab"]]
append result "\n new_tree contains(the answer to the universe)=[::cbt::contains $new_tree "the answer to the universe"]"
append result "\n new_tree contains(abba)=[::cbt::contains $new_tree "abba"]"
append result "\n new_tree=$new_tree"
set new_tree2 [::cbt::allprefixed $tree "a"]
append result "\n allprefixed 'a' result=$new_tree2"


#
append result "\n\n ==TESTING UpdateStringOfTree (tcl internal for new data types)=="
append result "\n tree=$tree"
append result "\n new_tree=$new_tree"


set mytree $new_tree
::cbt::insert $mytree hello
append result "\n mytree contains(hello)=[::cbt::contains $mytree hello]"
append result "\n mytree(must contain hello)=$mytree new_tree=$new_tree"


append result "\n\n ==TESTING SetTreeFromAny (tcl internal for new data types)=="

set tree2 [cbt::create]
append result "\n tree2 insert(wow)=[::cbt::insert $tree2 wow]"


set tree2 [cbt::extend [cbt::create] "hello world {another test} this is a test"]
set tree2 "hello world this is a test"
# HERE: append result "\n tree2=$tree2 contains(world)=[::cbt::contains $tree2 world] contains(another)=[::cbt::contains $tree2 another] contains(test)=[::cbt::contains $tree2 test] contains(another test)=[::cbt::contains $tree2 "another test"]"



#lappend tree2 helloworld
# perhaps the cbt_* functions should check for the objs type and convert accordingly
#append result "\n tree2=$tree2 contains(helloworld)=[::cbt::contains $tree2 helloworld]"


### WE NEED A BETTER NAME THAN ::cbt::extend FOR THIS USE CASE
set dict [cbt::extend [cbt::create] "814.fname=neophytos 814.lname=demetriou 814.dob=1977-09-27 1234.fname=John 1234.lname=smith"]
cbt::extend $dict "814.city=paphos"
append result "\n\n allprefixed {814.}=[::cbt::allprefixed $dict 814.]"
append result "\n allprefixed {1234.}=[::cbt::allprefixed $dict 1234.]"




set addresses {
    81.0.0.0 68
    81.0.64.0 21973
    81.0.72.0 49828
    81.0.74.0 21973
    81.0.74.32 56053
    81.0.74.40 50265
    81.0.74.48 21973
    81.0.74.64 55191
    81.0.74.80 50265
    81.0.74.128 2197
    81.89.4.16 50265
    81.100.74.136 50265
    81.0.74.144 21973
    81.0.74.168 50265
    81.0.74.176 21973
    81.0.74.184 50265
    81.0.74.192 59301
    81.0.74.200 50265
    81.0.74.208 21973
    81.0.74.216 50265
    81.0.74.224 21973
    81.0.74.232 50265
    81.0.74.240 21973
    81.0.75.8 50265
}

set try_bin_p "false"

set blocks ""
foreach {ip location_id} $addresses {
    if { $try_bin_p } {
	#lappend blocks [::xo::ip::to_hex $ip]=${location_id}
	lappend blocks [binary format I [ip2val $ip]]=${location_id}
    } else {
	lappend blocks $ip=${location_id}
    }
}

foreach query_ip {
    81.0.74.35
    81.0.74.235
    81.90.21.33
} {
    #set blocks_cbt [cbt_convert $blocks]
    set blocks_cbt [cbt::extend [cbt::create] $blocks]
    if { $try_bin_p } {
	set match [::cbt::prefix_match $blocks_cbt [binary format I [ip2val $query_ip]]
    } else {
	set match [::cbt::prefix_match $blocks_cbt $query_ip]
    }
    set location_id ""
    set lo_ip ""
    if { $match ne {} } {
	lassign [split $match =] lo_ip location_id
	#set lo_ip [string range $match 0 7]
	#set location_id [string range $match 9 end]
    }
    if { $try_bin_p } {
	append result "\n\n ::cbt::prefix_match blocks_cbt $query_ip: $match ([binary scan $lo_ip I res; set res] // location_id=$location_id)"
    } else {
	append result "\n\n ::cbt::prefix_match blocks_cbt $query_ip: $match ($lo_ip // location_id=$location_id)"
    }
}

#set timeres [time { set match [::cbt::prefix_match $blocks_cbt [::xo::ip::to_hex 81.0.74.35]] }]
#set timeres [time {::xo::geoip::ip_locate 81.0.74.35} 1000]
#append result "\n\n ::xo::geoip::ip_locate (without critbit_tree) took: $timeres"

#append result "\n\n[::cbt::allprefixed $blocks_cbt 81.0.74.2]"


    doc_return 200 text/html "tree=<a href=\"test?handle=${tree}\">$tree</a><br><pre>$result</pre>"
return



#### OLD STUFF

critcl::cproc test_contains {char* elem} int {
    //critbit0_tree test={0};

    critbit0_tree *tree = critbit0_NewTree();

    static const char *elems[] = {"a", "aa", "b", "bb", "ab", "ba", "aba", "bab", "asdf qwerty", NULL};
    int i;
    for (i = 0; elems[i]; ++i) critbit0_insert(tree, elems[i]);

    for (i = 0; elems[i]; ++i) 
    {
     if (!critbit0_contains(tree, elem)) return 0;
    }
    
    critbit0_FreeTree(tree);

    return 1;
}
