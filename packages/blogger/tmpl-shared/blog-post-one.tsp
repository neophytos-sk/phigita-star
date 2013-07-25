#source [acs_root_dir]/packages/kernel/tcl/StructuredText/StructuredText-procs.tcl
#source [acs_root_dir]/packages/core-platform/tcl/tsp/tmpl-procs.tcl

ad_page_contract {

    @author Neophytos Demetriou

} {
    id:integer,notnull   
    ctx_uid:integer  
}



set ds [::db::Set new \
	    -type CC_Users \
	    -where [list "user_id=[ns_dbquotevalue $ctx_uid]"]]
$ds load
set user_info [$ds head]



foreach varname {first_names last_name status screen_name priv_contact_info allow_ads_p} {
    set $varname [$user_info set $varname]
}

set current_root_of_hierarchy [User set id]-[ad_conn ctx_uid]

set user_id [ad_conn user_id]
set object_id [ad_conn subsite_id]
set privilege admin
set admin_p [permission::permission_p -party_id $user_id -object_id $object_id -privilege $privilege]



#source [acs_root_dir]/packages/kernel/tcl/xo/20-db/Query-procs.tcl
#source [acs_root_dir]/packages/persistence/tcl/32-connector-procs.tcl

set bi [::xo::db::get_cell User:${ctx_uid} Blog_Item:${id}]

if { ${bi} eq {} } {
    rp_returnnotfound
    return
}


set labels [::xo::db::get_slice User:${ctx_uid} Blog_Item_Label]
array set labelmap [$labels getIndexMapBy id]
set nlabels [llength [$bi set labels]]
### $bi set labels [::xo::fun::map x [$bi set labels] { set labelmap($x) }]


set users [::xo::db::get_slice "" CC_Users]
array set usermap [$users getIndexMapBy user_id]


set pathexp [list "User $ctx_uid"]
set prev_entries_data [::db::Set new \
			   -pathexp $pathexp \
			   -select "id title" \
			   -type ::Blog_Item \
			   -where [list "shared_p = 't'" "entry_date < [ns_dbquotevalue [${bi} set entry_date]]" "title is not null"] \
			   -order "entry_date desc" \
			   -limit "5"]

set next_entries_data [::db::Set new \
			   -pathexp $pathexp \
			   -select "id title" \
			   -type ::Blog_Item \
			   -where [list "shared_p = 't'" "entry_date > [ns_dbquotevalue [${bi} set entry_date]]" "title is not null"] \
			   -order "entry_date" \
			   -limit "5"]

$prev_entries_data load
$next_entries_data load

set prev_entries [$prev_entries_data set result]
set next_entries [$next_entries_data set result]

set next_entries [lreverse $next_entries]

if { ![string equal [${bi} set title] ""]} {
    set page_title [${bi} set title]
} else {
    set page_title "Blog Entry \#[${bi} set id]"
}
 

#set userdata [db::Set new -from "users u inner join persons p on (u.user_id=p.person_id)" -where "user_id=[ns_dbquotevalue $ctx_uid]"]
#${userdata} load
set u $usermap($ctx_uid)

##set typo_date [clock format [${bi} set pubdate] -format "%a, %d %b %Y %H:%M:%S %Z" -timezone :Europe/Nicosia]
set typo_date [clock format [clock scan [::xo::db::tcl_date [$bi set entry_date] tz]] -format "%a, %d %b %Y %H:%M:%S %Z" -timezone :Europe/Nicosia]




tmpl::UserSharedMaster -title "${page_title} \[${first_names} ${last_name} > [mc Blog Blog]\]" -context_bar [ad_context_bar "One Blog Entry"] {


    div -id "main" {
	::xo::ns::include [acs_root_dir]/packages/user-management/tmpl-shared/includelet-user-homepage-tabs.tcl -set selectedKey one-blog-entry -set base ..

	p
	div -class post {
	    h2 {
		t [${bi} set title] 
	    }
	    p -class auth {
		t "Posted by "
		a -href "/~[$u set screen_name]/" {
		    t "[$u set first_names] [$u set last_name]"
		}
		t " "
		
		span -class "typo_date" -title $typo_date {
		    t $typo_date
		}
	    }

	    div -class post {
		try {
		    t -disableOutputEscaping [stx_to_html "\n [${bi} set body]" -root_of_hierarchy $current_root_of_hierarchy -object_id ${id}]
		} catch {*} {
		    t -disableOutputEscaping "<span style=\"color:red;\">*</span>[$bi set body]"
		}
	    }
	    p -class meta {
		if { $nlabels } {
		    t "Posted in "
		    set j 0
		    foreach label_id [$bi set labels] {
			set label $labelmap($label_id)
			a -class label -href ".?label_id=${label_id}" {
			    t [${label} set name]
			}
			if {[incr j]<${nlabels}} {
			    t ", "
			}
		    }
		    t " | "
		}
		t "[ad_decode [$bi set cnt_comments] 0 no [$bi set cnt_comments]] comments"
	    }
	}

	if { [llength [${bi} set comments]] } {
	    ol -class "comment-list" -id "commentList" {
		center {
		    h2 {
			t [mc readers_comments "Reader's Comments"]
		    }
		}
		p
		foreach commentDict [${bi} set comments] {
		    dict with commentDict {
			set commentator_root_of_hierarchy [User set id]-${creation_user}

			set commentator $usermap($creation_user)
			set nickname [$commentator set screen_name]

			li -id "comment-${id}" {
			    if { $shared_p } {
				p -id "$id" {
				    t -disableOutputEscaping [stx_to_html $comment -image_prefix /~${nickname}/blog/ -root_of_hierarchy $commentator_root_of_hierarchy]
				}
				t "-- "
				a -href "/~${nickname}/" {
				    t "[${commentator} set first_names] [${commentator} set last_name]"
				}
				sub {
				    t -disableOutputEscaping "&nbsp;~${nickname}"
				}
				t ", "
			    } else {
				font -color red { i { t "-- Hidden!.. " } }
				if {[${comment} set user_id]==${user_id} || ${admin_p}} {
				    # commentator or administrator
				    t -disableOutputEscaping [stx_to_html [${comment} set comment]  -image_prefix /~${nickname}/blog/ -root_of_hierarchy $commentator_root_of_hierarchy]
				    t "-- "
				    a -href "/~${nickname}/" {
					t "[${comment} set first_names] [${comment} set last_name]"
				    }
				    sub {
					t -disableOutputEscaping "&nbsp;~${nickname}"
				    }
				    t ", "
				} else {
				    # visitor or blog maintainer
				}
			    }
			    t "[lc_time_fmt $creation_date %q]"
			    t " "
			    if {${admin_p}} {
				t "\["
				a -href "admin/comment-edit?id=$id" {
				    t "edit"
				}
				t "\]"
			    }

			    if {${ctx_uid}==${user_id}} {
				t " "
				t "\["
				set return_url /~[::util::coalesce ${screen_name} ${user_id}]/blog/${id}
				if { ${shared_p} } {
				    a -href "/my/blog/comment-toggle?id=${id}&shared_p=f&return_url=${return_url}" {
					t "hide"
				    }
				} else {
				    a -href "/my/blog/comment-toggle?id=${id}&shared_p=t&return_url=${return_url}" {
					t "show"
				    }
				}
				t "\]"
			    }
			    p
			}
		    }
		}
	    }
	}

	if {[util::coalesce [${bi} set allow_comments_p] f]} {
	    p
	    center {
		form -method GET -action "comment-add" {
		    input -type hidden -name parent_id -value ${id}
		    input -type submit -value "Add a Comment"
		}
	    }
	}
    }


    div -id sidebar {

	if {[string equal [ad_conn user_id] ${ctx_uid}]} {
	    div {
		h3 { t "Actions" }
		ul {
		    li {
			a -href "http://my.phigita.net/blog/post-edit?id=[${bi} set id]" { t "Edit" }
		    }
		    li {
			a -href "http://my.phigita.net/blog/${id}" {
			    t [mc Jump_to_Private_View "Jump to Private View"]
			}
		    }
		}
	    }
	}


	set prev [lindex ${prev_entries} 0]
	set next [lindex ${next_entries} end]

	p
	div -style "text-align:center;" {
	    h3 { t "Nearby"	}
	    
	    if {![string equal ${next} ""]} {
		a -href "[$next set id]" -title "[$next set title]" {
		    t -disableOutputEscaping "&laquo; newer"
		}
		t " | "
	    }
	    a -href "./" {
		t "up"
	    }
	    if {![string equal ${prev} ""]} {
		t " | "
		a -href "[$prev set id]" -title "[$prev set title]" {
		    t -disableOutputEscaping "older &raquo;"
		}
	    }
	}
	
	br
	ul {
	    foreach entry ${next_entries} {
		li {
		    a -href "[${entry} set id]" -title "[$entry set title]" {
			
			t "[$entry set title]" 
			
		    }
		}
	    }
	    li {
		b {
		    if {![string equal [$bi set title] ""]} {
			t "[$bi set title]" 
		    } else {
			font -color "red" {
			    t "Untitled: This Entry"
			}
		    }
		}
	    }
	    
	    foreach entry ${prev_entries} {
		li {
		    a -href "[${entry} set id]" -title "[$entry set title]" {
			
			t "[$entry set title]" 
			
		    }
		}
	    }
	}
	p
	if { $allow_ads_p } {
	    ###  /* Share Zone, Blog Posts, TR */
	    div {
		::xo::google::adsense::slot 8133060118 200 200
	    }
	}
    }

}
