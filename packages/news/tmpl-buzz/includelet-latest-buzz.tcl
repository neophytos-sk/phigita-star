::xo::html::add_style {
    .bz_details {
	font-size:x-small;
    }
}
set string_length 15
set limit 3
set storydata [::db::Set new \
		   -pool newsdb \
		   -select "* {substr(title,0,100) as title} {substr(last_crawl_content,0,100) as last_crawl_content}" \
		   -alias story \
		   -type ::sw::agg::Url \
		   -where [list "buzz_p" "language='el'"] \
		   -order "creation_date desc" \
		   -limit ${limit}]
$storydata load


div -class pl {
    h2 -style "background-color:#FFEAC0;color:#D2501E;border-style:solid solid none;border-width:1px 1px medium;border-color:#F29F3E rgb(251, 212, 153) rgb(251, 212, 153);" {	
	#img -src /graphics/icon_buzz.gif -width 16 -height 16
	t [mc Buzz "Buzz"]
    }
    div -style "border:1px solid #FBD499;overflow:hidden;padding:2 10;" {
	div -class "tl s"  {
	    t "\"[mc monitor_syndicated_content "Monitor syndicated content."]\""
	}


	ul -style "list-style-type:none;padding:0;" {

	    foreach story [${storydata} set result] {
		li -style "padding:5" {
		    array set uri [uri::split [${story} set url]]
		    div -clear both

		    if { [lindex [$story set image_file] 0] ne {} } {
			set imageFile [lindex [$story set image_file] 0]-sample-80x80.jpg
			set imageDir [web_root_dir]/data/news/images/[string range $imageFile 0 1]

			if {![catch {set image_size [ns_jpegsize ${imageDir}/${imageFile}]}] } {
			    foreach {width height} $image_size break
			    set story_image_file [lindex [$story set image_file] 0]
			    set imageHost [::util::getStaticHost $story_image_file "i" "-buzz"]
			    a -rel nofollow -href "http://buzz.phigita.net/ct?s=[$story set url_sha1]" -class "t ni" -title [$story set title] {
				img -src "${imageHost}/${story_image_file}" -width $width -height $height -align right -style "border:1px solid;"
			    }
			}
		    }
		    a -rel nofollow -href "http://buzz.phigita.net/ct?s=[${story} set url_sha1]" -class "t ni" {
			t -disableOutputEscaping [::textutil::adjust [::util::coalesce [string totitle [string trim [util::striphtml [${story} set title]]]] Untitled] -length ${string_length} -strictlength true]
		    }

		    ### Video Icon
		    if { [$story set object_list] ne {} } {
			t " "
			lassign [lindex [$story set object_list] 0] video_id video_image_file
			a -href "http://buzz.phigita.net/video/${video_id}" -style "text-decoration:none;border:0;" {
			    img -src "http://www.phigita.net/graphics/icon_video.gif" -alt {[video]} -width 19 -height 12 -border 0
			}
		    }
		    div -class bz_details { t [::textutil::adjust [$story set last_crawl_content] -length 40 -strictlength true] }
		    div -style "margin-left:5;" {
			#img -src http://www.phigita.net/graphics/theme/azure/bracket.gif -width 7 -height 11
			#t -disableOutputEscaping " "
			set host [regsub -- {^www\.} $uri(host) {}]
			nt "<span class=domain><a href=\"buzz/?host=$uri(host)\">[::textutil::adjust ${host} -length 40 -strictlength true]</a></span> "
			
			set count_tags [llength [$story set tags]]
			if { $count_tags } {
			    div -class tags {
				t ", tags:  "
				set index_i 1
				foreach storyTag [$story set tags] {
				    set Tag [string map {/ "_"} "$storyTag"]
				    if { $Tag ne {} || [string length $Tag] ==1} {
					set normalized_tag [string trim [regsub -all -- {(_){2,}} [string map {{ } {_} {!} {_} {/} {} {:} {_} {-} {_} {;} {_} {&} {_}} [string totitle [::util::dequotehtml $storyTag]]] {_}] { _}]
					span -class tag {
					    a -class label -href [export_vars -base http://buzz.phigita.net/tag/$normalized_tag] {
						t [::util::dequotehtml $Tag]
					    }
					}
				    }
				    if { $count_tags != $index_i } {
					t ", "
				    }
				    incr index_i
				}
			    }
			}
		    }
		}
	    }
	}
	a -class "fl s i" -href "http://buzz.phigita.net/" {
	    t "more buzz..."
	}
	t " \["
	a -class "fl s i" -href "http://buzz.phigita.net/tag/" {
	    t "Tags"
	}
	t "\]"
    }
}