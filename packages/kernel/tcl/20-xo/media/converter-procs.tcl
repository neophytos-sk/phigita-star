namespace eval ::xo {;}
namespace eval ::xo::media {;}

proc ::xo::media::object_dir {user_id object_id} {
    set class_id [User set id]
    set user_dir "${class_id}-${user_id}"
    set dir "/web/data/storage/${user_dir}/${object_id}"

    # file mkdir ${dir}
    file mkdir ${dir}/preview/

    return $dir
}

# TODO: change shared_p to visible_to
proc ::xo::media::save_user_file {user_id tmpfile filename {tags ""} {shared_p "0"}} {

    set filetype  [::xo::media::file_type $tmpfile $filename]
    set content_type [::xo::media::content_type $filetype]

    #xo::kit::log "not implemented yet filetype=$filetype content_type=$content_type"
    set pathexp [list "User $user_id"]

    package require md5
    set md5sum [string tolower [::md5::md5 -hex -file $tmpfile]]


    # TODO: see xo-drive/www-pvt/index.tcl
    set data [::db::Set new \
		  -pathexp $pathexp \
		  -select {
		      id
		      {extra->'XO.File.Magic' as filetype}
		      {extra->'XO.File.Type' as content_type}
		      title
		      {extra->'XO.File.Size' as file_size} 
		      shared_p 
		      deleted_p 
		      hidden_p 
		      starred_p 
		  } -type ::Content_Item \
		  -where [list "extra->'XO.File.MD5' = [ns_dbquotevalue $md5sum]"]]
    $data load

    ns_log notice [$data set sql]

    if { ![$data emptyset_p] } {
	set o [$data head]
	set object_id [$o set id]
	if { [::xo::kit::performance_mode_p] } {
	    return [list $object_id $filetype $content_type $o]
	} else {
	    # this is development server
	    # upload file nevertheless
	}
    }



    set o [::Content_Item new -mixin "GIST_Text_Index ::db::Object" -pathexp $pathexp]

    $o setSubject id
    $o setTarget ts_vector
    $o setIndexList {
	{A db "" title}

	{B db "simple" extra->'XO.Info.title'}
	{B db "simple" extra->'XO.Info.author'}
	{B db "simple" extra->'PDF.Info.subject'}
	{B db "simple" extra->'PDF.Info.keywords'}

	{B db "" extra->'MP3.Info.Title'}
	{B db "" extra->'MP3.Info.Artist'}
	{B db "" extra->'MP3.Info.Album'}
	{B db "" extra->'MP3.Info.Genre'}
	{B db "" extra->'MP3.Info.Year'}

	{C db "" description}
	{C tcl "" document_text}

	{D db "simple" extra->'Exif.Image.Make'}
	{D db "simple" extra->'Exif.Image.Model'}
    }

    $o set document_text ""

    set rootname [file rootname $filename]
    $o set title [string tolower $rootname]
    #$o set description [dict get $mydict description]

    #$o set filetype [dict get $mydict upload_file.filetype]

    $o set tags_ia ""
    set tags_list [::xo::fun::filter [::xo::fun::map x [split $tags {,}] {string trim $x}] x {$x ne {}}]

    ### $o set tags [join [::xo::fun::filter [split [dict get $mydict tags] {,}] x {[string trim $x] ne {}}] {,}]

    $o set shared_p $shared_p ;# [dict get $mydict shared_p]

    # Auditing
    $o set creation_user [ad_conn user_id]
    $o set creation_ip [ad_conn peeraddr]
    $o set modifying_user [ad_conn user_id]
    $o set modifying_ip [ad_conn peeraddr]

    $o beginTransaction
    $o rdb.self-id


    set list [list "XO.File.Name \{${filename}\}" "XO.File.Type ${content_type}" "XO.File.Size [file size $tmpfile]" "XO.File.Magic $filetype" "XO.File.MD5 $md5sum"]
    set extension [file extension $filename]
    if { $extension ne {} } {
        lappend list "XO.File.Extension $extension"
    }

    set object_id [$o set id]
    set dir [::xo::media::object_dir $user_id $object_id]
    set previewdir ${dir}/preview/
    set original_file ${dir}/o-${object_id}

    $o set extra $list ;# [dict get $mydict upload_file.extra]
    array set extra [join [$o set extra]]

    file rename -force -- $tmpfile $original_file






    ####### prepare preview
    #ns_log notice "extra=[$o set extra]"
    #ns_log notice "XO.File.Type = $extra(XO.File.Type)"

    #    set content_type  $extra(XO.File.Type)
    set magic $extra(XO.File.Magic)
    ### DOCUMENT ###
    if { $content_type eq {document} || $content_type eq {spreadsheet} || $content_type eq {presentation} } {

	set PDFTOTEXT /opt/poppler/bin/pdftotext 

	set config [dict create original_file $original_file directory $dir previewdir $previewdir object_id $object_id magic $magic]
	set docinfo [::xo::media::process_upload=document $config]
	
	set PDFTOTEXT_INPUT "o-${object_id}"
	$o set document_text [exec -- /bin/sh -c "cd ${dir};${PDFTOTEXT} ${PDFTOTEXT_INPUT} - || exit 0" 2> /dev/null]

	$o set extra [concat [$o set extra] $docinfo]
	ns_log notice "xo-drive: docinfo=[$o set extra]"

	$o lappend indexList {D db "simple" extra->'XO.Info.title'}
	$o lappend indexList {D db "simple" extra->'XO.Info.author'}

    }

    
    ### IMAGE ###
    if { $content_type eq {image} } {
	set config [dict create original_file $original_file previewdir $previewdir object_id $object_id]
	::xo::media::process_upload=image $config
    }


    ### AUDIO ### 
    if { $content_type eq {audio} } {

	set album ""
	set artist ""
	if { [info exists extra(MP3.Info.Album)] && [info exists extra(MP3.Info.Artist)] } {
	    set album $extra(MP3.Info.Album)
	    set artist $extra(MP3.Info.Artist)
	}

	set config [dict create original_file $original_file directory $dir previewdir $previewdir object_id $object_id album $album artist $artist]
	::xo::media::process_upload=audio $config
    }


    ### VIDEO ### 
    if { $content_type eq {video} } {
	set duration $extra(XO.Info.duration)
	set config [dict create original_file $original_file directory $dir previewdir $previewdir object_id $object_id duration $duration]
	::xo::media::process_upload=video $config
	$o lappend extra $extra
    }
    ### USER DB ###

    if { -1 != [lsearch -exact $extra(XO.File.Magic) {MDB}] } {
	exec -- /bin/sh -c "/usr/bin/mdb-schema -S __dummy__ ${original_file} > ${dir}/c-${object_id}.ddl || exit 0" 2> /dev/null
	set tables [exec -- /bin/sh -c "/usr/bin/mdb-tables ${original_file}  || exit 0" 2> /dev/null]
	foreach table_name $tables {
	    exec -- /bin/sh -c "/usr/bin/mdb-export ${original_file} ${table_name} | bzip2 > ${dir}/c-${object_id}-${table_name}.csv.bz2 || exit 0" 2> /dev/null
	}
    }

    package require crc32
    ###set tags_list [::xo::fun::filter [::xo::fun::map x [split $tags {,}] {string trim $x}] x {$x ne {}}]

    set tags_ia ""
    array set tags_hash_ia [list]

    if { ${tags_list} ne {} } {

	set tags_clause ""
	foreach tag $tags_list {
	    lappend tags_clause [::util::dbquotevalue $tag]
	}
	set tags_clause ([join $tags_clause {,}])

	set ds_tags [::db::Set new \
			 -pathexp $pathexp \
			 -select [list "trim(xo__concatenate_aggregate( '{' || name || '} ' || id || ' '),', ') as tags_hash_ia"] \
			 -type ::Content_Item_Label \
			 -where [list "name in $tags_clause"]]

	$ds_tags load

	if { ![$ds_tags emptyset_p] } {
	    array set tags_hash_ia [[$ds_tags head] set tags_hash_ia]
	}
	set tags_ia ""
	foreach tag $tags_list {

	    if { [info exists __label($tag)] } {
		continue
	    } else {
		set __label($tag) ""
	    }

	    if { [info exists tags_hash_ia($tag)] } {
		lappend tags_ia $tags_hash_ia($tag)
	    } else {
		set tag_crc32 [crc::crc32 -format %d $tag]
		set lo [::Content_Item_Label new \
			    -pathexp ${pathexp} \
			    -mixin ::db::Object \
			    -name ${tag} \
			    -name_crc32 ${tag_crc32}]

		$lo rdb.self-insert {select true;}
		set lo_id [[${lo} getConn] getvalue "select id from [${lo} info.db.table] where name=[::util::dbquotevalue ${tag}]"]
		lappend tags_ia $lo_id
	    }
	}

    }

    if { $tags_ia ne {} } {
	$o set tags_ia \{[join $tags_ia {,}]\}
    }




    $o rdb.self-insert


    #source [acs_root_dir]/packages/persistence/pdl/33-content-item.tcl
    set part [::Content_Item_Part new \
		  -mixin "GIST_Text_Index ::db::Object" \
		  -pathexp $pathexp \
		  -item_id [$o set id]]

    $part setTarget ts_vector
    $part setSubject {item_id part_index}
    $part setIndexList {
	{B db "" part_text}
    }

    # split \x0c = ^L = form feed
    set part_index 1
    foreach part_text [split [$o set document_text] "\x0c"] {
	if { $part_text ne {} } {
	    $part set part_index $part_index
	    $part set part_text $part_text
	    $part rdb.self-insert
	}
	incr part_index
    }


    $o endTransaction



    #ns_return 200 text/html [::util::map2json b:success true]


    return [list $object_id $filetype $content_type $o]
}

proc ::xo::media::file_type {tmpfile filename} {
    return [__FILE_MANAGER__ identify $tmpfile $filename]
}

proc ::xo::media::content_type {filetype} {
    set result ""
    switch -exact -- $filetype {
	PS -
	PDF  -
	DOCX -
	DOC  -
	ODW  -
	ODT  -
	SXW  -
	SXD  -
	DJVU { set result "document" }

	XLSX -
	XLS -
	ODC -
	SXC {set result "spreadsheet" }

	PPTX -
	PPT  -
	ODI  -
	SXI  { set result "presentation" }

	GIF  - 
	BMP  -
	PNG  -
	TIFF -
	JPEG { set result "image" }

	MID  -
	WAV  -
	MP2  -
	MP3  { set result "audio" }

	WMV  -
	MOV  { set result "video" }

	ZIP { set result "archive" }

	default {set result other }
    }
    return $result
}

proc ::xo::media::gen_doc_preview {infile outfile {dpi 120}} {
    set GS "/usr/bin/gs"
    set cmd "${GS} -q -dQUIET -dSAFER -dPARANOIDSAFE -dBATCH -dNOPAUSE -dNOPROMPT -dAlignToPixels=0 -dGridFitTT=0 \"-sDEVICE=png16m\" -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -r${dpi} -dFirstPage=1 -dLastPage=1 \"-sOutputFile=${outfile}\" \"${infile}\""
    ns_log notice "gen_doc_preview: cmd=$cmd"
    exec -- /bin/sh -c "${cmd} || exit 0" 2> /dev/null
}


proc ::xo::media::scale_image {geometry infile outfile} {
    set cmd "/usr/bin/convert -quiet -strip -scale $geometry  ${infile} ${outfile}"
    ns_log notice "scale_image cmd=$cmd"
    exec -- /bin/sh -c "$cmd || exit 0" 2> /dev/null
}

proc ::xo::media::optimize_image {infile {optimization_level "7"}} {
    set cmd "/usr/bin/optipng -q -k -o${optimization_level} $infile"
    exec -- /bin/sh -c "$cmd || exit 0" 2> /dev/null
}

proc ::xo::media::ooo_to_pdf {infile outfile informat outformat} {
    set ooo_converter "[acs_root_dir]/scripts/ooo-converter.sh"    
    set cmd "$ooo_converter $infile $outfile $informat $outformat"
    exec -- /bin/sh -c "$cmd || exit 0" 2> /dev/null
}

proc ::xo::media::embed_video {video_id {fetch_p "false"}} {
    lassign [::xo::buzz::getVideo $video_id $fetch_p] found_p vo
    if { !$found_p } {
	div -style "color:red" { t "<video clip not found>" }
	return
    }
    ::xo::buzz::videoEmbed $video_id $vo
}

proc ::xo::media::pdfinfo {directory PDFINFO_INPUT} {
    set PDFINFO /opt/poppler/bin/pdfinfo
    set extra ""
    set pdf_info [exec -- /bin/sh -c "cd ${directory};${PDFINFO} ${PDFINFO_INPUT} || exit 0" 2> /dev/null]
    foreach line [split $pdf_info \n] {
	set index [string first ":" $line]
	set key [string range $line 0 [expr { -1+$index }]]
	set value [string range $line [expr { 1+$index }] end]
	lappend extra [list XO.Info.[string map {" " _} [string tolower [string trim $key]]] [string trim $value]]
    }
    return $extra
}

proc ::xo::media::process_upload=document {config} {
    set ooo_converter [acs_root_dir]/scripts/ooo-converter.sh
    set odf_converter /opt/OdfConverter/bin/OdfConverter
    set PSTOPDF /usr/bin/ps2pdf
    set PDFTOHTML /opt/poppler/bin/pdftohtml
    set DJVUTOPDF /usr/bin/ddjvu



    dict with config {
	if { $magic ne {PDF} } {
	    if { $magic eq {PS} } {
		exec -- /bin/sh -c "cd ${directory};${PSTOPDF} o-${object_id} c-${object_id}.pdf || exit 0" 2> /dev/null
	    } elseif { $magic eq {DJVU} } {
		# quality specifies a JPEG quantization factor ranging from 25 to 150
		set factor 80
		exec -- /bin/sh -c "cd ${directory};${DJVUTOPDF} -format=pdf -quality=${factor} o-${object_id} c-${object_id}.pdf"
		#exec -- /bin/sh -c "cd ${directory};${DJVUTOPS} o-${object_id} tmp-${object_id}.ps"
		#exec -- /bin/sh -c "cd ${directory};${PSTOPDF} tmp-${object_id}.ps c-${object_id}.pdf || exit 0" 2> /dev/null
		### HERE: HUGE FILE: 100MB file remove [file join ${directory} tmp-${object_id}.ps]
	    } elseif { $magic eq {DOCX} || $magic eq {XLSX} || $magic eq {PPTX} } {
		exec -- /bin/sh -c "cd ${directory};${odf_converter} /I o-${object_id} /O c-${object_id}.odt /LEVEL 4 /DOCX2ODT || exit 0" 2> /dev/null
		exec -- /bin/sh -c "${ooo_converter} ${directory}/c-${object_id}.odt ${directory}/c-${object_id}.pdf odt pdf || exit 0" 2> /dev/null
	    } else {
		::xo::media::ooo_to_pdf ${original_file} ${directory}/c-${object_id}.pdf [string tolower $magic] pdf
	    }

	    set PDFTOTEXT_INPUT c-${object_id}.pdf
	    set PDFTOXML_INPUT c-${object_id}.pdf
	    set PDFINFO_INPUT c-${object_id}.pdf

	} else {

	    exec -- /bin/sh -c "/usr/bin/ps2pdf14 ${original_file} ${directory}/c-${object_id}.pdf || cd ${directory};ln -sf o-${object_id} c-${object_id}.pdf || exit 0" 2> /dev/null

	    set PDFTOTEXT_INPUT o-${object_id}
	    set PDFTOXML_INPUT o-${object_id}
	    set PDFINFO_INPUT o-${object_id}

	}


	#r72  - fastest
	#r96
	#r120 - default
	#r150
	#r300 - best quality
	set outfile ${previewdir}/c-${object_id}_p-1.png
	set infile ${directory}/c-${object_id}.pdf
	::xo::media::gen_doc_preview $infile $outfile

	### djvused o-1601 -e 'output-all' | bzip2 > c-1601.dsed.bz2
	exec -- /bin/sh -c "cd ${directory};${PDFTOHTML} -enc UTF-8 -zoom '1.0' -noframes -stdout -xml -nomerge -nodrm ${PDFTOXML_INPUT} | bzip2 > c-${object_id}.xml.bz2 || exit 0" 2> /dev/null

	foreach border_size {1 1 1 1} max_image_size {120 240 500 800} pointsize {4 5 7 8} {
	    set geometry ${max_image_size}x ;# ${max_image_size}
	    set pages [glob -nocomplain ${previewdir}/*.png]
	    foreach page_file $pages {
		set target_file [file rootname $page_file]-s${max_image_size}.jpg
		#-gravity SouthEast -font /web/data/fonts/cour.ttf -pointsize $pointsize -fill \"\#666666\" -draw \"text 1,1 'www.phigita.net'\"
		::xo::media::scale_image ${geometry} png:${page_file} jpg:${target_file}
		#### optipng OR optijpg
	    }
	}
	
	set extra [::xo::media::pdfinfo ${directory} ${PDFINFO_INPUT}]

    }
    return $extra
}

proc ::xo::media::process_upload=image {config} {
    dict with config {
	set i 0
	set outputformat jpg
	foreach border_size {0 1 2 3 5 5} image_size {75 120 240 500 800 1000} pointsize {3 4 5 6 7 7} {
	    
	    set target_file ${previewdir}/c-${object_id}_p-1-s${image_size}.${outputformat}
	    
	    incr image_size [expr {-2*$border_size}]
	    set geometry ${image_size}x${image_size}
	    set border_geometry ${border_size}x${border_size}
	    
	    exec -- /bin/sh -c "/usr/bin/convert -strip -shave 3x3 -scale $geometry -bordercolor black -border ${border_geometry} -gravity SouthEast -font /web/data/fonts/trebuc.ttf -pointsize $pointsize -fill \"\#e0e0e0\" -draw \"text 1,1 'www.phigita.net'\" ${original_file} ${outputformat}:$target_file || exit 0" 2> /dev/null
	    incr i
	}
    }
}


proc ::xo::media::process_upload=audio {config} {
    dict with config {
	exec -- /bin/sh -c "/usr/bin/ffmpeg -i ${original_file} -f mp3 -ar 22050 -ab 56k -acodec mp3 -ac 1 -y ${directory}/${object_id}.mp3 || exit 0" 2> /dev/null

	set targetFile ${directory}/cover-${object_id}.jpg

	if { $album ne {} && $artist ne {} } {
	    set keywords [ns_urlencode [string trim "$album $artist"]]
	    
	    if { $keywords ne {} } {
		set url "http://webservices.amazon.co.uk/onca/xml?Service=AWSECommerceService&AWSAccessKeyId=0NK019CD48HNEDK3PBG2&Operation=ItemSearch&SearchIndex=Music&ResponseGroup=Small,Images&Keywords=${keywords}"
		set curl [xo::comm::CurlHandle new -url $url -volatile]
		$curl perform
		set image_url ""
		regexp -- {<LargeImage><URL>(http://[^\<]+.jpg)</URL>} [set ${curl}::curlResponseBody] _dummy_ image_url
		exec -- /bin/sh -c "wget -O ${targetFile} $image_url || exit 0" 2> /dev/null

		set outputformat jpg
		foreach image_size {75 120 240 500} {
		    
		    set target_file ${previewdir}/c-${object_id}_p-1-s${image_size}.${outputformat}
		    
		    set geometry ${image_size}x${image_size}
		    
		    exec -- /bin/sh -c "/usr/bin/convert -strip -scale $geometry ${targetFile} ${outputformat}:$target_file || exit 0" 2> /dev/null
		    incr i
		}
	    }
	}
    }
}

proc ::xo::media::process_upload=video {config} {
    dict with config {
	exec -- /bin/sh -c "/usr/bin/ffmpeg -i ${original_file} -f flv -ar 22050 -ab 56k -aspect 4:3 -b 200k -r 12 -f flv -s 320x240 -acodec mp3 -ac 1 -g 12 -y ${directory}/${object_id}-tmp.flv || exit 0" 2> /dev/null
	exec -- /bin/sh -c "/opt/yamdi/yamdi -l -i ${directory}/${object_id}-tmp.flv -o ${directory}/c-${object_id}.flv || exit 0" 2> /dev/null
	#		    exec -- /bin/sh -c "/usr/bin/ffmpeg -i ${original_file} -an -ss 00:00:04 -r 1 -vframes 1 -s 110x80 ${directory}/frame-%d.png || exit 0" 2> /dev/null

	set i 1
	set skip_secs 4
	set number_of_frames 8
	set duration_secs [::util::duration_to_secs $duration]
	set step_secs [expr {int($duration_secs / $number_of_frames) }]
	while { $skip_secs < $duration_secs } {
	    set ss [::util::timefmt $skip_secs]
	    exec -- /bin/sh -c "/usr/bin/ffmpeg -i ${directory}/c-${object_id}.flv -an -ss $ss -r 1 -vframes 1 ${previewdir}/c-${object_id}_frame-%d.png || exit 0" 2> /dev/null
	    file rename ${previewdir}/c-${object_id}_frame-1.png ${previewdir}/c-${object_id}_p-${i}.png
	    ns_log notice "ss=$ss skip_secs=$skip_secs step_secs=$step_secs"
	    incr skip_secs $step_secs
	    incr i
	}

	set outputformat jpg
	foreach border_size {1 2} max_image_size {120 240} pointsize {4 5} {
	    
	    set image_size [expr {$max_image_size -2*$border_size}]
	    set geometry ${image_size}x${image_size}
	    set border_geometry ${border_size}x${border_size}

	    set frames [glob -nocomplain ${previewdir}/*.png]
	    foreach frame_file $frames {
		set target_file [file rootname $frame_file]-s${max_image_size}.${outputformat}
		exec -- /bin/sh -c "/usr/bin/convert -strip -shave 3x3 -scale $geometry -bordercolor black -border ${border_geometry} -gravity SouthEast -font /web/data/fonts/trebuc.ttf -pointsize $pointsize -fill \"\#e0e0e0\" -draw \"text 1,1 'www.phigita.net'\" ${frame_file} ${outputformat}:${target_file} || exit 0" 2> /dev/null
	    }
	}
    }
    return [list XO.Info.number_of_preview_frames [llength $frames]]
}





namespace eval ::xo::html {;}

proc ::xo::html::wrap_dom_script {script} {
    require_html_procs
    dom createDocument div doc
    if { [catch {
	uplevel [list $doc appendFromScript $script]
    } errmsg] } {
	ns_log notice "errmsg=$errmsg"
    }
    return [$doc asHTML]
}
