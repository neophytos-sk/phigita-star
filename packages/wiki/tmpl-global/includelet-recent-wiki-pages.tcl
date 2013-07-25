### WIKI
set limit 7
set wikidata [::db::Set new \
		  -select {root_object_id object_id title shared_p sharing_start_date first_names last_name screen_name} \
		  -type [::db::Inner_Join new \
			     -join_condition "cc.user_id=mro.root_object_id" \
			     -rhs [::db::Set new \
				       -select {user_id screen_name first_names last_name} \
				       -alias cc \
				       -type CC_Users] \
			     -lhs [::db::Set new \
				       -alias mro \
				       -type ::sw::agg::Most_Recent_Objects \
				       -limit ${limit} \
				       -order "sharing_start_date desc" \
				       -where [list shared_p "class_id=70"]]] \
		  -limit ${limit} \
		  -order "sharing_start_date desc"]
${wikidata} load

div -id "wikimenu" -class pl {
    a -href "http://my.phigita.net/wiki/page-create" -class action -style "color:#666666;" {
	t "create"
    }
    #h2 -style "background-color:#E5ECF9;color:#3366CC;border-style:solid solid none;border-width:1px 1px medium;border-color:#7AA5D6 rgb(197, 215, 239) #3366CC;" 
    h2 -style "background-color:#DDDDDD;color:#333333;border-style:solid solid none;border-width:1px 1px medium;border-color:#888888 #CCCCCC #CCCCCC" {
	t "Wiki" 
    }
    #div -style "border:1px solid #C5D7EF;overflow:hidden;padding:5px 5px 10px;" 
    div -style "border:1px solid #C5C5C5;overflow:hidden;padding:5px 5px 10px;" {
	div -class "tl s" { 
	    t "\"[mc create_a_knowledge_web "Create a knowledge web."]\"" 
	}

	ul -class pl -style "padding:10;" {
	    if {[${wikidata} emptyset_p]} {
		i { t None }
	    } else {
		foreach o [${wikidata} set result] {
		    li {
			a -class t -href "/~[$o set screen_name]/wiki/[$o set object_id]" {
			    t [${o} set title]
			}
		    }
		}
	    }
	}
    }
}