#ad_maybe_redirect_for_registration
#package require crc32

#source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/30-form-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/32-textarea-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/35-captcha-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/40-panel-procs.tcl
#source [acs_root_dir]/packages/persistence/tcl/ZZ-tablet-procs.tcl



namespace path {::xo::ui ::template}

Page new -master ::xo::ui::DefaultMaster  -appendFromScript {

    #StyleFile new -style_file [acs_root_dir]/packages/blogger/resources/css/combos.css
    StyleText new -inline_p yes -styleText {
	img.z-form-trigger-add{
	    width:17px;
	    height:21px;
	    background:transparent url(http://www.phigita.net/graphics/icons/add.png) no-repeat 0 0 !important;
	    cursor:pointer;
	    border:0 !important;
	    position:absolute;
	    top:0;
	}
	.fl {color:#7777CC;} 
    }

	Panel new -autoHeight true -width 500 -header true -border true -headerAsText true -style "'margin-left:auto;margin-right:auto'" -title "'Settings'" -appendFromScript {
	Form frm0 \
	    -style "padding:5px;margin-left:auto;margin-right:auto;" \
	-label "Basic Info" \
	-labelWidth 125 \
	-action store \
	-autoHeight true \
        -submitText "Save Info" \
	-appendFromScript {
	    RadioGroup new -name gender -label "Gender" -appendFromScript {
		Radio new -label "Female" -value f
		Radio new -label "Male" -value m
	    }
	    RadioGroup new -name tshirt_size -label "T-Shirt Size" -appendFromScript {
		Radio new -label "Small" -value s
		Radio new -label "Medium" -value m
		Radio new -label "Large" -value l
		Radio new -label "X-Large" -value xl
		Radio new -label "2X-Large" -value 2xl
	    }

	} -proc render {args} {
	    set user_id [ad_conn user_id]
	    set ds [::db::Set new -type "Basic_Info" -where [list "user_id=[ns_dbquotevalue ${user_id}]"]]
	    $ds load
	    set user_info [$ds head]
	    
	    my initFromDict [dict create priv_contact_info [$user_settings set priv_contact_info] allow_ads_p [$user_settings set allow_ads_p]]
	    
	    return [next]
	    
	} -proc action(store) {marshaller} {
	    if { [my isValid] } {
		
		set mydict [my getDict]

		set user_id [ad_conn user_id]
		set priv_contact_info [dict get $mydict priv_contact_info]
		set allow_ads_p [dict get $mydict allow_ads_p]

		set o [::Users new -mixin ::db::Object]
		$o beginTransaction
		[$o getConn] do "update users set priv_contact_info=[ns_dbquotevalue $priv_contact_info], allow_ads_p=[ns_dbquotevalue $allow_ads_p] where user_id=[ns_dbquotevalue $user_id]"
		$o endTransaction

		ad_returnredirect ..

		#my set action "edit"
		#my set submitText "Edit Settings"
		####my set disabled true ;# my set maskDisabled false
		#foreach o [my getFields] { $o set disabled true }
		#$marshaller go -select "" -action draw


	    } else {

		foreach o [my set __childNodes(__FORM_FIELD__)] {
		    $o set value [$o getRawValue]
		    if { ![$o isValid] } {
			$o markInvalid "Failed Validation"
		    }
		}

		$marshaller go -select "" -action draw
		
		#doc_return 200 text/plain [my getDict]
		#doc_return 200 text/plain "Incomplete or Invalid Form"
	    }
	} -proc action(edit) {marshaller} {
	    $marshaller go -select "" -action draw
	}
    }
    }
