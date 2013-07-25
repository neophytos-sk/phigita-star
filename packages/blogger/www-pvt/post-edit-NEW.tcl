ad_page_contract {

    @author Neophytos Demetriou

} {
    id:integer,notnull
}

set pathexp [list "User [ad_conn user_id]"]
set postdata [::db::Set new \
		  -pathexp $pathexp \
		  -type ::Blog_Item \
		  -where [list "id = [ns_dbquotevalue $id]"]]
$postdata load
[$postdata head] move post



#source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/30-form-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/32-textarea-procs.tcl


namespace eval ::xo::ui {

    Page new -appendFromScript {

	StyleFile new -style_file [acs_root_dir]/packages/blogger/resources/css/combos.css

	JsonStore ds0 \
            -url 'http://my.phigita.net/blog/get-tags' \
            -totalProperty 'totalCount' \
            -root 'tags' \
	    -fields [subst -nobackslashes {
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

	Form new -action store -style "width:700px;" -appendFromScript {

	    TextField new \
		-name title \
		-label Subject \
		-allowBlank false \
		-width 550 \
		-value [post set title]

	    StructuredText new \
		-name "body" \
		-label "Message" \
		-width 550 \
		-height 300 \
		-get_images_url 'http://my.phigita.net/media/view/get-images' \
		-value [post set body]

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


	    RadioList new -name allow_comments_p -label "Allow New Comments on This Post" -appendFromScript {
		if { [post set allow_comments_p] } {
		    Option new -label "Yes" -value t -checked_p true
		    Option new -label "No" -value f
		} else {
		    Option new -label "Yes" -value t
		    Option new -label "No" -value f -checked_p true
		}
	    }

	    RadioList new -name shared_p -label "Sharing" -appendFromScript {
		if { [post set shared_p] } {
		    Option new -label "Yes" -value t -checked_p true
		    Option new -label "No" -value f
		} else {
		    Option new -label "Yes" -value t
		    Option new -label "No" -value f -checked_p true
		}
	    }


	} -proc action(store) {} {
	    if { [my isValid] } {
		set mydict [my getDict]


		set id [set id [Blog_Item autovalue "User [ad_conn user_id]"]]

		set title [dict get $mydict title]
		set body [string map {\xad ""} [dict get $mydict body]]
		set tags [string trim [string range [dict get $mydict tags] 0 255] {, }]
		set shared_p [dict get $mydict shared_p]
		set allow_comments_p [dict get $mydict allow_comments_p]

		set pathexp [list "User [ad_conn user_id]"]
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

		    set mapObj [Blog_Item_Label_Map new -volatile -pathexp ${pathexp} -mixin ::db::Object]
		    ${mapObj} set object_id ${id}
		    ${mapObj} set label_id ${lo_id}
		    ${mapObj} set id ${id}
		    ${mapObj} rdb.self-insert
		    ${mapObj} destroy

		}

		${bi} endTransaction

		ad_returnredirect $id
	    } else {
		doc_return 200 text/plain "Incomplete or Invalid Form"
	    }
	}

    }
}