ad_page_contract {
    @author Neophytos Demetriou
} {
    {firstname:trim ""}
    {lastname:trim ""}
    {nickname:trim,notnull ""}
}

if {[regexp {[^a-z0-9\.]} ${nickname} match]} {

    set location errorDIV
    set response {
	<font color="red">
	Sorry, only letters (a-z), numbers (0-9), and periods (.) are allowed.
	</font>
    }

} elseif { [string length ${nickname}] < 5 || [string length ${nickname}] > 30 } {

    set location errorDIV
    set response {
	<font color="red">
	Sorry, your username must be between 5 and 30 characters long.
	</font>
    }

} elseif { [string index ${nickname} 0] == "." } {

    set location errorDIV
    set response {
	<font color="red">
	Sorry, the first character of your username must be an ascii letter (a-z) or number (0-9).
	</font>
    }

} elseif { [string index ${nickname} end] == "." } {

    set location errorDIV
    set response {
	<font color="red">
	Sorry, the last character of your username must be an ascii letter (a-z) or number (0-9).
	</font>
    }

} else {

    set result [db_0or1row check_exists_p "select 1 from users where screen_name=:nickname"]

    if { ${result} } {
	set location suggestionsDIV
	set response [subst {
	    <font color=ff0000>
	    <b>${nickname}</b> is not available.<!--, but the following usernames are:-->
	    </font>
	}]
    } else {
	set location suggestionsDIV
	set response [subst {
	    <font color=3366cc>
	    <b>${nickname}</b> is available.
	    </font>
	}]
    }
}

ns_set put [ad_conn outputheaders] Location ${location}
doc_return 200 text/xml ${response}
#doc_return 200 text/xml [subst -nobackslashes -nocommands {<?xml version="1.0"?>${response}}]