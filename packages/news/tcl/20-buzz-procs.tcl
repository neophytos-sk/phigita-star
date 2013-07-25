namespace eval ::xo {;}
namespace eval ::xo::buzz {;}
namespace eval ::util {;}

proc ::xo::buzz::video_p {url} {
    set ref_video_id [getVideoID $url]
    return [expr { $ref_video_id ne {} }]
}

#	gv {^http://video.google.com/googleplayer.swf?docid=(-?[0-9]+)(?:&[a-zA-Z0-9_\.\-]+=[a-zA-Z0-9_\.\-]*)*$}

proc ::xo::buzz::getVideoID {url} {
    set ref_video_id ""
    foreach {provider pattern} {
	youtube {^http://www.youtube.com/v/([0-9a-zA-Z_\-]+)(?:&[a-zA-Z0-9_\.\-]+=[a-zA-Z0-9_\.\-]*)*$}
	youtube {^http://youtu.be/([0-9a-zA-Z_\-]+)$}
	vimeo {^http://vimeo.com/([0-9]+)([?]|$)}
	vimeo {^http://vimeo.com/moogaloop.swf[?]clip_id=([0-9]+)(?:&[a-zA-Z0-9_\.\-]+=[a-zA-Z0-9_\.\-]*)*$}
	vodpod {^http://vodpod.com/watch/([0-9]+)(?:-[0-9a-zA-Z_\-]+)*$}
	viddler {^http://www.viddler.com/player/([0-9a-f]+)/$}
	blip-tv {^http://blip.tv/file/([0-9]+).*$}
    } {
	if { [regexp -- ${pattern} $url __match__ ref_video_id] } {
	    return ${ref_video_id}.${provider}
	}
    }
    return
}

# gv {video.google.com} {^videoplay[?]docid=(-?[0-9]+)(?:&[a-zA-Z0-9_\.\-]+=[a-zA-Z0-9_\.\- \%]*)*[\#]?$}
proc ::util::videoIf {url linkVar {idVar ""}} {
    upvar $linkVar link
    if { $idVar ne {} } {
	upvar $idVar id
    }

    set link ""
    array set uri [uri::split $url]
    foreach {provider hosts path_query_regexp} {
	youtube {www.youtube.com uk.youtube.com youtube.com} {^watch[?].*[&]?v=([0-9a-zA-Z_\-]+)[&]?}
	youtube {youtu.be} {^([0-9a-zA-Z_\-]+)$}
	vimeo {www.vimeo.com vimeo.com} {^([0-9]+)(?:[?]|$)}
	vodpod {vodpod.com} {^watch/([0-9]+)(?:-[0-9a-zA-Z_\-]+)*$}
	blip-tv {www.blip.tv blip.tv} {^file/([0-9]+).*$}
    } {
	if { -1 != [lsearch $hosts $uri(host)] && [regexp -- $path_query_regexp "$uri(path)[string trimright ?$uri(query) ?]" _match_ videoId] } {
	    set link [ad_conn protocol]://video.phigita.net/${videoId}.${provider}
	    set id ${videoId}.${provider}
	    return 1
	}
    }
    return 0
}

proc ::xo::buzz::getThumbnailDetails {o} {
    set thumbnail_sha1 [$o set thumbnail_sha1]
    set thumbnail_width [$o set thumbnail_width]
    set thumbnail_height [$o set thumbnail_height]
    if { $thumbnail_sha1 eq {} } {
	set video_image_url http://www.youtube.com/v/[$o set ref_video_id]
	set thumbnail_sha1 [ns_sha1 [::xo::buzz::getVideoImageURL $video_image_url]]
	if {![catch {set image_size [ns_jpegsize ${imageDir}/${imageFile}]}] } {
	    lassign ${image_size} thumbnail_width thumbnail_height
	}
    }
    set imageFile ${thumbnail_sha1}-sample-80x80.jpg
    set imageDir [::util::getDataDir news/images $thumbnail_sha1]
    set imageHost [::util::getStaticHost $thumbnail_sha1 "i" "-buzz"]
    return [list ${imageHost}/${thumbnail_sha1} $thumbnail_width $thumbnail_height]
}


proc ::xo::buzz::getVideoImageURL {url} {
    #http://img.youtube.com/vi/YavVQ7mxjF8/default.jpg
    lassign [split [getVideoID $url] .] clip_id provider
    return http://i.ytimg.com/vi/${clip_id}/0.jpg
    #return http://img.youtube.com/vi/${clip_id}/default.jpg
    ###return [string map {{http://www.youtube.com/v/} {http://img.youtube.com/vi/}} $url]/default.jpg
}


proc ::xo::buzz::getVideoUrl {url} {
    set ref_video_id [getVideoID $url]
    return http://www.youtube.com/v/${ref_video_id}
}


proc ::util::getDataDir {suffix sha1} {
    return [web_root_dir]/data/${suffix}/[string range $sha1 0 1]
}

proc ::xo::buzz::wgetImage {url} {
    ns_log notice "wgetImage url=$url"
    set suffix news/images
    set sha1 [::util::wgetFile ${suffix} $url]
    if { $sha1 ne {} } {
	set imageDir [::util::getDataDir ${suffix} ${sha1}]
	set imageFile ${sha1}-sample-80x80.jpg
	lassign [ns_jpegsize ${imageDir}/${imageFile}] width height
	return [list true ${sha1} ${width} ${height}]
    }
    return [list false]
}


#############

proc ::xo::buzz::getVideo {identifier {fetch_p "true"}} {

    lassign [split $identifier .] clip_id provider

    set provider [::util::coalesce $provider youtube]

    # -pool newsdb 
    set o [::db::Set new \
	       -type ::Video \
	       -where [list \
			   "ref_video_id=[ns_dbquotevalue $clip_id]" \
			   "provider=[ns_dbquotevalue $provider]"]]
    $o load
    if { [$o emptyset_p] } {
	set result "false"
	if {[catch {
	    if { $fetch_p } {
		set result [::xo::buzz::videoFetch.${provider} $clip_id]
	    } else {
		set result false
	    }
	} errmsg]} {
	    ns_log notice "::xo::buzz::getVideo provider=${provider} clip_id=${clip_id} errmsg=$errmsg"
	}
    } else {
	set result [list true [$o head]]
    }
    return $result

}

proc ::xo::buzz::videoEmbed {identifier vo} {
    lassign [split $identifier .] clip_id provider
    set provider [::util::coalesce $provider youtube]
    ::xo::buzz::videoEmbed.${provider} $clip_id $vo
}



proc ::xo::buzz::videoFetch.vimeo {clip_id} {

    #set api_url http://vimeo.com/api/clip/${clip_id}.xml
    set api_url http://vimeo.com/api/v2/video/${clip_id}.xml

    # -pool newsdb
    set vo [::Video new -mixin ::db::Object]
    if {[catch {
	set co [xo::comm::CurlHandle new -url $api_url]
	$co perform
	set docId [dom parse [$co set curlResponseBody]]
	set rootEl [$docId documentElement]
	ns_log notice [$rootEl asXML]
	if { ![$rootEl hasChildNodes] } {
	    ns_log notice "video-one // vimeo rootEl asXML = [$rootEl asXML]"
	    return false
	}

	$vo set ref_video_id $clip_id
	$vo set provider vimeo
	$vo set url  [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='url'])}]]
	$vo set title [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='title'])}]]
	$vo set description [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='description'])}]]
	$vo set duration [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='duration'])}]]
	$vo set tags [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='tags'])}]]
	$vo set thumbnail_url [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='thumbnail_medium'])}]]
	$vo set embed_p t

	$co destroy
	$docId delete

	lassign [::xo::buzz::wgetImage [$vo set thumbnail_url]] ok_p thumbnail_sha1 thumbnail_width thumbnail_height
	if { $ok_p } {
	    $vo set thumbnail_sha1 $thumbnail_sha1
	    $vo set thumbnail_width $thumbnail_width
	    $vo set thumbnail_height $thumbnail_height
	}

	$vo do self-insert {select true}

    } errmsg]} {
	ns_log notice "videoFetch.vimeo errmsg=$errmsg"
    }

    return [list true $vo]
}

proc ::xo::buzz::videoFetch.youtube {clip_id} {

    # -pool newsdb
    set vo [::Video new -mixin ::db::Object]
    if {[catch {

	    #http://www.youtube.com/v/$clip_id
	    #set videoObj [Video new -service YouTube -videoId $clip_id]
	    #$videoObj fetchIf

	    set dev_id IPSDHWTqBr4
	    #set api_url [format "http://www.youtube.com/api2_rest?method=youtube.videos.get_details&dev_id=%s&video_id=%s" $dev_id $clip_id]
	    set api_url [format "http://gdata.youtube.com/feeds/api/videos/%s" $clip_id]
	    set co [xo::comm::CurlHandle new -url $api_url]
	    $co perform

	    if { [$co set curlResponseBody] eq {Invalid id} } {
		return false
	    }
	    set docId [dom parse [$co set curlResponseBody]]
	    set rootEl [$docId documentElement]
	    #if rootEl nodeName 
	    #ns_log notice "video-one // youtube rootEl asXML = [$rootEl asXML]"


	    set url http://www.youtube.com/v/$clip_id

	    $vo set provider youtube
	    $vo set url $url
	    $vo set ref_video_id $clip_id

	    ##$vo set title [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video_details']/*[local-name()='title'])}]]
	    ##$vo set description [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video_details']/*[local-name()='description'])}]]
	    ##$vo set duration  [$docId selectNodes {returnstring(//*[local-name()='video_details']/*[local-name()='length_seconds'])}]
	    ##$vo set tags  [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video_details']/*[local-name()='tags'])}]]
	    ##$vo set thumbnail_url  [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video_details']/*[local-name()='thumbnail_url'])}]]

	    $vo set title [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='title'])}]]
	    $vo set description [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='content'])}]]
	    $vo set duration  [$docId selectNodes {values(//*[local-name()='entry']//*[local-name()='duration']/@seconds)}]
	    $vo set tags  [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='keywords'])}]]
	    $vo set thumbnail_url  [encoding convertfrom utf-8 [$docId selectNodes {values(//*[local-name()='thumbnail']/@url)}]]

	    #set embed_status [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='entry']/*[local-name()='embed_status'])}]]
	    #if { $embed_status eq {ok} } {

	    $vo set embed_p t

	    #} else {
	    #$vo set embed_p f
	    #}




	    #set title [::util::coalesce [$vo set title] Untitled $clip_id]


	    $co destroy
	    $docId delete

	    set thumbnails [$vo set thumbnail_url]
	    foreach image_url $thumbnails {
		lassign [::xo::buzz::wgetImage $image_url] ok_p thumbnail_sha1 thumbnail_width thumbnail_height
		if { $ok_p } {
		    $vo set thumnail_url $image_url
		    $vo set thumbnail_sha1 $thumbnail_sha1
		    $vo set thumbnail_width $thumbnail_width
		    $vo set thumbnail_height $thumbnail_height
		    break
		}
	    }
	    $vo do self-insert {select true}

	} errmsg]} {
	    ns_log notice "errmsg=$errmsg"
	    return false
	}

    return [list true $vo]
}


proc ::xo::buzz::videoFetch.viddler {clip_id} {

    #set api_url http://api.viddler.com/rest/v1/?method=viddler.videos.getDetailsByUrl&api_key=11303a3122f3d2893b4b125054533c9&url=http://www.viddler.com/explore/L337Tech/videos/9/
    set api_key 11303a3122f3d2893b4b125054533c9
    set api_url http://api.viddler.com/rest/v1/?method=viddler.videos.getDetails&api_key=${api_key}&video_id=${clip_id}

    # -pool newsdb
    set vo [::Video new -mixin ::db::Object]
    if {[catch {
	set co [xo::comm::CurlHandle new -url $api_url]
	$co perform
	set docId [dom parse [$co set curlResponseBody]]
	set rootEl [$docId documentElement]
	ns_log notice [$rootEl asXML]
	if { ![$rootEl hasChildNodes] } {
	    ns_log notice "video-one // vimeo rootEl asXML = [$rootEl asXML]"
	    return false
	}

	$vo set ref_video_id $clip_id
	$vo set provider viddler
	$vo set url  [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='url'])}]]
	$vo set title [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='title'])}]]
	$vo set description [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='description'])}]]
	$vo set duration [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='length_seconds'])}]]
	$vo set tags [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='tags'])}]]
	$vo set thumbnail_url [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='thumbnail_url'])}]]
	$vo set embed_p t

	$co destroy
	$docId delete

	lassign [::xo::buzz::wgetImage [$vo set thumbnail_url]] ok_p thumbnail_sha1 thumbnail_width thumbnail_height
	if { $ok_p } {
	    $vo set thumbnail_sha1 $thumbnail_sha1
	    $vo set thumbnail_width $thumbnail_width
	    $vo set thumbnail_height $thumbnail_height
	}

	$vo do self-insert {select true}

    } errmsg]} {
	ns_log notice "videoFetch.viddler clip_id=$clip_id errmsg=$errmsg"
    }

    return [list true $vo]
}



proc ::xo::buzz::videoFetch.blip-tv {clip_id} {

    set api_url http://blip.tv/file/${clip_id}?skin=rss

    # -pool newsdb
    set vo [::Video new -mixin ::db::Object]
    if {[catch {
	set co [xo::comm::CurlHandle new -url $api_url]
	$co perform
	set docId [dom parse [$co set curlResponseBody]]
	set rootEl [$docId documentElement]
	ns_log notice [$rootEl asXML]
	if { ![$rootEl hasChildNodes] } {
	    ns_log notice "video-one // vimeo rootEl asXML = [$rootEl asXML]"
	    return false
	}

	$vo set ref_video_id $clip_id
	$vo set provider blip-tv
	$vo set url  [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='item']/*[local-name()='link'])}]]
	$vo set title [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='item']/*[local-name()='title'])}]]
	$vo set description [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='item']/*[local-name()='description'])}]]
	$vo set duration [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='item']/*[local-name()='runtime'])}]]
	$vo set tags [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='item']/*[local-name()='category'])}]]
	$vo set thumbnail_url [encoding convertfrom utf-8 [$docId selectNodes {values(//*[local-name()='item']/*[local-name()='thumbnail']/@url)}]]
	dict set extra embedLookup [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='item']/*[local-name()='embedLookup'])}]]
	$vo set extra $extra			
	$vo set embed_p t

	$co destroy
	$docId delete

	lassign [::xo::buzz::wgetImage [$vo set thumbnail_url]] ok_p thumbnail_sha1 thumbnail_width thumbnail_height
	if { $ok_p } {
	    $vo set thumbnail_sha1 $thumbnail_sha1
	    $vo set thumbnail_width $thumbnail_width
	    $vo set thumbnail_height $thumbnail_height
	}

	$vo do self-insert {select true}

    } errmsg]} {
	ns_log notice "videoFetch.blip-tv clip_id=$clip_id errmsg=$errmsg"
    }

    return [list true $vo]
}





proc ::xo::buzz::videoFetch.vodpod {clip_id} {

    set api_url http://api.vodpod.com/api/video/details.xml?api_key=fcedc6a2baa74d66&video_id=Video.${clip_id}

    # -pool newsdb
    set vo [::Video new -mixin ::db::Object]
    if {[catch {
	set co [xo::comm::CurlHandle new -url $api_url]
	$co perform
	set docId [dom parse [$co set curlResponseBody]]
	set rootEl [$docId documentElement]
	ns_log notice [$rootEl asXML]
	if { ![$rootEl hasChildNodes] } {
	    ns_log notice "video-one // vodpod rootEl asXML = [$rootEl asXML]"
	    return false
	}

	$vo set ref_video_id $clip_id
	$vo set provider vodpod
	$vo set url  [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='link'])}]]
	$vo set title [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='title'])}]]
	$vo set description [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='description'])}]]
	$vo set duration "" ;#[encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='duration'])}]]
	$vo set tags [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='tags'])}]]
	$vo set thumbnail_url [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='thumbnails']/*[local-name()='large'])}]]
	$vo set embed_host [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='embed_host'])}]]
	$vo set redirect_p [::xo::buzz::videoFetchArgs.vodpod ${embed_host} ${embed_tag} embedArgs]
	$vo set embed_p t

	$co destroy
	$docId delete

	lassign [::xo::buzz::wgetImage [$vo set thumbnail_url]] ok_p thumbnail_sha1 thumbnail_width thumbnail_height
	if { $ok_p } {
	    $vo set thumbnail_sha1 $thumbnail_sha1
	    $vo set thumbnail_width $thumbnail_width
	    $vo set thumbnail_height $thumbnail_height
	}

	### HERE - TODO: Redirect URL / Embed Tag
	### $vo do self-insert {select true}

    } errmsg]} {
	ns_log notice "videoFetch.vimeo errmsg=$errmsg"
    }

    return [list true $vo]
}


proc ::xo::buzz::videoFetch.gv {clip_id} {
    return false

    set api_url http://video.google.com/videoplay?docid=${clip_id}

    # -pool newsdb
    set vo [::Video new -mixin ::db::Object]
    if {[catch {
	set co [xo::comm::CurlHandle new -url $api_url]
	$co perform
	set html [$co set curlResponseBody]
	set docId [dom parse -simple -keepEmpties [::htmltidy::tidy "<html>${html}</html>"]]
	set rootEl [$docId documentElement]
	if { ![$rootEl hasChildNodes] } {
	    ns_log notice "video-one // googlevideo rootEl asXML = [$rootEl asXML]"
	    return false
	}

ns_log notice html=$html

	$vo set ref_video_id $clip_id
	$vo set provider gv
	$vo set url  $api_url
	$vo set title [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='title'])}]]
	$vo set description [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='p' and @id="video-desc"])}]]
	# "- 1:50:29 - May 8, 2007" 
	#set duration [lindex [split [encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='span' and @id="video-duration"])}]] -] 1]
	set duration [string trim [$docId selectNodes {returnstring(//*[local-name()='span' and @id="video-duration"])}] \xa0]
	ns_log notice "videoFetch.gv duration=$duration"
	$vo set duration [::util::duration_to_secs $duration]
	$vo set tags "" ;#[encoding convertfrom utf-8 [$docId selectNodes {returnstring(//*[local-name()='video']/*[local-name()='tags'])}]]
	set thumbnail_url ""
	regexp -- {\\x26thumbnailUrl\\x3d(http://[a-z0-9\.]+/ThumbnailServer2[^\\]+)\\x26} $html __match__ thumbnail_url
	$vo set thumbnail_url [ns_urldecode $thumbnail_url]
	$vo set embed_host ""
	$vo set redirect_p "f"
	$vo set embed_p t

	$co destroy
	$docId delete

	lassign [::xo::buzz::wgetImage [$vo set thumbnail_url]] ok_p thumbnail_sha1 thumbnail_width thumbnail_height
	if { $ok_p } {
	    $vo set thumbnail_sha1 $thumbnail_sha1
	    $vo set thumbnail_width $thumbnail_width
	    $vo set thumbnail_height $thumbnail_height
	}

	$vo do self-insert {select true}
	#ns_log notice "googlevideo: thumbnail_url=$thumbnail_url"

    } errmsg]} {
	ns_log notice "videoFetch.gv errmsg=$errmsg"
    }

    return [list true $vo]
}

proc ::xo::buzz::videoEmbedHosts.vodpod {} {
    return {youtube.com vimeo.com viddler.com flickr.com blip.tv}
}

proc ::xo::buzz::videoFetchArgs.vodpod {embed_host embed_tag embedArgsVar} {
    upvar $embedArgsVar embedArgs 
    foreach host [::xo::buzz::videoEmbedHosts.vodpod] {
	if { ${host} eq ${embed_host} } {
	    return t ;# redirect to original provider
	}
    }
    set embedArgs [list embed_tag $embed_tag]
    return 
}

proc ::xo::buzz::videoEmbed.youtube {clip_id vo} {
    set url http://www.youtube.com/v/$clip_id

    require_html_procs

    ::html::object -width "425" -height "350" {
	param -name "movie" -value $url
	param -name "wmode" -value "transparent"
	embed -src $url -type "application/x-shockwave-flash" -wmode "transparent" -width "425" -height "350"
    }
}

proc ::xo::buzz::videoEmbed.vimeo {clip_id vo} {
    require_html_procs
    ::html::object -width "500" -height "375" {
	param -value "true" -name "allowfullscreen"
	param -value "always" -name "allowscriptaccess"
	param -value "http://vimeo.com/moogaloop.swf?clip_id=${clip_id}&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=00ADEF&amp;fullscreen=1" -name "movie"
	embed -width "500" -height "375" -allowscriptaccess "always" -allowfullscreen "true" -type "application/x-shockwave-flash" -src "http://vimeo.com/moogaloop.swf?clip_id=${clip_id}&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=00ADEF&amp;fullscreen=1"
    }
}


proc ::xo::buzz::videoEmbed.viddler {clip_id vo} {
    require_html_procs
    ::html::object -classid "clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" -width "437" -height "288" -id "viddler" {
	param -name "movie" -value "http://www.viddler.com/player/${clip_id}/"
	param -name "allowScriptAccess" -value "always"
	param -name "allowFullScreen" -value "true"
	embed -src "http://www.viddler.com/player/${clip_id}/" -width "437" -height "288" -type "application/x-shockwave-flash" -allowScriptAccess "always" -allowFullScreen "true" -name "viddler"
    }
}

proc ::xo::buzz::videoEmbed.blip-tv {clip_id vo} {
    # embed_lookup sample = g8cbgZWWJgI
    set embedLookup [dict get [$vo set extra] embedLookup]
    embed -src "http://blip.tv/play/${embedLookup}" -type "application/x-shockwave-flash" -width "480" -height "414" -allowscriptaccess "always" -allowfullscreen "true"
}

proc ::xo::buzz::videoEmbed.vodpod {clip_id vo} {
}

proc ::xo::buzz::videoEmbed.gv {clip_id vo} {
    embed -id "VideoPlayback" -src "http://video.google.com/googleplayer.swf?docid=${clip_id}&hl=en&fs=true" -style "width:400px;height:326px;" -allowFullScreen true -allowScriptAccess always -type application/x-shockwave-flash
}
