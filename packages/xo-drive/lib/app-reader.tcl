#source [acs_root_dir]/packages/kernel/tcl/0000-utils/30-JS-procs.tcl

ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer
    {p:integer 1}
    {size 800}
    {q ""}
}


set base [::xo::kit::pvt_home_url]

#set size 500

set pathexp [list "User [ad_conn user_id]"]
set data [::db::Set new \
	      -pathexp $pathexp \
	      -select {
		  id 
		  title 
		  {extra->'XO.File.Type' as filetype} 
		  {extra->'XO.Info.page_size' as page_size} 
		  {extra->'XO.Info.pages' as pages}
	      } -type ::Content_Item \
	      -noinit]

$data lappend where "[::xo::db::qualifier id = $id]"
$data load

set o [$data head]
set object_id [$o set id]
set page_width [lindex [$o set page_size] 0]
set page_height [lindex [$o set page_size] 2]

if { $page_width > $page_height } {
    set page_size $page_width
} else {
    set page_size $page_height
}


set list ""
foreach item $pathexp {
    foreach {className instance_id} $item break
    lappend list [$className set id]-${instance_id}
}

set directory /web/data/storage/
append directory [join $list .]/
append directory $object_id


set pages [$o set pages]

set nextUrl "\#"
set previousUrl "\#"

if { ${p} < ${pages} } { 
    set nextUrl [export_vars \
		     -base . \
		     -override [list "p [expr {1+$p}]"] \
		     {q size}] 
}

if { ${p} > 1 } { 
    set previousUrl [export_vars \
			 -base . \
			 -override [list "p [expr {-1+$p}]"] \
			 {q size}] 
}

#ns_log notice "xo-drive app-reader view id=$id sql=[$data set sql] p=$p pages=$pages"
if { ${p} > ${pages} || ${p} < 1 } {
    rp_returnnotfound
    return
}

set numChars 30000
set doc_xml ""
set fp [open "|bzcat ${directory}/c-${object_id}.xml.bz2"]
while {![eof $fp]} { append doc_xml [read $fp $numChars] }
close $fp

set docId [dom parse -simple -html $doc_xml]
set root [$docId documentElement]

set pageXmlNode [$root selectNodes [subst -nocommands -nobackslashes {//page[@number="${p}"]}]]

set result ""
set highlights ""
foreach node [$pageXmlNode selectNodes {fontspec}] {
    set font_id [$node getAttribute id]
    set font_size [$node getAttribute size]
    set font_family [$node getAttribute family]
    set fontspec($font_id) [list $font_size $font_family]
}


set result ""
if { [exists_and_not_null q] } { 
    set searchQuery [::util::dbquotevalue ${q}]
    set queryAsVector [string map {{'} {}} [[$data getConn] getvalue "select strip(to_tsvector('[default_text_search_config]',${searchQuery}))"]]
    
    set lexemes [split $queryAsVector]
    foreach node [$pageXmlNode selectNodes {text}] {
	set line [string tolower [$node asText]]
	set charIndex 0
	#ffcf5c #cfff5c #cf5cff #a0f0f0 #aa0000 #00aa00 #0000aa
	#color {#ffcf5c #cfff5c #cf5cff #1b9e77 #d95f02 #7570b3 #e7298a #66a61e #e6ab02 #a6761d #666666 #0033cc}
	# "#ffcf5c"
	set color "rgb(253,144,2)"
	foreach lexeme $lexemes {
	    while { -1 != [set charIndex [string first $lexeme $line $charIndex]] } {
		set top [$node getAttribute top]
		set left [$node getAttribute left]
		set height [$node getAttribute height]
		set xright [concat $left [string trim [$node getAttribute xright]]]
		
		set wordend [string wordend $line $charIndex]
		set begin_x [lindex $xright [expr { $charIndex}]]
		set end_x [lindex $xright [expr { $wordend  }]]
		
		lappend highlights [list $begin_x $end_x $top $left $height $color]
		incr charIndex
	    }   
	}
    }

    foreach item $highlights {
	foreach {begin_x end_x top left line_height color} $item break
		
	#set zoom 1.1
	set zoom [expr { double(${size}) / double(${page_size}) }]
	set begin_x [expr { int(floor($begin_x * $zoom)) }]
	set end_x [expr { int(ceil($end_x * $zoom)) }]
	set top [expr { int(floor($top * $zoom)) }]
	set line_height [expr { int(ceil($height * $zoom)) }]
	
	#	    incr begin_x -1
	#	    incr end_x 1
	#	    incr top -1
	#	    incr line_height 3
	set xwidth [expr { $end_x - $begin_x }]
		
	set pagexml [$pageXmlNode getAttribute number]
	append result [subst -nocommands -nobackslashes {<img class="lexeme" src="http://www.phigita.net/graphics/s.gif" style="padding:0;z-index:100;filter:alpha(opacity=40);opacity: 0.4;-moz-opacity:0.4;position:absolute;top:${top}px;left:${begin_x}px;background:${color};width:${xwidth}px;" height="${line_height}px"/>}]
    }
}


#<input type="submit" value="Search Inside"></form>
#<form action="."><input type="hidden" name="" value="">

set zoomSlider ""
foreach sizeValue {240 500 800} prettyName {small medium large} {
    if { $sizeValue eq $size } {
	lappend zoomSlider $prettyName
    } else {
	set url [export_vars -base . -override [list [list size $sizeValue]] {q p}]
	lappend zoomSlider [format "<a href=\"%s\">%s</a>" $url $prettyName]
    }
}
set zoomSlider [join $zoomSlider { | }]


#$p, $pages, $size

set js [::xo::js::include_compiled xo-drive.lib.reader {
    kernel/lib/base.js
    kernel/lib/event.js
    kernel/lib/DomHelper.js
    xo-drive/lib/reader.js
}]

ns_return 200 text/html [subst -nocommands -nobackslashes {
<!DOCTYPE HTML>
<html>
<head>
<script type="text/javascript">
    ${js}

    window.onload=function(){
	//Setup reader
	DR.init({
	    baseUrl: '${base}/media/view/',
	    docId: ${id},
	    size: ${size},
	    pages: ${pages},
	    currentPage: ${p}
	});
    };

</script>

<style>
.page{}
.page img{height:100%;width:auto;}
body{text-align:center;color:#FFF;background:#c0c0c0;margin:0px;}
.footer{position:fixed;bottom:0px;left:80px;right:80px;height:30px;background: #2c2c2c;background:rgba(44,44,44,0.8) !important;color:#FFF;padding:5px 0 0 0;border:2px solid #0d0d0d;border-bottom:0;border-radius:5px 15px 0 0;z-index:1000;}
.footer span{padding:0 10px 0 10px;}
.footer span a{color:#FFF;}
.footer span a:hover{color:#FFF;font-weight:bold;}
.footer span div{display:inline-block;*display:inline;zoom:1;position:relative;top:-8px;}
.footer input{background:#c0c0c0;border:0;padding:2px;height:22px;}
.footer input:hover,.footer input:active{background:#f2f2f2;}
#loading{position:fixed;right:0px;top:0px;width:100px;background:#db4a46;padding:5px;font-weight:bold;display:none;}
#morepages{position:fixed;background: #cef238;right: 5px; bottom:0px; width:20px;height:50px;color:#000;}

#totalpages{margin:0;padding:0;}
#goto{width:40px;text-align:right;}

#btnprev,#btnnext,#btnprevslide,#btnnextslide,#btnzoomin,#btnzoomout,#btnslideshow,#btnscroll{display:inline-block;*display:inline;zoom:1;width:26px;height:26px;background-position:top left; background-repeat:no-repeat;}
#btnprev:hover,#btnnext:hover,#btnprevslide:hover,#btnnextslide:hover,#btnzoomin:hover,#btnzoomout:hover,#btnslideshow:hover,#btnscroll:hover{background-position:top right;}
#btnprev{background:url(/graphics/reader/btnprev.gif);}
#btnnext{background:url(/graphics/reader/btnnext.gif);}
#btnprevslide{background:url(/graphics/reader/btnprevslide.gif);}
#btnnextslide{background:url(/graphics/reader/btnnextslide.gif);}
#btnzoomin{background:url(/graphics/reader/btnzoomin.gif);}
#btnzoomout{background:url(/graphics/reader/btnzoomout.gif);}
#btnslideshow{background:url(/graphics/reader/btnslideshow.gif);}
#btnscroll{background:url(/graphics/reader/btnscroll.gif);}
#btnfullscreen{display:none;}
#slidecontrols{display:none;}

.tooltip{position:absolute !important;top:-140px !important;left:-80px !important;width:120px;background:rgba(40,40,40,0.9);display:block !important;border-radius:5px;padding:5px;text-align:left !important;box-shadow: 2px 2px 2px #000;}
.tooltip ul{list-style:none;margin:0;padding:0;}
.tooltip ul li{margin:2px 0 0 0;}
.tooltip ul a{display:block;}

#slidemask{position:fixed;top:0px;left:0px;right:0px;bottom:0px;display:none;}
#prevslide,#nextslide{width:40%;height:100%;}
#prevslide{float:left;cursor:pointer;}
#nextslide{float:right;cursor:pointer;}
#prevslide:hover,.nextslide:hover{background:rgba(0,0,0,0.1);}
.maskimg{position:absolute;top:40%;}
    #viewmode li {margin:5px;}

</style>
</head>
<body>
<div id="slidemask">
	<div id="nextslide" title="Next slide"><img style="right:10px;" class="maskimg" src="/graphics/reader/masknext.gif" /></div>
	<div id="prevslide" title="Previous slide"><img style="left:10px;" class="maskimg" src="/graphics/reader/maskprev.gif" /></div>	
</div>
<div id="loading">Loading...</div>
<div id="content">
    <div class="page" id="page_1"><img src="${base}/media/view/${id}?size=${size}&p=${p}" /></div>
</div>
<div id="spacer">
</div>
<div id="toolbar" class="footer">
	<span id="pageviewcontrols">
		<a href="#viewmodemenu"  id="curview"><img src="/graphics/reader/viewscroll.gif" /></a>
		<div id="viewtooltip" style="display:none;">
		<div class="tooltip">
			<b>View mode:</b><br />
    <ul id="viewmode">
    <li><div id="btnslideshow">Slideshow</div></li>
    <li><div id="btnscroll">Scroll</div></li>
</ul>
		</div>
		</div>
	</span>
	<span id="pagecontrols">
		<a href="#prevpage" id="btnprev"></a>
		<a href="#nextpage" id="btnnext"></a>
	</span>
	<span id="slidecontrols">
		<a href="#prevslide" id="btnprevslide"></a>
		<a href="#nextslide" id="btnnextslide"></a>
	</span>
	<span>
		<div>
    <input id="goto" type="text" value="1" />&nbsp;/&nbsp;<span id="totalpages">${pages}</span>
		</div>
	</span>
	<span id="zoomcontrols">
		<a href="#zoomout" id="btnzoomout"></a>
		<a href="#zoomin" id="btnzoomin"></a>
	</span>
	<!--
	<span>
		<a href="javascript: DR.showFullscreenReader();" id="btnfullscreen">[FS]</a>
	</span>
	<span id="searchcontrols">
		<div>
		<input id="search" type="text" value="Search within document..." />
		</div>
	</span>
	-->
</div>
<div id="morepages">+</div>
</body>
</html>

}]

return 
if {0} {
ns_return 200 text/html [subst -nocommands -nobackslashes {
<form name="readerNav" action="./" method="GET">
	    [${zoomSlider}]
<input type="hidden" name="size" value="$size">
<input type="text" name="q" value="${q}">
<a href="$previousUrl">Previous</a>
	    Page <input type="text" name="p" value="${p}" size="2"> of ${pages}
<a href="$nextUrl">Next</a>
	    <input type="submit" value="GO" style="visibility:hidden;">

</form>
    <div style="position:relative;">${result}<img style="position:absolute;top:0px;left:0px;" src="../../view/${id}?size=${size}&p=${p}" /></div>
	}]
}