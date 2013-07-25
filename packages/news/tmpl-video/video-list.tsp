set latest_video [::db::Set new -select * -type ::Video -order "last_update desc" -limit 64 -load]

tmpl::master -docStyleId doc3 -title "Video Buzz" {

    ::xo::html::add_style {
	p.video {color:#949494;font-size:10px;font-weight:normal;line-height:11px;margin:0pt;padding:0pt 12px 0pt 0pt;}   
	p.video a {color:#004276;text-decoration:none;}
    }

    div -style "float:right;" {
	::xo::google::adsense::slot 5014637820 160 600
    }

    div -style "float:left;padding:5;" {
	::xo::google::adsense::slot 1150766718 125 125
    }


    foreach o [$latest_video set result] {
	div -style "width:100;height:150;float:left;text-align:center;" {

	    lassign [::xo::buzz::getThumbnailDetails $o] thumbnail_url thumbnail_width thumbnail_height
	    a -href "[$o set ref_video_id].[$o set provider]" {
		img -src "${thumbnail_url}" -width $thumbnail_width -height $thumbnail_height -style "margin:1;"
	    }
	    br
	    p -class video {
		a -href "[$o set ref_video_id].[$o set provider]" {
		    t [$o set title]
		}
	    }
	}
    }


    div -style "float:left;padding:5;" {
	::xo::google::adsense::slot 1150766718 125 125
    }

}
