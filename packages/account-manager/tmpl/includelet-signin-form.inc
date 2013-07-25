set return_url [get_value_if arg(return_url) ""]



div -class "signin" {

    form -method "post" -action "user-login" -name "login" {
	input -type "hidden" -name "return_url" -value ${return_url}
	input -type "hidden" -name "time" -value @{time}
	input -type "hidden" -name "token_id" -value @{token_id}
	input -type "hidden" -name "hash" -value @{hash}

	div -class "signin-box" {

	    h2 {
		t "Sign in"
		strong
	    }

	    div -class "control-group" {
		label -for "email" {
		    strong -class "email-label" {
			t "Username (or email)"
		    }
		}
		input -id "email" -type "text" -name "email" -value @{email} -spellcheck false
	    }
	    div -class "control-group" {
		label -for password {
		    strong -class "password-label" {
			t "Your Password:"
		    }
		}
		input -id password -type "password" -name "password"
		div -id "password_hash" {
		    div -id "one"
		    div -id "two"
		    div -id "three"
		}
	    }
	    br -clear both
	    div -class "control-group" {

		div -style "margin-top:10px;" {
		    input -type "submit" -value "Sign in" -class "btn btn-primary"

		    div -class "remember"  {
			label -for "persistent_cookie_p" {
			    input -type "checkbox" -name "persistent_cookie_p" -value "1" -size 50 -id "persistent_cookie_p"
			    strong -class "remember-label" { t " Stay signed in?" }
			}
		    }
		}

	    }
	    p
	    
	    div -class "control-group" {
		small {
		    strong { t "Mode: " }
		    tpl -if { @{protocol} eq {http} } {
			t "Standard"
			t " | "
			a -href @{secure_mode_url} {
			    t "Secure"
			}
		    } 
		    tpl -else "" {
			a -href @{standard_mode_url} {
			    t "Standard"
			}
			t " | "
			t "Secure"
		    }
		    br
		    a -href "forgotten-password" {
			t "Forgot your password?"
		    }
		}
	    }

	}
    }
}
