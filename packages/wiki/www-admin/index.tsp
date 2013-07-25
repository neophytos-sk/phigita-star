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




set wikidata [::db::Set new \
		  -select {root_object_id object_id title shared_p sharing_start_date first_names last_name screen_name} \
		  -type [::db::Inner_Join new \
			     -join_condition "cc.user_id=mro.root_object_id" \
			     -rhs [::db::Set new -select {user_id screen_name first_names last_name} -alias cc -from CC_Users] \
			     -lhs [::db::Set new -alias mro -type ::sw::agg::Most_Recent_Objects -where [list "class_id=70"]]] \
		  -limit ${limit} \
		  -order "sharing_start_date desc"]
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
			t "User"
		    }
		    th {
			t "Title"
		    }
		    th {
			t "Status"
		    }
		    th -nowrap "" { t "Sharing Start Date" }
		}
		set i 0
		foreach o [${wikidata} set result] {
		    tr {
			td -nowrap "" {
			    a -href "/~[$o set screen_name]/" {
				t "[$o set first_names] [$o set last_name]"
			    }
			}
			td -width "80%" -valign top {
			    a -href "page-one?root_object_id=[$o set root_object_id]&id=[$o set object_id]" {
				t [::util::coalesce [${o} set title] Untitled]
			    }
			}
			td {
			    if { [$o set shared_p] } {
				b {
				    t "Public"
				}
			    } else {
				t "Private"
			    }
			}
			td -nowrap "" { t [lc_time_fmt [${o} set sharing_start_date] "%b %d, %Y"]}
			if {[incr i] == ${limit}} break;
		    }
		}
	    }

	}
    }
