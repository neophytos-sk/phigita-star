set index [expr {int(rand()*1000)}]

set imageList [util_memoize {
	db::Set imageTaggerFileList -pool newsdb -select image_file -type ::sw::agg::Url -where [list "image_file is not null"] -order "creation_date desc" -limit 10000
	imageTaggerFileList load
	::aux::mapobj {set image_file} [imageTaggerFileList set result]
	} 600]


::tmpl::master {
	img -src images/[lindex $imageList $index]
}