
my instvar title show_action_p

### BLOGS
set base_url .
set string_length 15

set blogdata_limit 3
set blogdata_preview_limit 3
set blogdata [::db::Set new \
		  -cache "MOST_RECENT_SHARED_BLOG_ITEMS" \
		  -type [db::Inner_Join new \
			     -rhs [::db::Set new \
				       -alias bl \
				       -select {
					   bs.user_id 
					   cc.screen_name 
					   cc.status 
					   {first_names || ' ' || last_name as full_name}
				       } -type [db::Inner_Join new \
						    -lhs [::db::Set new \
							      -select {user_id} \
							      -alias bs \
							      -type ::sw::agg::Blog_Stats \
							      -where [list "cnt_shared_entries>0"]] \
						    -rhs [::db::Set new \
							      -type CC_Users \
							      -alias cc] \
						    -join_condition {bs.user_id = cc.user_id}]] \
			     -lhs [::db::Set new \
				       -alias mro \
				       -select {
					   sharing_start_date 
					   title 
					   root_object_id 
					   object_id 
					   {substring(content from 0 for 120) as snippet}
				       } -type ::sw::agg::Most_Recent_Objects \
				       -where [list "class_id=[Blog_Item set id]" "root_class_id=[User set id]" "shared_p"] \
				       -order "sharing_start_date desc" \
				       -limit ${blogdata_limit}] \
			     -join_condition {bl.user_id=mro.root_object_id}] \
		  -order "sharing_start_date desc" \
		  -limit ${blogdata_limit}]

${blogdata} load


set ds_x1 [::db::Set new \
	       -cache "COUNT_NEW_SHARED_BLOG_ENTRIES" \
	       -select [list "count(1) as cnt_new_entries"] \
	       -type ::sw::agg::Most_Recent_Objects \
	       -where [list "shared_p" "class_id=80" "sharing_start_date > current_timestamp-'2 days'::interval"]]
$ds_x1 load
set cnt_new_entries [[$ds_x1 head] set cnt_new_entries]



div -class "pl" {
    if { $show_action_p } {
	a -href "http://my.phigita.net/blog/post-write" -class action -style "color:#3366CC;" {
	    t "write"
	}
    }
    h2 -style "background-color:#DEE5F2;color:#5A6986;border-style:solid solid none;border-width:1px 1px medium;border-color:#ABB2C2 #DEE5F2 #5A6986;" {
	#   img -src http://www.phigita.net/graphics/icn_blog -align left
	t $title
    }
    div -style "border:1px solid #C5D7EF;overflow:hidden;padding:5px 5px 10px;" {
	div -class "tl s" { 
	    #t "\"[mc publish_to_the_web_instantly "Publish to the web instantly."]\"" 
	    t "\"[mc write_about_your_passion_or_life "Write about your passion. Or life."]\""
	}
	ul -style "padding-left:10px;" {
	    
	    foreach o [$blogdata set result] {
		#set snippet [string map {* "" \" "" : " " \/ " "} [regsub -all -- {http://[^\s]*} [${o} set snippet] {}]]
		#set snippet "[string tolower [string trim [string range ${snippet} 0 [expr [string wordstart ${snippet} end]-1]]]]..."
		li {
		    a -class "t" -href "${base_url}/~[util::coalesce [${o} set screen_name] [${o} set user_id]]/blog/[${o} set object_id]" {
			t [::textutil::adjust [${o} set title] -length ${string_length} -strictlength true]
		    }
		    br
		    small {
			a -class g -href "${base_url}/~[util::coalesce [${o} set screen_name] [${o} set user_id]]/" {
			    t "[${o} set full_name]"
			}
			t -disableOutputEscaping " (&nbsp;~[util::coalesce [${o} set screen_name] [${o} set user_id]]&nbsp;[getStatusImg [$o set user_id] [$o set status]])"
		    }
		    #div -class qu { t "\"${snippet}\"" }
		}
	    }
	}
	a -class "fl s i" -href "http://blogs.phigita.net/" {
	    t "more blogs..."
	}
	if { ${cnt_new_entries} } {
	    tmpl::tag=new -n_items "&nbsp;${cnt_new_entries}&nbsp;" -title "${cnt_new_entries} blog [ad_decode ${cnt_new_entries} 1 entry entries] in last 48 hours"
	}
	#t " \[ Latest Comments \]"

    }
}