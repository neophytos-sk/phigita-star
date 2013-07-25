set limitTags 150

### Generate Tag Cloud

# Step 1 - Get a list tags, and their frequency

set conn [DB_Connection new -pool newsdb]
set popularTags [$conn query "select ln(occurrence) as occurrence,itemset_tags from xo.xo__buzz_itemset_tags where itemset_size=1 order by occurrence desc limit $limitTags"]

# Step 2 - Find the Max and Min frequency

set maxOcc [[lindex $popularTags 0] set occurrence]
set minOcc [[lindex $popularTags end] set occurrence]

#Step 3 - Find the difference between max and min, and the distribution

set diffOcc [expr { $maxOcc - $minOcc }]
set distOcc [expr { (1.0+$diffOcc) / 5.0 }]

# Step 4 - Sort by name

set tagCloudList [lsort -command [list ::util::__ObjectSlotCompare itemset_tags] $popularTags]

# Step 5 - Loop over the tags, and output with size


set base .

tmpl::master -title "Buzz Tag Cloud" -context_bar [ad_context_bar "Tag Cloud"] {

    style {
	c {
	    .tagCloud {padding:5 0 5 0;margin:10 10 10 10;list-style-type:none;text-align:center;width:600;}
	    .tagCloud li {display:inline;padding:0;margin:0;font-weight:bold;line-height:1.75em;}
	    .tagCloud li a {color:#4261DF;}
		
		.tagCloud a.s0 { font-size: 1em; }
		.tagCloud a.s1 { font-size: 1.4em; }
		.tagCloud a.s2 { font-size: 1.7em; } 
		.tagCloud a.s3 { font-size: 2.1em; }
		.tagCloud a.s4 { font-size: 2.5em; }
	    }
	}
    ul -class tagCloud {
	foreach o $tagCloudList {
	    set occ [$o set occurrence]
	    set tagClass "s[expr { int(double($occ - $minOcc)/double($distOcc)) }]"
	    li {
		#set targetTag [::util::ldiff [string map {{/} { } {:} { } {-} { } {;} { } {&} { }} [$o set itemset_tags]] [string tolower [string map {{_} { }} $tag]]]
		set targetTag [string map {{/} { } {:} { } {-} { } {;} { } {&} { }} [$o set itemset_tags]]
		set normalizedTag [string map {{ } {_}} [string trim [string totitle $targetTag]]]
		a -class $tagClass -href [export_vars -base $base/$normalizedTag] {
		    t [string trim $targetTag]
		}
		t -disableOutputEscaping " &nbsp; "
		#span -class occ { t "([$o set occurrence])" }
	    }
	}
    }
	div -style "width:600;" {
	    center {
		t -disableOutputEscaping {
		    <script type="text/javascript"><!--
google_language = 'en';
google_encoding = 'utf-8';
google_ad_client = "pub-1374549828513817";
google_alternate_color = "ffffff";
google_ad_width = 468;
google_ad_height = 60;
google_ad_format = "468x60_as";
google_ad_type = "text_image";
google_ad_channel = "7682154683";
		    //--></script>
<script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js"></script>
		}
	    }
	}



}

$conn destroy