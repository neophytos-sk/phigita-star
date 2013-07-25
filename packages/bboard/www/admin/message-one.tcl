ad_maybe_redirect_for_registration
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

	Action action__getImages -name getImages -body {
            #'http://my.phigita.net/media/view/get-images'
            ::xo::ns::source [acs_root_dir]/packages/xo-drive/tmpl-pvt/view/get-images.tcl
        }

	Tablet ds0 \
	    -root 'root' \
	    -autoLoad true \
	    -select "id name description" \
	    -type ::bboard::Message_Type \
	    -defaultSortField name \
	    -fields [util::list2json {id name description}] \
	    -name_field_map {
		name name
	    }

	Panel new -autoHeight true -width 700 -header true -border true -headerAsText true -style "'margin-left:auto;margin-right:auto'" -title "'Write your message'" -appendFromScript {


	    Form post_form \
		-action store \
		-label "Post a message" \
		-width 700 \
		-style "padding:5px;margin-left:auto;margin-right:auto;" \
		-appendFromScript {

		    TextField new \
			-name title \
			-label Title \
			-allowBlank false \
			-width 550

		    StructuredText new \
			-map {action__getImages} \
			-name "content" \
			-label "Message" \
			-width 550 \
			-height 300 \
			-get_images_proxy "new Ext.data.HttpProxy({url:action__getImages,method:'GET'})"


		    RadioGroup new -name allow_comments_p -value t -label "Allow Comments?" -appendFromScript {
			Radio new -label "Yes" -value t
			Radio new -label "No" -value f
		    }

		    RadioGroup new -name live_p -value t -label "Status" -appendFromScript {
			Radio new -label "Enable" -value t
			Radio new -label "Disable" -value f
		    }

		    ComboBox type_id -map {
			{ds0 ds} 
		    } -name "type_id" \
			-label "Type" \
			-store ds \
			-mode 'local' \
			-typeAhead false \
			-width 560 \
			-allowBlank true \
			-displayField 'name' \
			-valueField 'id' \
			-hidden_field_p yes



		} -proc action(store) {marshaller} {
		    if { [my isValid] } {
			set mydict [my getDict]
			set user_id [ad_conn user_id]
			set peeraddr [ad_conn peeraddr]

			set id [::bboard::Message autovalue ""]
			set content_type "::bboard::Message"
			set title [dict get $mydict title]
			set content [string map {\xad ""} [dict get $mydict content]]
			set allow_comments_p [dict get $mydict allow_comments_p]
			set live_p [dict get $mydict live_p]
			set hidden_type_id [dict get $mydict hidden_type_id]

			set o [::bboard::Message new -mixin ::db::Object]

			${o} set id ${id}
			${o} set title ${title}
			${o} set content ${content}
			${o} set content_type ${content_type}
			${o} set allow_comments_p ${allow_comments_p}
			${o} set live_p ${live_p}
			${o} set type_id ${hidden_type_id}


			$o set creation_user        $user_id
			$o set creation_ip          $peeraddr
			$o set modifying_user       $user_id
			$o set modifying_ip         $peeraddr

			${o} do self-insert

			set base ..
			ad_returnredirect ${base}/message/$id
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






    }
