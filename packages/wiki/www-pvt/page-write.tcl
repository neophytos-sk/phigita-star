#ad_maybe_redirect_for_registration
package require crc32

#source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/10-ui-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/30-form-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/32-datastore-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/32-textarea-procs.tcl


namespace path ::xo::ui 


    Page new -master "::xo::ui::DefaultMaster" -appendFromScript {

	StyleFile new -style_file [acs_root_dir]/packages/blogger/resources/css/combos.css
	StyleText new -inline_p yes -styleText {
	    .x-form-check-wrap {float:left;margin-left:4;}
	    .x-form-label-left label {text-align:right;}
	}

	Action action__getTags -name getTags -body {
	    ::xo::ns::source [acs_root_dir]/packages/blogger/www-pvt/get-tags.tcl
	}
	Action action__getImages -name getImages -body {
	    #'http://my.phigita.net/media/view/get-images'
	    ::xo::ns::source [acs_root_dir]/packages/xo-drive/tmpl-pvt/view/get-images.tcl
	}
	JsonStore ds0 \
	    -map {action__getTags} \
            -url action__getTags \
	    -proxy "new Ext.data.HttpProxy({url:action__getTags,method:'GET'})" \
            -totalProperty 'totalCount' \
            -root 'tags' \
	    -fields [::util::list2json {tagName numOccurs}]

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

	Panel new -autoHeight true -width 700 -header true -border true -headerAsText true -style "'margin-left:auto;margin-right:auto'" -title "'Write your post'" -appendFromScript {


	    Form post_form \
		-action store \
		-label "Write Post" \
		-width 700 \
		-style "padding:5px;margin-left:auto;margin-right:auto;" \
		-appendFromScript {

		    HiddenField new \
			-name id \
			-allowBlank true \
			-value [::xo::kit::queryget id]

		    TextField new \
			-name title \
			-label Title \
			-allowBlank false \
			-width 550

		    StructuredText new \
			-map {action__getImages} \
			-name "body" \
			-label "Message" \
			-width 550 \
			-height 300 \
			-get_images_proxy "new Ext.data.HttpProxy({url:action__getImages,method:'GET'})"

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


		    RadioGroup new -name allow_comments_p -value t -label "Allow New Comments on This Post" -appendFromScript {
			Radio new -label "Yes" -value t
			Radio new -label "No" -value f
		    }

		    RadioGroup new -name shared_p -value t -label "Sharing" -appendFromScript {
			Radio new -label "Public" -value t
			Radio new -label "Private" -value f
		    }


		} -proc action(store) {marshaller} {
		    if { [my isValid] } {
			set mydict [my getDict]

			if { [::xo::kit::vcheck id integer value_of_id] } {
			    set id $value_of_id
			    set data_operation "update"
			} else {
			    set id [set id [Blog_Item autovalue "User [ad_conn user_id]"]]
			    set data_operation "insert"
			}

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
			${bi} rdb.self-${data_operation}  ;# insert or update
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
			    ${mapObj} rdb.self-insert
			    ${mapObj} destroy

			}

			${bi} endTransaction

			ad_returnredirect $id
		    } else {
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



	MixinRule new -applyTo post_form -check ALL -guard {
	    { [::xo::kit::vcheck id integer] }
	} -instproc render {visitor} {


	    set id [::xo::kit::value_if id integer]
	    #set id [::xo::kit::queryget id]
	    set pathexp [list "User [ad_conn user_id]"]

	    set ds_labels [::db::Set new \
			       -pathexp $pathexp \
			       -type [::db::Inner_Join new \
					  -lhs [::db::Set new -alias m -pathexp $pathexp -type ::Blog_Item_Label_Map -where [list object_id=[ns_dbquotevalue $id]]] \
					  -rhs [::db::Set new -alias l -pathexp $pathexp -type ::Blog_Item_Label] \
					  -join_condition {m.label_id=l.id}]]
	    $ds_labels load


	    set postdata [::db::Set new \
			      -pathexp $pathexp \
			      -type ::Blog_Item \
			      -where [list "id = [ns_dbquotevalue $id]"]]
	    $postdata load
	    ns_log notice "sql=[$postdata set sql]"

	    if { [$postdata emptyset_p] } {
		rp_returnnotfound
		return
	    }

	    set o [$postdata head]

	    set tmplist ""
	    foreach label [$ds_labels set result] {
		lappend tmplist [$label set name]
	    }
	    $o set tags [join $tmplist {, }]

	    #set log_msg "post-write(edit): [$o info vars]"

	    foreach ff [my getFields] {
		#append log_msg "\nff=$ff cl=[$ff info class] name=[$ff name]"
		if { [$o exists [$ff name]] } {
		    #append log_msg " value=[::util::shortline [$o set [$ff name]] 50 20]"
		    $ff setValueTo [$o set [$ff name]]
		}
	    }
	    #ns_log notice $log_msg

	    set result [next]
	    return $result
	}



    }
