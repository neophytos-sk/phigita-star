#!/usr/bin/tclsh
load ../unix/libttext0.3.so

set stopwordsfile stopwords_el 
set inputfilename cluster-1_filelist

# k is (currently) the index for the threshold. We need to experiment further.
set k 40


set dataset [list]
set stopwords [list]

set fp [open ${stopwordsfile} r]
set stopwords [read ${fp}]
close ${fp}

set ofp [open ${inputfilename} r]
while {![eof ${fp}]} {
    set filename [gets ${fp}]
    if {![string equal ${filename} {}]} {
	set ifp [open ${filename} r]
	lappend dataset [read ${ifp}]
	close ${ifp}
    }
}
close ${ofp}


#set stopwords $C


######### HERE ###########
set clusters [ttext::ttext cluster ${k} ${dataset} ${stopwords}]
#
# Similarly,
#     set clusters [ttext::cluster ${k} ${dataset} ${stopwords}]
#

puts "Dataset Size: [llength ${dataset}]"
puts "Stopwords Size: [llength ${stopwords}]"
puts "Number of Clusters: [llength ${clusters}]"
puts "Clusters: ${clusters}"
