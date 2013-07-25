::xo::html::iuse "vstat0 vstat1 vstat2 vprev vnext"


set video_limit 9
# -pool newsdb
set latest_video [::db::Set new \
		      -cache VIDEO.TOP_${video_limit}.CLIPS \
		      -select "ref_video_id provider duration thumbnail_sha1 thumbnail_width thumbnail_height {lower(substr(title,1,25) || case when length(title)>25 then '...' else '' end) as title}" \
		      -type ::Video \
		      -order "last_update desc" \
		      -limit $video_limit \
		      -load]


div -class pl {
    #h2 -style "background-color:#EBEBFD;color:#49188F;border-style:solid solid none;border-width:1px 1px medium;border-color:#B498DC rgb(219, 210, 243) rgb(219, 210, 243);position:relative;" 
    h2 -style "border-style:solid solid none;border-width:1px 1px medium;border-color:#dddddd #dddddd #dddddd;position:relative;" {
	#img -src http://www.phigita.net/graphics/icon_video.gif ; 
	# 171 (left angle quote) 
	# 187 (right angle quote)
	div -id vprev -class "z-cl-prev" -onclick "hC(-1);" { t -disableOutputEscaping "<"  }
	div -class "z-cl-status" { 
	    span -id vstat0 -onclick "hD(0,2);" -style "color:#49188F;" { t -disableOutputEscaping "o" }
	    span -id vstat1 -onclick "hD(3,5);" { t -disableOutputEscaping "o" }
	    span -id vstat2 -onclick "hD(6,8);" { t -disableOutputEscaping "o" }
	}
	div -id vnext -class "z-cl-next" -onclick "hC(1);" { t -disableOutputEscaping ">"  }
	t " Video" 
    }
    ###div -style "border:1px solid #DBD2F3;overflow:hidden;padding:5px 5px 10px;" 
    div -style "background-color:#f2f2f2;border:1px solid #dddddd;overflow:hidden;padding:0;text-align:center;display:block;width:100%;" {
	div -id vc -class "z-cl" -style "width:294px;margin:0px auto;" {
	    div -class "z-cl-clip-region" -style "width:294px;" {
		ul -class z-cl-list {
		    set video_list ""
		    set count 0
		    foreach o [$latest_video set result] { 
			li -id v$count -style "display:[::util::returnIf "$count>2" "none" "block"];" {

			    lassign [::xo::buzz::getThumbnailDetails $o] thumbnail_url thumbnail_width thumbnail_height
			    #img -src "${imageHost}/${thumbnail_sha1}" -width $thumbnail_width -height $thumbnail_height -border 0
			    a -href "http://video.phigita.net/[$o set ref_video_id].[$o set provider]" {
				div -id vi$count -style "margin:auto;width:${thumbnail_width};height:${thumbnail_height};border:0;background:url(${thumbnail_url});"
			    }
			    br
			    p -class video {
				a -href "http://video.phigita.net/[$o set ref_video_id].[$o set provider]" {
				    t [$o set title]
				}
				br
				t " [VideoDuration [$o set duration]]"
			    }
			}
			lappend video_list "'[::xo::html::cssId v${count}]'"
			incr count
		    }
		}
	    }
	}
    }
    div -style "border-style:none solid solid;border-width:medium 1px 1px;border-color:#dddddd #dddddd #dddddd;font-weight:normal;" {
	div -style "padding:5;" {
	    a -class fl -href "http://video.phigita.net/" {
		t "more video..."
	    }
	}
    }
}



set js {
    VC = {
	vs: 0,
	ve: 2,
	vIC: '#999999',
	vAC: '#49188F',
	init : function() {
	    VC.VP=document.getElementById('vprev');
	    VC.VN=document.getElementById('vnext');
	},
	hC : function (d) {
	    var nvs = VC.vs+(d*VM);
	    if (nvs<0 || nvs >= VL) return;
	    var nve = VC.ve+(d*VM);
	    if (nve<0 || nve >= VL) return;
	    hD(nvs,nve);
	},
	hD : function (nvs,nve) {
	    D = document;
	    if (VC.vs==nvs && VC.ve==nve) return;
	    var max=nve>=VC.vs-1?nve:VC.vs-1;
	    var min=VC.vs<nvs?VC.vs:nvs;
	    for (i=nvs;i<=max;i++) D.getElementById(V[i]).style.display='block';
	    for (i=min;i<nvs;i++) D.getElementById(V[i]).style.display='none';
	    //for (i=nvs;i<=nve;i++) D.getElementById(V[i]).style.display='block';
	    //for (i=VC.vs;i<=VC.ve;i++) D.getElementById(V[i]).style.display='none';
	    if (nve==VL-1){VC.VN.style.color=VC.vIC;}
	    if (nvs==0){VC.VP.style.color=VC.vIC;}
	    if (VC.ve==VL-1){VC.VN.style.color=VC.vAC;}
	    if (VC.vs==0){VC.VP.style.color=VC.vAC;}
	    D.getElementById('vstat'+(VC.vs / VM)).style.color=VC.vIC;
	    D.getElementById('vstat'+(nvs / VM)).style.color=VC.vAC;
	    VC.vs=nvs;
	    VC.ve=nve;
	    return;
	} 
    }
    window['VC']=VC;
    VC['init']=VC.init;
    window['hC']=VC.hC;
    window['hD']=VC.hD;
}
set video_array \[[join $video_list ,]\]
append js "V=${video_array};VL=${video_limit};VM=3;"

#set COMPILED_JS [::xo::js::get_compiled VIDEO.CAROUSEL $JS ADVANCED_OPTIMIZATIONS]

script {
    nt "VC.init();"
}

::xo::html::add_script VIDEO.CAROUSEL js