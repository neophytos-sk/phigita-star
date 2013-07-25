#ad_maybe_redirect_for_registration
package require crc32

#source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/30-form-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/32-textarea-procs.tcl

namespace inscope ::xo::ui {

    set COMMENT {
	Class TestTemplate -instproc render {visitor} {
	    $visitor ensureNodeCmd elementNode div
	    set node [div -class helloworld {
	    t "hello world"
	    }]
	    return $node
	}
    }

    Page new -master "::xo::ui::DefaultMaster" -appendFromScript {

	StyleFile new -style_file [acs_root_dir]/packages/blogger/resources/css/combos.css
	StyleText new -inline_p yes -styleText {
	    .x-form-check-wrap {float:left;margin-left:4;}
	}

	JsonStore ds0 \
            -url 'get-tags' \
            -totalProperty 'totalCount' \
            -root 'tags' \
	    -store_fields [subst -nobackslashes {
                'tagName' 'numOccurs'
	    }]

        Template tpl0 -html {
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
	    -action update \
	    -label "Write Post" \
	    -style "width:700px;margin-left:auto;margin-right:auto;" \
	    -appendFromScript {

		TextField new \
		    -name title \
		    -label Title \
		    -allowBlank false \
		    -width 550

		StructuredText new \
		    -name "body" \
		    -label "Message" \
		    -width 550 \
		    -height 300 \
		    -get_images_url 'http://my.phigita.net/media/view/get-images'

		ComboBox tags -map {
		    {ds0 ds} 
		    {tpl0 resultTpl} 
		    tagSelectFn
		} -name "tags" \
		    -label "Tags" \
		    -store ds \
		    -typeAhead false \
		    -width 560 \
		    -hideTrigger true \
		    -tpl resultTpl \
		    -queryParam 'q' \
		    -itemSelector 'div.search-item' \
		    -onSelect tagSelectFn \
		    -allowBlank true \
		    -minChars 0


		RadioGroup new -name allow_comments_p -label "Allow New Comments on This Post" -appendFromScript {
		    Radio new -label "Yes" -value t -checked true
		    Radio new -label "No" -value f
		}

		RadioGroup new -name shared_p -label "Sharing" -appendFromScript {
		    Radio new -label "Public" -value t -checked true
		    Radio new -label "Private" -value f
		}
	    
	    } -proc render {visitor} {
		set user_id [ad_conn user_id]
		set id [ns_queryget id]
		set pathexp [list "User ${user_id}"]
		set ds [::db::Set new \
			    -pathexp ${pathexp} \
			    -type ::Blog_Item \
			    -select "title body allow_comments_p shared_p" \
			    -where [list "id=[ns_dbquotevalue $id]"]]
		$ds load
		set postdata [$ds head]
		my initFromDict [dict create title [$postdata set title] body [$postdata set body] allow_comments_p [$postdata set allow_comments_p] shared_p [$postdata set shared_p]]

		return [next]

	    } -proc action(update) {marshaller} {
	    if { [my isValid] } {
		set mydict [my getDict]
		set user_id [ad_conn user_id]
		set id [ns_queryget id]
		set title [dict get $mydict title]
		set body [string map {\xad ""} [dict get $mydict body]]
		set tags [string trim [string range [dict get $mydict tags] 0 255] {, }]
		set shared_p [dict get $mydict shared_p]
		set allow_comments_p [dict get $mydict allow_comments_p]

		set pathexp [list "User ${user_id}"]
		set bi [Blog_Item new -mixin ::db::Object -pathexp ${pathexp}]

		${bi} set id ${id}
		${bi} set title ${title}
		${bi} set body ${body}
		${bi} set shared_p ${shared_p}
		${bi} set allow_comments_p ${allow_comments_p}

		${bi} beginTransaction
		${bi} rdb.self-insert
		set conn [${bi} getConn]
		foreach name [split $tags {,}] {
		    set name [string trim $name]
		    set name_crc32 [crc::crc32 -format %d ${name}]

		    if { [info exists __label($name)] } {
			continue
		    } else {
			set __label($name) true
		    }

		    set lo [::Blog_Item_Label new \
				-pathexp ${pathexp} \
				-mixin ::db::Object \
				-name ${name} \
				-name_crc32 ${name_crc32}]

		    $lo rdb.self-insert {select true;}
		    set lo_id [${conn} getvalue "select id from [${lo} info.db.table] where name=[::util::dbquotevalue ${name}]"]

		    set mapObj [Blog_Item_Label_Map new -pathexp ${pathexp} -mixin ::db::Object]
		    ${mapObj} set object_id ${id}
		    ${mapObj} set label_id ${lo_id}
		    ${mapObj} set id ${id}
		    ${mapObj} rdb.self-insert {select true;}
		    ${mapObj} destroy

		}

		${bi} endTransaction

		ad_returnredirect $id
	    } else {
		ns_log notice mydict=[my getDict]
		foreach o [my getFields] {
		    $o set value [$o getRawValue]
		    if { ![$o isValid] } {
                    $o set markInvalid "Invalid"
		    }
		}

		$marshaller go -select "" -action draw


	    }
	}

    }
}