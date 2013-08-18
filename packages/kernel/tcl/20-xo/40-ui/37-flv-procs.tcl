Class ::xo::ui::FLV=Progressive -superclass {::xo::ui::Widget} 

::xo::ui::FLV=Progressive instproc render {visitor} {
    my instvar filename path image

    #set visitor [self callingobject]
    $visitor ensureLoaded XO.SWF
    $visitor ensureNodeCmd elementNode div

    set base http://[ad_host][ns_conn url]
    set flv_file_uri [my uri -base ${base} -select [my domNodeId] -action returnFLV]
    set flv_stream_uri [my uri -base ${base} -select [my domNodeId] -action streamFLV]

    set image_uri [my uri -base ${base} -select [my domNodeId] -action returnImage]
    set image_uri  [string map {? {%3f} = {%3d} & {%26}} $image_uri]

    set flv_file_uri [string map {? {%3f} = {%3d} & {%26}} $flv_file_uri]
    set flv_stream_uri [string map {? {%3f} = {%3d} & {%26}} $flv_stream_uri]

    set flv_file $flv_file_uri
    #set flv_file $flv_stream_uri 
    #set flv_file http://my.phigita.net/gallery/playlist2.xml

    ### WORKS OK - Streaming needs some work ##
    set player_uri http://www.phigita.net/lib/xo-1.0.0/players/flv-3.12/flvplayer.swf


    ### WORKS OK - NEEDS vidFile, vidPosition vidID in streamFLV - GOT IT FROM Coldfusion ###
    ### http://www.realitystorm.com/_interface/common/flash/streamFLVfeed.zip
#    set player_uri http://www.phigita.net/lib/xo-1.0.0/streamFLVplayer.swf
    set streamerURL $flv_stream_uri
    ###

#    set player_uri /__tests/test-templating/test-flv/tmp/scrubber.swf
#    set player_uri /__tests/test-templating/test-flv/tmp/phpsflvplayer.swf
#    set player_uri /__tests/test-templating/test-flv/tmp/TitaniumSP_320x240.swf
#    set flv_file_uri golfers.flv
#    set flv_stream_uri /__tests/test-templating/test-flv/b-streamFLV

    $visitor inlineJavascript [subst -nobackslashes {
	var [my domNodeId] = function(){
	    return {
		init : function() {
		    var so = new SWFObject('${player_uri}','p_[my domNodeId]','320','260','7');
		    so.addParam("allowfullscreen","false");
		    so.addVariable("file",'${flv_file}');
//		    so.addVariable("autostart","false");
		    so.addVariable("shuffle","false");
//		    so.addVariable("start","0");

		    so.addVariable("backcolor","0x000000");
		    so.addVariable("frontcolor","0xCCCCCC");
		    so.addVariable("lightcolor","0xFF7722"); 

		    so.addVariable("bufferlength","[my bufferlength]");
//		    so.addVariable("usefullscreen","false");
		    so.addVariable("image","${image_uri}");

//		    so.addVariable("logo","[my logo]");
//		    so.addVariable("link","[my link]");

		    so.addVariable("type","flv");
		    so.addVariable("showdigits","false");

		    //so.addVariable("linkfromdisplay","[my linkfromdisplay]");
//		    so.addVariable("linktarget","[my linktarget]");

		    //if(id != '') { so.addVariable("id",id); }
// 		    so.addVariable("streamscript",'lighttpd');

// HERE 		    so.addVariable("vidID",1);
// HERE 		    so.addVariable("vidFile",'${flv_file}');
// HERE 		    so.addVariable("streamerURL",'${streamerURL}');


		    so.write('[my domNodeId]');
		}
	    }
	}();
    }]
    $visitor onReady [my domNodeId].init [my domNodeId] true
    
    [next] appendFromScript {
	set node [div -id [my domNodeId]]
    }
    return $node
}



::xo::ui::Class ::xo::ui::MP3 -superclass {::xo::ui::Widget} -parameter {
    {filename ""}
    {path "[acs_root_dir]/www/__tests/admin/test-templating/test-flv"}
    {image ""}
    {title ""}
    {creator ""}
    {identifier ""}
    {image_type "image/jpeg"}
    {thumbsinplaylist ""}
    {more_info ""}
    {displaywidth "120"}
}

::xo::ui::MP3 instproc action(returnMP3) {marshaller} {
    set mp3Target [my path]/[my filename]
    ns_returnfile 200 audio/mpeg $mp3Target
}

::xo::ui::MP3 instproc action(returnImage) {marshaller} {
    set imageTarget [file normalize [my path]/[my image]]
    if { ![file exists $imageTarget] } {
	set imageTarget /web/data/graphics/audio.gif
    }
    ns_returnfile 200 [::util::coalesce [my image_type] [ns_guesstype $imageTarget]] $imageTarget
}


::xo::ui::MP3 instproc action(returnXML) {marshaller} {
    my instvar domNodeId title identifier creator more_info

    set base "./"
    set mp3_file [my uri -base ${base} -select $domNodeId -action returnMP3]
    set image_uri [my uri -base ${base} -select $domNodeId -action returnImage]
    set image_uri  [string map {? {%3f} = {%3d} & {%26}} $image_uri]
    set thetitle [::util::coalesce $title "Untitled $identifier"]

    ns_return 200 text/xml [subst -nocommands -nobackslashes {<playlist version="1" xmlns="http://xspf.org/ns/0/">
	<trackList>

	<track>
	<title>${thetitle}</title>
	<creator>${creator}</creator>
	<location>${mp3_file}</location>
	<image>${image_uri}</image>
	<info>${more_info}</info>
	<identifier>${identifier}</identifier>
	</track>

	</trackList>
	</playlist>
    }]
}


::xo::ui::MP3 instproc render {visitor} {


    my instvar filename path domNodeId thumbsinplaylist displaywidth

    $visitor ensureLoaded XO.SWF
    $visitor ensureNodeCmd elementNode div

    set base http://[ad_host][ns_conn url]
    
    set mp3_file [my uri -base ${base} -select $domNodeId -action returnXML]
    #set mp3_file [my uri -base ${base} -select $domNodeId -action returnMP3]


    set player_uri http://www.phigita.net/lib/xo-1.0.0/players/mp3_player/mp3player.swf


    $visitor inlineJavascript [subst -nobackslashes -nocommands {
	var ${domNodeId} = function(){
	    return {
		init : function() {
		    var so = new SWFObject('${player_uri}','p_${domNodeId}','300','140','7');
		    so.addVariable("file",'${mp3_file}');
		    so.addVariable("thumbsinplaylist",'${thumbsinplaylist}');
		    so.addVariable('displaywidth','${displaywidth}');
		    so.addVariable("backcolor","0x000000");
		    so.addVariable("frontcolor","0xCCCCCC");
		    so.addVariable("lightcolor","0xFF7722"); 
		    so.write('${domNodeId}');
		}
	    }
	}();
    }]
    $visitor onReady ${domNodeId}.init ${domNodeId} true
    
    [next] appendFromScript {
	set node [div -id [my domNodeId]]
    }
    return $node
}




Class ::xo::ui::FLV -superclass {::xo::ui::Widget} -parameter {
    {filename "golfers.flv"}
    {path "[acs_root_dir]/www/__tests/admin/test-templating/test-flv"}
    {bytes_per_timeframe 30000}
    {bufferlength 3}
    {image ""}
    {logo "http://www.phigita.net/graphics/phigita-tv-2"}
    {link "http://www.phigita.net/"}
    {linktarget "_blank"}
    {linkfromdisplay "false"}
    {showdigits "false"}
    {image_type "image/png"}
    {vidID ""}
} -instmixin ::xo::ui::ControlTrait


::xo::ui::FLV instmixin ::xo::ui::FLV=Progressive

#::xo::ui::FLV instmixin  ::xo::ui::FLV=PseudoStreaming
#::xo::ui::FLV instmixin  ::xo::ui::FLV=PseudoStreaming-3.12

#streaming requires adobe flash media server


::xo::ui::FLV instproc action(returnImage) {marshaller} {
    set imageTarget [file normalize [my path]/[my image]]
    ns_returnfile 200 [::util::coalesce [my image_type] [ns_guesstype $imageTarget]] $imageTarget
}


::xo::ui::FLV instproc action(returnFLV) {marshaller} {
    #set videoTarget [my queryget -select [my domNodeId] -action returnFLV videoTarget]
    #if { $videoTarget eq {} } {
    #}
    set videoTarget [file normalize [my path]/[my filename]]
    ns_returnfile 200 video/x-flv $videoTarget

}

::xo::ui::FLV instproc action(returnImage) {marshaller} {
#    set imageTarget [my queryget -select [my domNodeId] -action returnImage imageTarget]
    set imageTarget [file normalize [my path]/[my image]]
    ns_returnfile 200 [::util::coalesce [my image_type] [ns_guesstype $imageTarget]] $imageTarget
}


::xo::ui::FLV instproc action(streamFLV) {marshaller} {

    my instvar bytes_per_timeframe
    #ns_log notice "stream.tcl working... [ns_conn url] query=[ns_conn query]"
    set setId [ns_getform]

    set position [ns_set iget $setId pos]
    set filename [ns_set iget $setId file]



    if { $filename eq "" } {
	#set filename [ns_set iget $setId vidFile]
	set filename [my path]/[my filename]
    }

    if { $position eq "" } {
	set position [ns_set iget $setId vidPosition]
    }

    if { $position eq "" } {
	set position [ns_set iget $setId start]
    }


    if { $position eq "" } {
	set position 0
    }


    ns_log notice "position=$position filename=$filename"

    ad_streamfile_background 200 video/x-flv $filename $position
    return


    set fp [open $filename]
    # This is guaranteed to work with binary data but
    # may fail with other encodings...


    ns_write "HTTP/1.0 200 OK\r\nContent-Type: video/x-flv\r\n\r\n"
    fconfigure $fp -translation binary
    if { $position > 0 } {
	ns_write "FLV\x1\x1\0\0\0\x9\0\0\0\x9"
    }


    seek $fp $position

    if {1} {
	while {![eof $fp]} {
	    ns_write [read $fp $bytes_per_timeframe]
	    #after 1200
	}
	close $fp
    } else {
	while {![eof $fp]} {
	    ns_connsendfp $fp $bytes_per_timeframe
	}
	#ns_returnfp 200 video/x-flv $fp [expr {[file size $filename]-$position}]
    }
    
}

proc ::xo::ui::Cleanup {in out bytes {error {}}} {
    global total
    set total $bytes
    close $in
    #close $out
    if {[string length $error] != 0} {
	# error occurred during the copy
	ns_log notice "flv fcopy error = $error"
    }
}
