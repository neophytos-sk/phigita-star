ad_page_contract {
    @author Neophytos Demetriou
} {
    {code:trim,notnull ""}
}

tmpl::blank {

    div -style "width:600px;margin:auto;" {
	form -action "" -method post {
	    textarea -rows 15 -cols 80 -name code { t $code }
	    button -type submit { t "TclEval" }
	}
	
	if {[catch {set result [eval $code]} errMsg]} {
	    pre { code { t $errMsg } }
	} else {
	    textarea -rows 20 -cols 80 { t $result }
	}
    }
}