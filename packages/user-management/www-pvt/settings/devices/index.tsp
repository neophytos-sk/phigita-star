set user_id [ad_conn user_id]

set data [::db::Set new \
	      -type ::echo::Device \
	      -where [list [::xo::db::qualifier device_user eq $user_id]]]
$data load

::tmpl::master -title "Manage Devices" {
    
    ::xo::html::add_style {
	input {font-size:1.5em;}
	button {font-size:1.5em;}
    }
    script {
	t {
	    function validate_phone(el) {
		var btnEl = document.getElementById('save_btn');
		var retval = false;
		if (!el.value.match(/^[+](357)([ ]*[1-9]|[1-9])[0-9]{7}$/)) {
		    btnEl.disabled=true;
		} else {
		    btnEl.disabled=false;
		    retval = true;
		}
		return retval;
	    }
	}
    }
    div -id phone_frm {
	div {
	    b { t "Mobile Phone" }
	}
	div {
	    foreach o [$data set result] {
		if { [$o set is_verified_p] } {
		    t "[$o set device_guid]"
		    span -style "color:blue;" { t "(verified)" }
		} else {
		    div -style "text-align:center;" {
			t "Verify your number [$o set device_guid] by sending the following code to +35797643810:"
			div -style "color:green;font-weight:bold;font-size:medium;" {
			    t [$o set device_token]
			}
		    }
		}
	    }
	}
	div {
	    form -id phone_frm -name pf -action phone-add -method "post" -onsubmit "return validate_phone(document.pf.phone)" {
		input -name phone -type text -value "+357" -onkeydown "return checkKey()" -onkeyup "return validate_phone(document.pf.phone)" -size 20 -style "margin-top:5px;"
		button -id save_btn -type submit -disabled "" { t "save" }
		div -style "color:#888;" {
		    ### (leaving off the leading 0 of your number if applicable)
		    t "Precede your number with a \"+\" and your country code. Example: +35797643810"
		}
	    }
	    script { t { validate_phone(document.pf.phone); document.pf.phone.focus() } }
	}
    }
}