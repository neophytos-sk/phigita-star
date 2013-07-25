

set ctx_uid [ad_conn ctx_uid]

set conn [DB_Connection new -volatile]

if {![${conn} exists [Blog_Item_Comment pdl.table.exists xo__u${ctx_uid} xo__blog_item_comment]]} {
    rp_returnnotfound
}

set userdata [db::Set new -from "users u inner join persons p on (u.user_id=p.person_id)" -where "user_id=[ns_dbquotevalue $ctx_uid]"]
${userdata} load
set u [${userdata} head]


set pathexp [list "User $ctx_uid"]
set commentdata [db::Set new -pathexp $pathexp -type ::Blog_Item -where [list "cnt_comments != 0"] -order "last_comment desc"]
$commentdata load

set sql [subst {
	    select 
	      parent_id,
	      title, 
	      c.max__creation_date, 
	      first_names, 
	      last_name, 
	      n_comments 
    from (xo__u${ctx_uid}.xo__blog_item i join 
		  (select 
		     parent_id,
		     max(creation_date) as max__creation_date, 
		     count(1) as n_comments, 
		     (select c1.creation_user 
		      from xo__u${ctx_uid}.xo__blog_item_comment c1 
		      where c1.parent_id = c2.parent_id 
		      order by c1.creation_date desc 
		      limit 1) as last__creation_user 
		   from xo__u${ctx_uid}.xo__blog_item_comment c2 
		   group by parent_id) c on (c.parent_id = i.id)) join cc_users on (last__creation_user = user_id)  where i.shared_p='t' order by max__creation_date desc;
}]

set full_name "[$u set first_names] [$u set last_name]"
tmpl::master -title "$full_name - Blog - Entries with Comments" -context_bar [ad_context_bar "Comments"] {

    b {
	t "Most Recent Comments"
    }
    br
    font -color "\#666" {
	i {
	    t " These are blog entries in which there have been the most recent contributions:"
	}
    }

    ul {
	#db_foreach comment ${sql} 
	foreach comment [$commentdata set result] {
	    $comment instvar {cnt_comments n_comments} last_comment id title
	    set first_names ""
	    set last_name ""
	    set full_name "$first_names $last_name"
	    li {
		a -href "../${id}" {
		    t ${title}
		}
		br

		font -color "\#666666" -size "-2" {
		    t " ${n_comments} [ad_decode ${n_comments} 1 "comment, on" "comments, last on"] [lc_time_fmt ${last_comment} %q] by $full_name"
		}
		
	    }
	    p
	}
    }

}
