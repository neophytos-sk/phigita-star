ad_page_contract {
    @author Neophytos Demetriou
} {
    {label_id:integer ""}
    {offset:naturalnum 0}
}


set limit 50

set tmp_offset [expr ${offset}-${limit}]
if {${tmp_offset}==0} {
    set override_script {}
} else {
    set override_script [list [list offset ${tmp_offset}]]
}

set newer_url [export_vars  -url -base . -no_empty -override ${override_script} {label_id year month day}]
set older_url [export_vars  -url -base . -no_empty -override {{offset {[expr ${offset}+${limit}]}}} {label_id year month day}]




set ctx_uid [ad_conn user_id]
set pathexp [list "User ${ctx_uid}"]



set wikidata [::db::Set new -select {id title shared_p creation_date last_update} -pathexp ${pathexp} -type ::wiki::Page -limit ${limit} -order "last_update desc"]
${wikidata} load


tmpl::master -title "Your Wiki" -context_bar [ad_context_bar] {
    source [acs_root_dir]/packages/wiki/tmpl-pvt/js.tcl

    style {
        c {
            .label {color: #063; font-size:75%; white-space:nowrap;}
		.bl {color:blue;}
	    .fr {float:right;}

		.dkBlue {
		    cursor:pointer;
		    border-bottom:solid 2px #000;
		    border-right:solid 2px #000;
		    border-top:solid 1px #336699;
		    border-left:solid 1px #336699;
		    background-color:#002255;
		    color:#fff;
		    font-size:105%;
		    text-decoration:none;
		    padding:.4em;
		    font-weight:bold;
		}
		.dkBlue:hover {
		    text-decoration:none;
		    background-color:#003366;
		    color:#fff;
		}
		a.dkBlue:hover {
		    _background-color:#002255;
		}



	    #actionmenu {width:300;border: 3px solid #dddddd; padding: 5px;margin-bottom:5px;}
	    #actionmenu h1 {font-size:120%;display:inline;}


	    #archivemenu {width:300;border: 3px solid #dddddd; padding: 5px;margin-bottom:5px;}
	    #archivemenu h1 {font-size:120%;display:inline;}

	    #labelmenu {width:300;border: 3px solid #dddddd; padding: 5px;margin-bottom:5px;}
	    #labelmenu h1 {font-size:120%;display:inline;}
	    #labelmenu ul {list-style-type:none;padding:0 10;text-align:center;}
	    #labelmenu li {display:inline;padding:3;overflow:visible;text-overflow:ellipsis;font-weight:bold;}
	    #labelmenu li a {color:#063;white-space:nowrap;font-weight:bold;}
	    #labelmenu li b {white-space:nowrap;}



	    #wikidata h1 {font-size:120%;display:inline;}
		#wikidata table th {color:#ffffff;background:#ddddbd;}
		#wikidata table td {color:#666666;background-color:#f0f0f0;padding:10;}

        }
    }


	a -class dkBlue -href "page-create" {
	    t "Create New Page"
	}

	p

	div -id "wikidata" {
	    div -style "float:right;" {
		set size [llength [${wikidata} set result]]
		if {${offset} > 0} {
		    a -class fl -href ${newer_url} {
			t -disableOutputEscaping "&\#171; Newer"
		    }
		}
		t " "
		if {${size}>${limit}} {
		    a -class fl -href ${older_url} {
			t -disableOutputEscaping "Older &\#187;"
		    }
		}
	    }

	    h1 { t "Wiki Pages " }
	    if {[exists_and_not_null subtitle]} {
		t -disableOutputEscaping "( [join ${subtitle} {; }] )"
	    }
		
	    p

	    table -width 100% {
		tr {
		    th {
			t "Title"
		    }
		    th -nowrap "" { t "Last Modified" }
		    th {
			t "Status"
		    }
		    th {
			t "Options"
		    }
		}
		set i 0
		foreach o [${wikidata} set result] {
		    tr {
			td -width "80%" -valign top {
			    a -href "[${o} set id]" {
				t [::util::coalesce [${o} set title] Untitled]
			    }
			}
			td -nowrap "" { t [lc_time_fmt [${o} set last_update] "%b %d, %Y"]}
			td -width "1%" -valign top -nowrap "" {
			    if { [${o} set shared_p] } {
				a -class fl -href "page-ac-set?id=[${o} set id]&shared_p=f" -onClick "return check(0,'privatize')" {
				    t "Draft"
				}
				t " | "
				t "Public"
			    } else {
				t "Draft"
				t " | "
				a -class fl -href "page-ac-set?id=[${o} set id]&shared_p=t" -onClick "return check(0,'publish')" {
				    t "Public"
				}
			    }
			}
			td -align center -nowrap "" {
			    t -disableOutputEscaping " &nbsp; "
			    a -class fl -href "page-edit?id=[${o} set id]" { t "Edit" }
			    t -disableOutputEscaping " &nbsp; "
			    a -class fl -href "page-delete?id=[${o} set id]" -onClick "return check(0,'delete')" { t "Delete" }
			    t -disableOutputEscaping " &nbsp; "
			}
			if {[incr i] == ${limit}} break;
		    }
		}
	    }

	}
    }
