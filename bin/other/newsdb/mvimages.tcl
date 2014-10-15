puts "starting..."
cd /web/data/news/images/
set filelist [glob -nocomplain *]
puts length=[llength $filelist]
foreach filename $filelist {
    if { ![file isfile $filename] } continue
    set path /web/data/news/images/[string range $filename 0 1]
    if { ![file exists $path] } {
	file mkdir $path
    }
    file rename -force $filename ${path}/$filename
    if { [incr i] % 100 == 0 } {
	puts $i
    }
}
