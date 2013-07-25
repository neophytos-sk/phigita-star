::xo::html::add_style {
    .bb_type {float:left;width:75px;text-align:center;font-size:x-small;}
    .bb_title {margin-left:85px;font-size:120%;}
    .bb {border:1px solid #f0f0f0;padding:5;margin-top:3px;}
    .bb a.title {color:#16387c;text-decoration:none;}
    .bb a.title:hover {text-decoration:underline;}
}


set bbdata [::db::Set new \
		-cache "BBOARD.TOP5_MESSAGES" \
		-select {
		    * 
		    {m.id as message_id}
		    {t.hstore->'color' as color}
		    {t.hstore->'background' as background}
		} \
		-type [::db::Left_Outer_Join new \
			   -lhs [::db::Set new -alias m -type ::bboard::Message -order "creation_date desc" -limit 5] \
			   -rhs [::db::Set new -alias t -type ::bboard::Message_Type] \
			   -join_condition {m.type_id=t.id}] \
		-order "creation_date desc"]

$bbdata load

if { ![$bbdata emptyset_p] } {
    nt "\[&nbsp;BBoard&nbsp;\]"
    br
    t "advertise things to buy or sell"
    br
    t "promote who you want"
    br
    t "announce events"
    br
    t "or provide information"

    foreach o [$bbdata set result] {
	div -class "bb pl" {
	    div -class "bb_msg" {
		div -class "bb_type" {
		   div -style "width:100%;margin:1px;padding:1px;background:[::util::coalesce [$o set background] \#fffebb];color:[::util::coalesce [$o set color] \#000000];" {
			#t -disableOutputEscaping [lc_time_fmt [$o set creation_date] "%a<br>%b %d"]
			t [::util::coalesce [$o set name] Notice]
		    }
		}
		div -class "bb_title" {
		    a -class title -href /bboard/message/[$o set message_id] {
			t [$o set title]
		    }
		}
	    }
	}
    }
    a -class fl -href "bboard/" {
	t "more messages..."
    }
    if { 0 != [ad_conn user_id] } {
	t " "
	a -class fl -href "bboard/message-one" {
	    t "\[Post to BBoard\]"
	}
    }
}