ad_page_contract {
    @author Neophytos Demetriou
} {
    {ctx_uid:integer ""}
    {date ""}
    {m ""}
}



if {[string equal ${date} ""]} then {
    set s 0 ;# state 

    set date [dt_sysdate]

    set blog_items [Blog_Item retrieve \
			-pathexp "User [ad_conn user_id]" \
			-output "*, to_char(entry_date, 'J') as entry_date_julian " \
			-order "entry_date desc"\
			-limit "10"]

} else {
    set s 1 ;# state 

    set date_format "YYYY-MM-DD HH24:MI"

    set blog_items [Blog_Item retrieve \
			-pathexp "User [ad_conn user_id]" \
			-output "*, to_char(entry_date, 'J') as entry_date_julian " \
			-criteria "entry_date between
                                                 to_date([ns_dbquotevalue ${date}],[ns_dbquotevalue ${date_format}]) and
                                                 to_date([ns_dbquotevalue ${date}],[ns_dbquotevalue ${date_format}]) + (24 - 1/3600)/24" \
			-order "entry_date desc"\
			-limit "10"]

}

if {[string equal ${m} ""]} {
    set month_number [clock format [clock scan ${date}] -format %m] 
} else {
    set month_number ${m}
}

#set year_number [clock format [clock scan ${date}] -format %Y] 
#set prev_month [clock format [clock scan [dt_prev_month ${year_number} ${month_number}]] -format %m]
#set next_month [clock format [clock scan [dt_next_month ${year_number} ${month_number}]] -format %m]

set calendar_details [ns_set create calendar_details]

if {![string equal ${blog_items} ""]} {
    db_foreach entry_dates "select to_char(entry_date, 'J') as entry_date_julian from xo__u[ad_conn user_id].xo__blog_item" {
	ns_set put $calendar_details $entry_date_julian "1"
    }
}




tmpl::master -title "My Blogger" -context_bar [ad_context_bar] -role "pvt" {

source [acs_root_dir]/packages/blogger/tmpl/js.tcl
    
    table -cellpadding 10 {
	tr {
	    td -valign "top" {

		set previous_entry_date "0000-00-00 00:00:00"
		foreach bi ${blog_items} {

		    ns_set update $calendar_details [${bi} set entry_date_julian] "2"

		    if {![string equal [lc_time_fmt [${bi} set entry_date] %Q] [lc_time_fmt ${previous_entry_date} %Q]]} {
			
			div -style "border: 1px solid #2040ff;background: #c0d0ff;padding: 1px;margin: 0px 0px 3px 0px;" {
			    img -src /graphics/blogger/permalink -width 12 -height 15 -border 0
			    b {
				t " "
				t [lc_time_fmt [${bi} set entry_date] %Q]
			    }
			}
		    } else {
			div -style "border-top:1px dashed #3366cc;padding-bottom:14px;"
			p
		    }
		    h2 {
			t [${bi} set title] 
		    }
		    p
		    #t -disableOutputEscaping [ad_text_to_html [${bi} set body]]
		    t -disableOutputEscaping [stx_to_html [${bi} set body]]
		    
		    table -width 100% {
			tr {
			    td -align "right" {
				small {
				    t "posted at "
				    t [lc_time_fmt [${bi} set entry_date] %r]
				    t -disableOutputEscaping "&nbsp;-&nbsp;"
				    a -href "[${bi} set id]" { t "\#" }
				    t -disableOutputEscaping "&nbsp;-&nbsp;"
				    a -href "/search/?q=[${bi} set title]" { t "G" }
				    t -disableOutputEscaping "&nbsp;-&nbsp;"
				    a -href "comments" { t "Comments" }
				    t -disableOutputEscaping "&nbsp;&nbsp;"
				    p
				    span -style "border: 1px solid #ff2040;background: #ffc0d0;padding: 1px;margin: 0px 0px 3px 0px;" {
					t "Administration: "
					a -href "entry-edit?id=[${bi} set id]" { t "Edit" }
					t -disableOutputEscaping "&nbsp;-&nbsp;"
					a -href "entry-delete?id=[${bi} set id]" -onClick "return check(0,'delete')" { t "Delete" }
					t -disableOutputEscaping "&nbsp;-&nbsp;"
					t -disableOutputEscaping "<b>[ad_decode [${bi} set shared_p] f Private Public]  Access</b> "
					t " (make it "
					a -href "entry-ac-set?id=[${bi} set id]&shared_p=[ad_decode [${bi} set shared_p] t f t]" -onClick "return check(0,'[ad_decode [${bi} set shared_p] f publish privatize]')" {
					    t "[ad_decode [${bi} set shared_p] t Private Public]"
					}
					t ")"
				    } 
				}
			    }
			}
		    }
		    set previous_entry_date [${bi} set entry_date]
		}

	    }
	    td -bgcolor efefef -valign "top" -width "1%" {

		p

		tmpl::action_bar [list \
				      {entry-add blogger.Add_Entry "Add Entry"} \
				      [list /~[ad_conn user_id]/blogger/ blogger.Jump_To_Public_Blogger "See Public View"] ]

		p

		tmpl::month_calendar -date ${date} -tsp {
		    center {
			if {[string equal {%2$s} {%3$s}]} then {
			    div -style "border: 2px solid #FFA500;padding: 1px;margin: 0px 0px 3px 0px;" {
				if {[ns_set get $calendar_details {%2$s}] == "1"} then {
				    a -href "?date=[dt_julian_to_ansi {%2$s}]" {
					t {%1$s}
				    } 
				} elseif {[ns_set get $calendar_details {%2$s}] == "2"} then {
				    a -href "?date=[dt_julian_to_ansi {%2$s}]" -style "background-color: #ffc0d0" {
					t {%1$s}
				    }
				} else {			
				    t {%1$s}
				}
			    }
			} else {
			    if {[ns_set get $calendar_details {%2$s}] == "1"} then {
				a -href "?date=[dt_julian_to_ansi {%2$s}]" {
				    t {%1$s}
				}
			    } elseif {[ns_set get $calendar_details {%2$s}] == "2"} then {
				a -href "?date=[dt_julian_to_ansi {%2$s}]" -style "background-color: #ffc0d0" {
				    t {%1$s}
				}				
			    } else {
				t {%1$s}
			    }
			}
		    }
		}

		set comment {
		    a -href "?m=${prev_month}" {
			t "Previous"
		    }
		    t " - "
		    a -href "?m=${next_month}" {
			t "Next"
		    }
		}


		center {
		    if {${s} == 0} {
			t "--> Show most recent <--"
		    } else {
			a -href "." {
			    t "Show most recent"
			}
		    }
		}

			    p

		table -border 0 -cellpadding 1 -cellspacing 0 -bgcolor "#ffff00" {
		    tr {
			td {


			    table -border 0 -cellpadding 6 -cellspacing 0 -width 100% -bgcolor "#ffffcc" {
				tr {
				    td {
					font -color "#000000" {


					    small {
						t " Blogger is a web-based tool that helps you publish to the web instantly -- whenever the urge strikes. A blog is a web page made up of usually short, frequently updated posts that are arranged chronologically. The content and purposes of blogs varies greatly -- from links and
commentary about other web sites, to news about a company/person/idea, to diaries, photos, poetry, mini-essays, project updates, even fiction. "
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
    
    set date [dt_sysdate]
    set month_number [clock format [clock scan $date] -format %m]

	set comment	{
    set calendar_details [ns_set create calendar_details]
    db_foreach entry_dates { select to_char(entry_date, 'J') as entry_date_julian from xo__u790.xo__blog_item } {
	ns_set put $calendar_details $entry_date_julian "1"
    }

    t -disableOutputEscaping [dt_widget_month_small \
				  -date $date \
				  -calendar_details $calendar_details \
				  -day_number_template "\[ad_decode \[ns_set get \$calendar_details \$julian_date\] 1 \"<a href=\\\"?date=\$year-$month_number-\[format \"%02d\" \$day_number\]/\\\" title=\\\"View the entries for this date\\\"><b>\$day_number</b></a>\" \$day_number\]"]
    }

}
