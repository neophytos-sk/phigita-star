val -id registered_p { ::xo::kit::is_registered_p }

### BLOGS
set base_url .
set blogdata_limit 3
set blogdata_preview_limit 3

datastore \
    -id blogdata \
    -cache "MOST_RECENT_SHARED_BLOG_ITEMS" \
    -select {title screen_name full_name object_id} \
    -from_class [db::Inner_Join new \
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
			       } -type ::sw::agg::Most_Recent_Objects \
			       -where [list "class_id=[Blog_Item set id]" "root_class_id=[User set id]" "shared_p"] \
			       -order "sharing_start_date desc" \
			       -limit ${blogdata_limit}] \
		     -join_condition {bl.user_id=mro.root_object_id}] \
    -order "sharing_start_date desc" \
    -limit ${blogdata_limit} \
    -extend {
        set title [::textutil::adjust $title -length 17 -strictlength true]
    }

#####

css {
    .blogs_header {
	background:#dee5f2;padding:2px 0px;height:1.5em;
	color:#5A6986;
    }
    .blogs_header strong {
	font-size: 16px;
	margin-left:5px;
    }
    .blogs_action {
	width:40px;
    }
}

div -id "blogs" {
    a -href "https://my.phigita.net/blog/post-create" -class "btn btn-default btn-mini blogs_action" -style "float:right;" {
	t "write"
    }

    div -class "blogs_header" {
	strong { t "Blogs" }
	t " "
	sup { t "write about your passion, or life" }
    }

    #layout_row {
	#layout_col -class span3 {
	    div {
            dataview -id "somename" {
                tpl -for "blogdata" -limit "3" {
                    dl {
                        dt {
                        a -href "/~@{screen_name}/blog/@{object_id}" {
                            t @{title}
                        }
                        }
                        dd {
                        a -href "/~@{screen_name}/" {
                            t @{full_name}
                        }
                        ## CHAT presence &nbsp; getStatusImg o set user_id o set status
                        t " (~@{screen_name})"
                        }
                    }
                }
		    }
	    }
	#}
	#layout_col -class span3 {
	    #div {
		#tpl -for "blogdata" -offset "3" {
		#}
	    #}
	#}
    #}

    a -class "btn btn-link btn-mini" -href "http://blogs.phigita.net/" {
	t "More Blogs"
    }
	tpl -if @{val.registered_p} {
	    t " "
	    a -class "btn btn-link btn-mini" -href "http://my.phigita.net/blog/" {
		t "Your Blog"
	    }
	}

}
