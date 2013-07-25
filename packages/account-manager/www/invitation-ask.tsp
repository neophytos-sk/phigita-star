tmpl::blank -title "Ask for an invitation" -onload "javascript:document.forms\[0\].elements\['email'\].focus()" {

    style {
	c {
	    body { margin: 20px; width: 95%; font: normal 14px Trebuchet MS, Arial, Helvetica, sans-serif; }
	    p, label { font: normal 14px Trebuchet MS, Arial, Helvetica, sans-serif; }
	    .input { font-size: 20px; width: 300px; padding: 5px; }
	    .button { font-size: 20px; }
	    #container { margin: 50px auto; width: 500px; text-align: center; }
	}
    }

    div -id "container" {
	img -src "/graphics/logo" -width "173" -height "35" -border "0" -alt "phigita.net! Homepage"
	p {
	    t "if you would like to participate, ask for an invitation"
	}
	
	form -action "invitation-ask-2" -method "post" {
	    label -title "your email" -class "label" {
		t "your email:"
	    }
	    t -disableOutputEscaping "&nbsp;"
	    input -type "text" -name "email" -value "" -class "input"
	    t -disableOutputEscaping "&nbsp;"
	    input -type "submit" -name "submit" -value "Ask" -class "button"
	}
	p -class "more" {
	    t "otherwise..."
	}
	p {
	    a -href "/" {
		t "read the blogs, linklogs, and answers"
	    }
	}
    }

}