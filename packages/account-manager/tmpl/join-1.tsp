ad_page_contract {
    @author Neophytos Demetriou
} {
    token:trim,notnull
}


set invite_id ""
set payload ""
lassign [split ${token} -] invite_id payload

if {![db_0or1row get_invitation_info "select inv.*,u.user_id,u.screen_name, (CURRENT_TIMESTAMP - '2 weeks'::interval > inv.creation_date) as expired_p from xo__friend_invite_tokens inv left outer join cc_users u on (inv.email = u.email) where inv.invite_id=:invite_id and inv.token=:payload"]} {
	rp_internal_redirect /packages/account-manager/tmpl/link-broken
}

if {![string equal ${friend_id} ""]} {
	rp_internal_redirect /packages/account-manager/tmpl/link-used
}

if {${expired_p}} {
	rp_internal_redirect /packages/account-manager/tmpl/link-expired
}


set exists_p [db_0or1row check_users "select screen_name,email from cc_users where email=:email"]
if { $exists_p } {
    rp_form_put screen_name $screen_name
    rp_form_put email ${email}
    rp_internal_redirect /packages/account-manager/tmpl/email-used
}


set screen_name ""
lassign [split ${email} @] screen_name


script -type "text/javascript" -src "GaiaCaribou.js"

script -type text/javascript {
	c {

var myxmlhttp;

/**
 * Trim Function (trims leading and trailing whitespace)
 * This function is used by parseResponseHeader, needed because the 
 * split function in IE doesn't strip the trailing "\n"
 */ 
function trim(value) {
   var temp = value;
   var obj = /^(\s*)([\W\w]*)(\b\s*$)/;
   if (obj.test(temp)) { 
     temp = temp.replace(obj, '$2'); 
   }
   return temp;
}

/**
 * parses the given xmlhttp response header for the given 
 * key's value 
 * 
 * The header will look like this: 
 *   NextIndex: 4
 *   PrevFirstName: John
 *   PrevLastName: Smith
 *   PrevDesired: John
 *   Content-Type: text/html; charset=ISO-8859-1
 *   Date: Mon, 03 Nov 2003 21:19:53 GMT 
 *   ...
 * 
 */ 
function parseResponseHeader(key, header) { 

  var lines = header.split("\n"); 
  var re = new RegExp("^" + key + ":\\s");

  for (var i in lines) { 
    if (re.exec(lines[i])) { 
      var returnValue = trim(RegExp.rightContext); 
      return returnValue; 
    } 
  } 
  return ""; 
} 

function CheckAvailXmlHttpHandler() {

  /* Ready when readystate == 4 
   * Success when status == 200
   */
  if (myxmlhttp.readyState != 4 || myxmlhttp.status != 200) { 
    return;
  }
  // get the values of the last inputs that were used to determine 
  // usernames & save them. 
  // extract the value of nextIndex from the response header

  var responseHeader = myxmlhttp.getAllResponseHeaders(); 

  // hidden variables to keep state information for the Handler
  // if the inputs (firstname, lastname, desired username) don't change, then 
  // we want to update NextIndex so we show different username suggestions each time 

//  var nextIndex = parseResponseHeader("NextIndex", responseHeader); 
//  if (nextIndex != "") { 
//    document.forms[0].NextIndex.value = nextIndex; 
//  } 

//  fillPrevious(parseResponseHeader("PrevFirstName", responseHeader), 
//               parseResponseHeader("PrevLastName", responseHeader),
//               parseResponseHeader("PrevDesired", responseHeader) ); 

  // Determine where in the page to write the response. 
  // Either at the "suggestionsDIV" or "errorDIV"

  var location = parseResponseHeader("Location", responseHeader); 
  

  if (location == "errorDIV") { 
    document.getElementById("errorDIV").innerHTML = "<br>" + myxmlhttp.responseText + "<br>";
    document.getElementById("suggestionsDIV").innerHTML = "<br>"; 
  } 

  if (location == "suggestionsDIV") {
    document.getElementById("suggestionsDIV").innerHTML = "<br>" + myxmlhttp.responseText + "<br>";
    document.getElementById("errorDIV").innerHTML = "<br>";
  }
}

function getAvailableNames() {


  var firstname = escape(document.forms[0].firstname.value); 
  var lastname = escape(document.forms[0].lastname.value); 
  var nickname = escape(document.forms[0].nickname.value);
  var token = escape(document.forms[0].token.value);
 
//  var nextIndex = escape(document.forms[0].NextIndex.value); 


  var url = "u-${token}?service=mail&continue=http://www.phigita.net/" + 
            "&nickname=" + nickname + "&firstname=" + firstname + 
            "&lastname=" + lastname;

  myxmlhttp = CreateXmlHttpReq(CheckAvailXmlHttpHandler);
  XmlHttpGET(myxmlhttp, url);
}

function suggestEmail(input) {
  if (!input.value) {
    var fn = document.forms[0].FirstName.value;
    var ln = document.forms[0].LastName.value;
    if (fn && ln) {
       input.value = trim(fn) + '.' + trim(ln);
       input.select();
    }
  }
}
}
}





tmpl::simple -title "Create your account" -onload {javascript:document.forms['createaccount'].elements['nickname'].focus()} {
blockquote {
t "To create your account, please fill out the following form."
p
form -id "createaccount" -name "createaccount" -action "c-${invite_id}-${payload}" -method "post" {
input -type hidden -name "token" -value ${invite_id}-${payload}
	table -cellpadding "2" -bgcolor "#cbdced" -cellspacing "0" -border "0" -width "400" {
	    tr {
		td {
		    table -cellpadding "2" -bgcolor "#eeeeee" -cellspacing "0" -border "0" -width "100%" {
			tr {
			    td -bgcolor "#ffffff" -align "center" {
				table -cellpadding "5" -bgcolor "#ffffff" -cellspacing "0" -border "0" -width "100%" {
				    tr {
					td -width "1%" -nowrap "" -valign "top" {
					    font -size "-1" -face "Arial, sans-serif" {
						b { t "[mc First_Name "First Name"]: " }
					    }
					}
					td {
					    div -class "errorbox-good" {
						input -type text -name "firstname" -value ${first_name} -size 30
					    }
					}
				    }
				    tr {
					td -width "1%" -nowrap "" -valign "top" {
					    font -size "-1" -face "Arial, sans-serif" {
						b { t "[mc Last_Name "Last Name"]: " }
					    }
					}
					td {
					    div -class "errorbox-good" {
						input -type text -name "lastname" -value ${last_name} -size 30
					    }
					}
				    }
				    tr {
					td -width "1%" -nowrap "" -valign "top" {
					    font -size "-1" -face "Arial, sans-serif" {
						b { t "Desired Login Name: " }
					    }
					}
					td {
					    font -size "-1" -face "Arial, sans-serif" {
					    div -class "errorbox-good" {
						input -type text -name "nickname" -value ${screen_name} -size 30
						div -id "errorDIV" {
						  br
						}
						br
						input -type "button" -name "checkavail" -value "check availability!"  -style "font-size:9pt" -onclick "getAvailableNames()"
						div -id "suggestionsDIV" {
						  br
						}
					    }
					    }
					}
				    }
				    tr {
					td -width "1%" -nowrap "" -valign "top" {
					    font -size "-1" -face "Arial, sans-serif" {
						b { t "Email address: " }
					    }
					}
					td {
					    div -class "errorbox-good" {
						input -type text -name "email" -disabled "" -value ${email} -size 30
					    }
					}
				    }
				    tr {
					td -width "1%" -nowrap "" -valign "top" {
					    font -size "-1" -face "Arial, sans-serif" {
						b { t "Password: " }
					    }
					}
					td {
					    div -class "errorbox-good" {
						input -type password -name "password" -size 30
					    }
					}
				    }
				    tr {
					td -width "1%" -nowrap "" -valign "top" {
					    font -size "-1" -face "Arial, sans-serif" {
						b { t "Re-enter password: " }
					    }
					}
					td {
					    div -class "errorbox-good" {
						input -type password -name "password_confirmation" -size 30
					    }
					}
				    }
				    tr {
					td -colspan "3" -align "center" {
#					    input -type submit -value "I have read and agree to the Terms of Use. Create my account."
					    input -type submit -style "width:100%" -value "Create my account."
					}
				    }
				}
			    }
			}
		    }
		}
	    }
	}
}
}
}