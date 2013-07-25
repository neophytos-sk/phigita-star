namespace path ::xo::ui


Action action__getTags -name getTags -body {
    ::xo::ns::source [acs_root_dir]/packages/xo-drive/www-pvt/get-tags.tcl
}

JsonStore ds01 \
    -map {action__getTags} \
    -url action__getTags \
    -proxy "new Ext.data.HttpProxy({url:action__getTags,method:'GET'})" \
    -totalProperty 'totalCount' \
    -root 'tags' \
    -fields [util::list2json {tagName numOccurs}]

Template tpl0_search -html {
    <tpl for="."><div class="search-item">
    <h3><span>{numOccurs} entries</span>{tagName}</h3>
    </div></tpl>
}

JS.Function removeDuplicates -argv {arr} -body {
    var result = new Array(0);
    var seen = {};
    for (var i=0; i<arr.length; i++) {
				      if (!seen[arr[i]]) {
					  result.length += 1;
					  result[result.length-1] = arr[i];
				      }
				      seen[arr[i]] = true;
				  }
    return result
}

JS.Function tagSelectFn -map {tags setCaretToEnd removeDuplicates} -argv {record} -body {
    var oldValueArray = tags.getValue().split(',');
    oldValueArray[oldValueArray.length-1] = record.get('tagName');
    var newValueArray = new Array();
    for (var i=0; i<oldValueArray.length;i++) {
					       newValueArray[i]=oldValueArray[i].trim();
					   }
    var newValue=removeDuplicates(newValueArray).join(', ') + ', ';
    tags.setValue(newValue);
    setCaretToEnd(tags);
    tags.collapse();
}

JS.Function setCaretToEnd -argv {el} -body {
    var length=el.getRawValue().length;
    el.selectText(length,length);
}

Form new \
    -monitorValid true \
    -monitorPoll 100 \
    -action store \
    -label "Upload" \
    -appendFromScript {


	FileField upload_file \
	    -name upload_file \
	    -label "File"

	ComboBox tags -map {
	    {ds01 ds} 
	    {tpl0_search resultTpl} 
	    tagSelectFn
	} -name "tags" \
	    -label "Tags" \
	    -store ds \
	    -typeAhead false \
	    -width 460 \
	    -hideTrigger true \
	    -tpl resultTpl \
	    -queryParam 'q' \
	    -itemSelector 'div.search-item' \
	    -onSelect tagSelectFn \
	    -allowBlank true \
	    -minChars 0

	RadioGroup new -name shared_p -label "Access Control" -appendFromScript {
	    Radio new -label "Private" -value f -checked true
	    Radio new -label "Public" -value t
	}


    } -proc action(store) {marshaller} {
	if { [my isValid] } {

	    set mydict [my getDict]

	    
	    set pathexp [list "User [ad_conn user_id]"]
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

	    $o set title [string tolower [file rootname [dict get $mydict upload_file]]]
	    #$o set description [dict get $mydict description]
	    #$o set filetype [dict get $mydict upload_file.filetype]
	    $o set tags_ia ""
	    set tags_list [::xo::fun::filter [::xo::fun::map x [split [dict get $mydict tags] {,}] {string trim $x}] x {$x ne {}}]

	    ### $o set tags [join [::xo::fun::filter [split [dict get $mydict tags] {,}] x {[string trim $x] ne {}}] {,}]

	    $o set shared_p [dict get $mydict shared_p]

	    $o set extra [dict get $mydict upload_file.extra]

	    #		$o set translation [dict get $mydict upload_file.translation]


	    # Auditing
	    $o set creation_user [ad_conn user_id]
	    $o set creation_ip [ad_conn peeraddr]
	    $o set modifying_user [ad_conn user_id]
	    $o set modifying_ip [ad_conn peeraddr]


	    $o beginTransaction
	    $o rdb.self-id



	    set list ""
	    foreach item $pathexp {
		foreach {className instance_id} $item break
		lappend list [$className set id]-${instance_id}
	    }

	    set object_id [$o set id]
	    set directory /web/data/storage/
	    append directory [join $list .]/ ;# [User set id]-[ad_conn user_id]
	    append directory $object_id

	    set upload_file [ns_queryget upload_file]

	    set original_file ${directory}/o-${object_id}

	    file mkdir ${directory}
	    file mkdir ${directory}/preview/
	    set previewdir ${directory}/preview/

	    file rename -force -- [ns_queryget upload_file.tmpfile] ${directory}/o-${object_id}

	    set ooo_converter [acs_root_dir]/scripts/ooo-converter.sh
	    set odf_converter /opt/OdfConverter/bin/OdfConverter

	    set PDFTOTEXT /opt/poppler/bin/pdftotext 
	    set PDFTOHTML /opt/poppler/bin/pdftohtml
	    set PDFINFO /opt/poppler/bin/pdfinfo
	    set PSTOPDF /usr/bin/ps2pdf


	    set GS /usr/bin/gs

	    ####### prepare preview
	    #ns_log notice "extra=[$o set extra]"
	    array set extra [join [$o set extra]]
	    #ns_log notice "XO.File.Type = $extra(XO.File.Type)"

	    set filetype  $extra(XO.File.Type)
	    set magic $extra(XO.File.Magic)

	    ### DOCUMENT ###
	    if { $filetype eq {document} || $filetype eq {spreadsheet} || $filetype eq {presentation} } {
		if { $magic ne {PDF} } {
		    if { $magic eq {PS} } {
			exec -- /bin/sh -c "cd ${directory};${PSTOPDF} o-${object_id} c-${object_id}.pdf || exit 0" 2> /dev/null
		    } elseif { $magic eq {DOCX} || $magic eq {XLSX} || $magic eq {PPTX} } {
			exec -- /bin/sh -c "cd ${directory};${odf_converter} /I o-${object_id} /O c-${object_id}.odt /LEVEL 4 /DOCX2ODT || exit 0" 2> /dev/null
			exec -- /bin/sh -c "${ooo_converter} ${directory}/c-${object_id}.odt ${directory}/c-${object_id}.pdf odt pdf || exit 0" 2> /dev/null
		    } else {
			exec -- /bin/sh -c "$ooo_converter ${original_file} ${directory}/c-${object_id}.pdf [string tolower $magic] pdf || exit 0" 2> /dev/null
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
		set dpi 120
		exec -- /bin/sh -c "${GS} -q -dQUIET -dSAFER -dPARANOIDSAFE -dBATCH -dNOPAUSE -dNOPROMPT -dAlignToPixels=0 -dGridFitTT=0 \"-sDEVICE=png16m\" -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -r${dpi} -dFirstPage=1 -dLastPage=1 \"-sOutputFile=${previewdir}/c-${object_id}_p-1.png\" \"${directory}/c-${object_id}.pdf\" || exit 0" 2> /dev/null

		$o set document_text [exec -- /bin/sh -c "cd ${directory};${PDFTOTEXT} ${PDFTOTEXT_INPUT} - || exit 0" 2> /dev/null]


		exec -- /bin/sh -c "cd ${directory};${PDFTOHTML} -enc UTF-8 -zoom '1.0' -noframes -stdout -xml -nomerge -nodrm ${PDFTOXML_INPUT} | bzip2 > c-${object_id}.xml.bz2 || exit 0" 2> /dev/null


		foreach border_size {1 1 1 1} max_image_size {120 240 500 800} pointsize {4 5 7 8} {
		    
		    
		    #set image_size [expr {$max_image_size -2*$border_size}]
		    #set geometry ${image_size}x${image_size}
		    #set border_geometry ${border_size}x${border_size}
		    #-bordercolor black -border ${border_geometry}

		    set geometry ${max_image_size}x${max_image_size}
		    set pages [glob -nocomplain ${previewdir}/*.png]

		    foreach page_file $pages {
			set target_file [file rootname $page_file]-s${max_image_size}.jpg
			#-gravity SouthEast -font /web/data/fonts/cour.ttf -pointsize $pointsize -fill \"\#666666\" -draw \"text 1,1 'www.phigita.net'\"
			exec -- /bin/sh -c "/usr/bin/convert -quiet -strip -scale $geometry  png:${page_file} jpg:$target_file || exit 0" 2> /dev/null
		    }

		    set pdf_info [exec -- /bin/sh -c "cd ${directory};${PDFINFO} ${PDFINFO_INPUT} || exit 0" 2> /dev/null]
		    foreach line [split $pdf_info \n] {
			set index [string first ":" $line]
			set key [string range $line 0 [expr { -1+$index }]]
			set value [string range $line [expr { 1+$index }] end]
			$o lappend extra [list XO.Info.[string map {" " _} [string tolower [string trim $key]]] [string trim $value]]
		    }

		    $o lappend indexList {D db "simple" extra->'XO.Info.title'}
		    $o lappend indexList {D db "simple" extra->'XO.Info.author'}

		}
	    }

	    
	    ### IMAGE ###
	    if { $filetype eq {image} } {
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


	    ### AUDIO ### 
	    if { $filetype eq {audio} } {
		exec -- /bin/sh -c "/usr/bin/ffmpeg -i ${original_file} -f mp3 -ar 22050 -ab 56k -acodec mp3 -ac 1 -y ${directory}/${object_id}.mp3 || exit 0" 2> /dev/null

		set targetFile ${directory}/cover-${object_id}.jpg

		if { [info exists extra(MP3.Info.Album)] && [info exists extra(MP3.Info.Artist)] } {
		    set album $extra(MP3.Info.Album)
		    set artist $extra(MP3.Info.Artist)
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


	    ### VIDEO ### 
	    if { $filetype eq {video} } {
		exec -- /bin/sh -c "/usr/bin/ffmpeg -i ${original_file} -f flv -ar 22050 -ab 56k -aspect 4:3 -b 200k -r 12 -f flv -s 320x240 -acodec mp3 -ac 1 -g 12 -y ${directory}/${object_id}-tmp.flv || exit 0" 2> /dev/null
		exec -- /bin/sh -c "/opt/yamdi/yamdi -l -i ${directory}/${object_id}-tmp.flv -o ${directory}/c-${object_id}.flv || exit 0" 2> /dev/null
		#		    exec -- /bin/sh -c "/usr/bin/ffmpeg -i ${original_file} -an -ss 00:00:04 -r 1 -vframes 1 -s 110x80 ${directory}/frame-%d.png || exit 0" 2> /dev/null

		set i 1
		set skip_secs 4
		set number_of_frames 8
		set duration_secs [::util::duration_to_secs $extra(XO.Info.duration)]
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
		    $o lappend extra [list XO.Info.number_of_preview_frames [llength $frames]]

		}

	    }


	    ### USER DB ###

	    if { -1 != [lsearch -exact $extra(XO.File.Magic) {MDB}] } {
		exec -- /bin/sh -c "/usr/bin/mdb-schema -S __dummy__ ${original_file} > ${directory}/c-${object_id}.ddl || exit 0" 2> /dev/null
		set tables [exec -- /bin/sh -c "/usr/bin/mdb-tables ${original_file}  || exit 0" 2> /dev/null]
		foreach table_name $tables {
		    exec -- /bin/sh -c "/usr/bin/mdb-export ${original_file} ${table_name} | bzip2 > ${directory}/c-${object_id}-${table_name}.csv.bz2 || exit 0" 2> /dev/null
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



	    ad_returnredirect "."


	} else {

	    foreach o [my set __childNodes(__FORM_FIELD__)] {
		$o set value [$o getRawValue]
		if { ![$o isValid] } {
                    $o set markInvalid "Invalid"
		}
	    }

	    $marshaller go -select "" -action draw


	}
    }

