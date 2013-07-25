ad_maybe_redirect_for_registration

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

	Panel new -autoHeight true -width 700 -header true -border true -headerAsText true -style "'margin-left:auto;margin-right:auto'" -title "'Post to BBoard'" -appendFromScript {


	    Form post_form \
		-action store \
		-label "Post to BBoard" \
		-labelAlign 'top' \
		-width 700 \
		-autoHeight true \
		-style "padding:5px;margin-left:auto;margin-right:auto;" \
		-appendFromScript {

		    TextField new \
			-name title \
			-label "Posting Title" \
			-allowBlank false \
			-anchor '100%'

		    TextArea new \
			-name "content" \
			-label "Posting Description (supports structured text)" \
			-anchor '100%' \
			-height 300 \


		    ComboBox message_type -map {
			{ds0 ds} 
		    } -name "message_type" \
			-label "What type of posting is this?" \
			-store ds \
			-mode 'local' \
			-typeAhead false \
			-anchor '100%' \
			-allowBlank true \
			-displayField 'name'





		} -proc action(store) {marshaller} {
		    if { [my isValid] } {
			set mydict [my getDict]

			set user_id [ad_conn user_id]
			set peeraddr [ad_conn peeraddr]

			set id [::bboard::Message autovalue ""]
			set content_type "::bboard::Message"
			set title [dict get $mydict title]
			set content [string map {\xad ""} [dict get $mydict content]]
			set allow_comments_p f ;# [dict get $mydict allow_comments_p]
			set live_p t ;# [dict get $mydict live_p]
			# set hidden_type_id [dict get $mydict hidden_type_id]
			set message_type_id [::xo::db::getColumn main ::bboard::Message_Type id "name eq [dict get $mydict message_type]"]

			set o [::bboard::Message new -mixin ::db::Object]

			${o} set id ${id}
			${o} set title ${title}
			${o} set content ${content}
			${o} set content_type ${content_type}
			${o} set allow_comments_p ${allow_comments_p}
			${o} set live_p ${live_p}
			${o} set type_id ${message_type_id}


			$o set creation_user        $user_id
			$o set creation_ip          $peeraddr
			$o set modifying_user       $user_id
			$o set modifying_ip         $peeraddr

			${o} do self-insert

			set base .
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
