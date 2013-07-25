set path [acs_root_dir]/packages/maps/lib/
source ${path}/config.tcl

ad_page_contract {
	@author Neophytos Demetriou
} {
    ll:trim,notnull,optional
    {s:integer,notnull,optional 300000}
}


set nScale $s
if { ${nScale} > [lindex ${anScales} 0] } {
    set nScale [lindex ${anScales} 0]
}

## find closest valid scale (that is larger than this one)
foreach theScale [lreverse ${anScales}] {
    if { ${nScale} <= ${theScale} } {
        set nScale ${theScale}
        break;
    }
}


set map_url iframe-map
if { [info exists ll] } {
    lassign [split $ll {,}] lon lat
    if { [string is double -strict $lon] && [string is double -strict $lat] } {
	append map_url "?ll=${ll}&s=${nScale}"
    }
}



tmpl::master -title "Maps" -context_bar [ad_context_bar] {

    iframe -src $map_url -width 640 -height 480

    set comment {
	div -style "margin-left:200px;width:250;padding:5 5 5 5;border:1px dashed #efefef;" {
                t -disableOutputEscaping {
                    <script type="text/javascript"><!--
                    google_language = 'en';
                    google_encoding = 'utf-8';
                    google_country = 'gr';
                    google_ad_client = "pub-1374549828513817";
                    google_alternate_color = "ffffff";
                    google_ad_width = 234;
                    google_ad_height = 60;
                    google_ad_format = "234x60_as";
                    google_ad_type = "text";
                    google_ad_channel = "";
                    //--></script>
                    <script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js"></script>
                }
	}
    }


}