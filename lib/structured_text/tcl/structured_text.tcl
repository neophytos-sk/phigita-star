package require uri

::xo::lib::require html_procs

namespace eval ::xo::structured_text {;}

proc ::xo::structured_text::video_if {url linkVar {idVar ""}} {
    upvar $linkVar link
    if { $idVar ne {} } {
        upvar $idVar id
    }

    set link ""
    array set uri [uri::split $url]
    foreach {provider hosts path_query_regexp} {
	youtube {youtu.be} {([0-9a-zA-Z_\-]+)}
        youtube {www.youtube.com uk.youtube.com youtube.com} {^watch[?]v=([0-9a-zA-Z_\-]+)[&]?}
        vimeo {www.vimeo.com vimeo.com} {^([0-9]+)(?:[?]|$)}
        vodpod {vodpod.com} {^watch/([0-9]+)(?:-[0-9a-zA-Z_\-]+)*$}
        blip-tv {www.blip.tv blip.tv} {^file/([0-9]+).*$}
        gv {video.google.com} {^videoplay[?]docid=(-?[0-9]+)(?:&[a-zA-Z0-9_\.\-]+=[a-zA-Z0-9_\.\- \%]*)*[\#]?$}
    } {
        if { -1 != [lsearch $hosts $uri(host)] && [regexp -- $path_query_regexp "$uri(path)[string trimright ?$uri(query) ?]" _match_ videoId] } {
            set link [ad_conn protocol]://video.phigita.net/${videoId}.${provider}
            set id ${videoId}.${provider}
            return 1
        }
    }
    return 0
}

proc ::xo::structured_text::transform_embed {configVar node url align} {

    set clip_id ""
    if { [::xo::structured_text::video_if $url link clip_id] } {
	::xo::media::embed_video $clip_id true ;# true here means try to fetch the video (if not found in db)
    }
}


proc ::xo::structured_text::transform_video {configVar node clip_id align} {

    ::xo::media::embed_video $clip_id true ;# true = try to fetch the video if not found in db

}


proc ::xo::structured_text::transform_image {configVar node image_id align} {

    if { $configVar ne {} } {
	upvar $configVar config
    }

    set root                $config(root)
    set container_object_id $config(container_object_id)
    set image_prefix        $config(image_prefix)

    ###

    set seconds [clock seconds]
    set secret_token [ns_sha1 sEcReT-iMaGe-${root}-${image_id}-${seconds}-${container_object_id}]
    set image_url "${image_prefix}${image_id}-${secret_token}-${seconds}-${container_object_id}"

    set caption [join [::xo::fun::map x [$node childNodes] {$x asHTML}] " "]
    set align [::util::coalesce ${align} "center"]
    ::html::div -style "text-align:center;" {
	::html::a -href "${image_url}-s800" {
	    ::html::img -src "${image_url}-s500" -class "z-align-${align}" -identifier "${image_id}" -border "0"
	}
	if { $caption ne {} } {
	    ::html::div -class "z-image-caption" -style "text-align:${align}" { ::html::nt ${caption} }
	}
    }

    ##::xo::html::embed_video $clip_id
}

proc ::xo::structured_text::transform_hr {configVar node} {

    div -style "width:100%;text-align:center;margin:10 0 10 0;" { 
	::html::img -style "width:100px;height:1px;margin:5 0 5 0;background:#000;"
	::html::img -src "/graphics/divider.png" -width "55" -height "12" -style "margin:0 5 0 5;"
	::html::img -style "width:100px;height:1px;margin:5 0 5 0;background:#000;"
    }
}

proc ::xo::structured_text::transform_pre {configVar node} {
    pre {
	nt [$node asText]
    }
}

#    {//pre}       ::xo::structured_text::transform_pre   {}
#    {//hr}        ::xo::structured_text::transform_hr    {}
variable ::xo::structured_text::transform_spec {
    128 {//__image__} ::xo::structured_text::transform_image {id align}
    256 {//__video__} ::xo::structured_text::transform_video {id align}
    512 {//__embed__} ::xo::structured_text::transform_embed {url align}
}


proc ::xo::structured_text::init_css {} {
    ::xo::html::iuse {z-pre z-code z-bold z-italic z-highlight z-image-caption}
}

proc ::xo::structured_text::init_css_for_tweb {} {
    css {
	.z-bold {font-weight:bold;}
	.z-italic {font-style:italic;}
	.z-highlight {background:#dee7ec;}
	.z-align-left {display:block;margin-right:auto;}
	.z-align-right {display:block;margin-left:auto;}
	.z-align-center {display:block;margin:0pt auto;}
	.z-image-caption {font-style:italic;color:#666666;}
	.z-pre {font-family:"Arial Unicode MS",Arial; padding: 1em; border: 1px solid #8cacbb; color: Black; background-color: #dee7ec;}
	.z-code {
	    background-color: #feffca;
	    border:1px dashed #999;
	    color: #333;
	    font-family: "Courier New", Courier, monospace;
	    margin: 1em 0 2em;
	    padding:0.5em;
	    overflow-x: auto;
	    white-space:pre-wrap;
	    white-space: -moz-pre-wrap !important;
	    white-space: -pre-wrap;
	    white-space: -o-pre-wrap;
	    width:99%;
	    word-wrap:break-word;
	}
    }
    ::xo::tdp::excludeClassesFromRenaming {
	z-bold z-italic z-highlight
	z-image-caption z-align-left z-align-right z-align-center
	z-pre z-code
    }
}

### array set config [list root "814" container_object_id "1112" image_prefix "/~k2pts/blog/image"]
proc ::xo::structured_text::stx_to_html {configVar textVar {resultVar ""}} {

    require_html_procs

    ::xo::structured_text::init_css

    upvar $configVar config

    upvar $textVar text
    if { $resultVar ne {} } {
	upvar $resultVar result
    }

    set outflags [::xo::structured_text::__stx_to_html text html] ;# we will call our C++ library here


    set doc [dom parse -simple -keepEmpties -paramentityparsing never "<div>${html}<div>"]

    foreach {required_flag match action attrs} $::xo::structured_text::transform_spec {
	if { $outflags & $required_flag } {
	    #ns_log notice "stx_to_html: selectNodes $match (outflags=$outflags say we can)"
	    set nodes [$doc selectNodes $match]
	    foreach node $nodes {
		set parent [$node parentNode]
		set args [list]
		foreach attr $attrs {
		    lappend args [$node getAttribute $attr ""]
		}

		$parent insertBeforeFromScript {
		    $action config $node {*}${args}
		} $node
		$node delete
	    }
	}
    }

    set result [$doc asHTML]
    $doc delete
    return
}

proc ::xo::structured_text::minitext_to_html {text} {

    require_html_procs

    ::xo::structured_text::init_css

    set html ""
    ::xo::structured_text::__mtx_to_html text html
    return $html
}
