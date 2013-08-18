package require crc16
#::util::loadIf /opt/naviserver/bin/libjscompact0.1.so


namespace eval ::xo {;}
namespace eval ::xo::ui {;}


Class ::xo::ui::RenderingVisitor -parameter {
    {domDoc ""}
    {documentElement ""}
    {head ""}
    {body ""}
    {content ""}
    {last ""}
    {__style ""}
    {__styleList ""}
    {__js ""}
    {__jsList ""}
    {__maxInitTime "0"}
    {__version "K"}
}

::xo::ui::RenderingVisitor instproc initHeaders {} {

    my instvar is_gecko is_ie __user_agent __headers

    if { ![info exists __user_agent] } {
	set __headers [ns_conn headers]
	set __user_agent [string tolower [ns_set iget $__headers User-Agent]]
	set is_ie [expr { [string first "msie" $__user_agent] != -1 }]
	set is_gecko [expr { [string first "gecko" $__user_agent] != -1 }]
	#set is_opera [expr { [string first "opera" $__user_agent] != -1 }]
    }

}

::xo::ui::RenderingVisitor instproc init {} {
    my instvar domDoc documentElement head body content last __styleNode __jsNode

    my ensureNodeCmd elementNode head body div style script

    dom createNodeCmd textNode t
    dom createDocument HTML domDoc

    $domDoc publicId "-//W3C//DTD HTML 4.01//EN"
    $domDoc systemId "http://www.w3.org/TR/html4/strict.dtd"

    set documentElement [$domDoc documentElement]
    $documentElement appendFromScript {
	set head [head]
	set body [body {

	    set __styleNode [style -type "text/css"]
	    set __jsNode [script -type "text/javascript"]

	    set content [div]
	    set last [div]
	}]
    }
}

::xo::ui::RenderingVisitor instproc ensureNodeCmd {nodeType args} {

    my instvar __nodeCmd
    foreach commandName $args {
	if { ![info exists __nodeCmd($commandName)] } {
	    dom createNodeCmd -returnNodeCmd $nodeType $commandName
	    set __nodeCmd($commandName) ""
	}
    }

}

::xo::ui::RenderingVisitor instproc visit {o} {
    if { [catch {set node [$o render [self]]} errmsg] } {
	my ensureNodeCmd elementNode div
	ns_log notice "Error: o=$o cl=[$o info class] xXx-$errmsg"
	set node [div]
    } 
    return $node
}

::xo::ui::RenderingVisitor instproc inlineStyle {style} {
    my instvar __styleNode __style

    set comment {
	if { ![info exists __styleNode] } {
	    my ensureNodeCmd elementNode style
	    [my head] appendFromScript {
		set __styleNode [style -type "text/css"]
	    }
	}
	$__styleNode appendFromScript { t -disableOutputEscaping ${style} }
    }

    append __style $style

}

::xo::ui::RenderingVisitor instproc inlineJavascriptToHead {js} {
    my instvar __head_javascript

    if { ![info exists __head_javascript] } {
	my ensureNodeCmd elementNode script
	[my head] appendFromScript {
	    set __head_javascript [script -type "text/javascript"]
	}
    }
    $__head_javascript appendFromScript { t -disableOutputEscaping $js }

}

::xo::ui::RenderingVisitor instproc inlineJavascript {js} {
    my instvar __jsNode __js __maxInitTime

    set cl [[self callingobject] info class]
    if { [$cl exists tclInitTime] } {
	if { $__maxInitTime < [$cl set tclInitTime] } {
	    set __maxInitTime [$cl set tclInitTime]
	}
    }

    append __js $js

}

::xo::ui::RenderingVisitor instproc resolve_file {refPath filename} {
    set refRootName [file rootname $refPath]
    return [file normalize ${refRootName}/${filename}]
}



::xo::ui::RenderingVisitor instproc prepareCSS {styleList} {

    if { $styleList eq {} } { return }

    my instvar __version
    set protocol [ad_conn protocol]
    set issecure [ad_conn issecure]
    set targetName [::crc::crc16 -format %X ${styleList}]
    set targetURL /resources/css/${__version}${issecure}-${targetName}.css
    set targetFile [file normalize [acs_root_dir]/www/${targetURL}]
    set finalFile /web/data/${targetURL}

    set mtime [::memoize::cache get MTIME:${finalFile}]
    if { $mtime eq {} } {


	if { ![file exists $finalFile] } {

	    set ofp [open $targetFile w]
	    foreach styleFileURL $styleList { 
		#ns_log notice "styleFile=$styleFile"
		set styleFile [file normalize [acs_root_dir]/www/$styleFileURL]
		set ifp [open $styleFile]
		set str [read $ifp]
		close $ifp

		set start 0
		set regexp {url\(([^\(\)]+)\)}
		set tmpstr ""
		set flip 0

		while {[regexp -start $start -indices -- $regexp $str match submatch]} {
		    lassign $submatch subStart subEnd
		    lassign $match matchStart matchEnd
		    append tmpstr [string range $str $start [expr {-1 + $matchStart}]]

		    set srcImageUrl [string trim [string range $str $subStart $subEnd] " '\"\t\r\n"]
		    if { ![info exists src_to_target($srcImageUrl)] } {
			set tailName [::crc::crc16 -format %X $srcImageUrl]_[file tail $srcImageUrl]
			set targetImageUrl /resources/images/${tailName}
			set realImageUrl ${protocol}://g${issecure}${flip}.phigita.net/${tailName}
			set src_to_target($srcImageUrl) $realImageUrl
			set srcImageFile [file normalize [file dirname $styleFile]/$srcImageUrl]
			set targetImageFile [file normalize [acs_root_dir]/www/${targetImageUrl}]
			set finalImageFile [file normalize /web/data/${targetImageUrl}]

			#ns_log notice $srcImageFile
			if { [file exists $srcImageFile] } {
			    file copy -force $srcImageFile $targetImageFile
			    file copy -force $targetImageFile $finalImageFile
			}
			set flip [expr {!${flip}}]
		    } else {
			set realImageUrl $src_to_target($srcImageUrl)
		    }

		    append tmpstr url($realImageUrl)
		    set start [expr {1+$matchEnd}]
		}
		append tmpstr [string range $str $start end]
		puts -nonewline $ofp $tmpstr
	    }
	    close $ofp

	    ::CSS do minimize $targetFile $finalFile

	}

	set mtime [::util::mtime ${finalFile}]
	set timeout 172800 ;# 2 days
	::memoize::cache set MTIME:${finalFile} $mtime $timeout

    }

    return ${targetURL}

}


::xo::ui::RenderingVisitor instproc importCSS {{-compile_p "yes"} {-targetName ""} {-host ""} filename} {
    my instvar domDoc __styleNode __styleList __seen
    if { $compile_p } {
	if { ![info exists __seen($filename)] } {
	    lappend __styleList $filename
	}
    } else {
	if { ![exists_and_not_null targetName] } {
	    set targetName [file tail $filename]
	}

	set url $filename

	if { ![info exists host] } {
	    set host [ad_conn protocol]://www.phigita.net/
	}
	set href [::uri::canonicalize ${host}${url}]
	[my body] insertBeforeFromScript [subst {
	    t -disableOutputEscaping {<link rel="stylesheet" type="text/css" href="$href" />}
	}] $__styleNode
    }

}

::xo::ui::RenderingVisitor instproc importJS_OLD {{-targetName ""} filelist} {
    if { $targetName eq "" } {
	my jsLoad $filelist
    } else {
	foreach file $filelist {
	    my lappend __acc($targetName) $file
	}
    }
}

::xo::ui::RenderingVisitor instproc importJS {{-compile_p "yes"} {-targetName ""} filelist} {
    my instvar __jsList
    my set __compile(${targetName}) $compile_p
    foreach filename $filelist {
	my lappend __acc(${targetName}) $filename
    }
}

::xo::ui::RenderingVisitor instproc prepareJS {jsList} {

    my instvar __version __acc

    foreach targetName $jsList {

	set targetURL /resources/js/${__version}-${targetName}.js
	set targetFile [file normalize [acs_root_dir]/www/${targetURL}]
	set finalFile /web/data/${targetURL}

	lappend targetURLs $targetURL
	#{lappend targetURLs [::util::getStaticHost [crc::crc16 -format %X ${__version}-${targetName}] "j" "" "8"]}

	set mtime [::memoize::cache get MTIME:${finalFile}]
	if { $mtime eq {} } {

	    if { ![file exists $finalFile] } {
		set ofp [open $targetFile w]
		foreach jsFile $__acc($targetName) {
		    if { ![info exists __seen($jsFile)] } {
			set __seen($jsFile) $targetName
			#ns_log notice jsFile=$jsFile
			set ifp [open [file normalize [acs_root_dir]/www/$jsFile]]
			fconfigure $ifp -encoding binary
			puts $ofp [read $ifp]
			close $ifp
		    } else {
			#ns_log notice "seen $jsFile in $targetName"
		    }
		}
		close $ofp
		if { [my set __compile(${targetName})] } {
		    ::JS do minimize ${targetFile} ${finalFile}
		} else {
		    file copy -force -- ${targetFile} ${finalFile}
		}
	    }

	    set mtime [::util::mtime ${finalFile}]
	    set timeout 172800 ;# 2 days
	    ::memoize::cache set MTIME:${finalFile} $mtime $timeout

	}
    }

    return ${targetURLs}

}

::xo::ui::RenderingVisitor instproc jsLoad {{-targetName ""} filelist} {
    my instvar __version

    if { $targetName eq {} } { set targetName [ns_sha1 $filelist] }
    set targetFileName /lib/data/${__version}-${targetName}.js
    set outputFile [file normalize /web/data/${targetFileName}]


    if { [file exists $outputFile] } {
	set create_p 0
	set mtime [::util::mtime $outputFile]
	set total 0
	foreach filename $filelist {
	    if { [::util::mtime /web/data/$filename] > $mtime } {
		set create_p 1
		break
	    }
	    incr total [file size /web/data/$filename]
	}
	if { 0 && !$create_p } {
	    set size [file size $outputFile]
	    if { $size != $total } {
		set create_p 1
	    }
	    if { [ad_conn user_id] == 814 } {
		ns_log notice "create_p=$create_p outputFile=$outputFile size=$size total=$total"
	    }

	}
    } else {
	set create_p 1
    }		

    if { $create_p } {
	set ofp [open ${outputFile} w]
	fconfigure $ofp -encoding binary
	foreach filename $filelist {
	    set inputFile /web/data/${filename}
	    set ifp [open [file normalize $inputFile]]
	    fconfigure $ifp -encoding binary
	    puts $ofp [read $ifp]
	    close $ifp
	}
	close $ofp

	#ns_log notice "JS do minimize $outputFile $targetName"

	::JS do minimize ${outputFile} /web/data/js/${__version}-${targetName}.js

    }

    set host [ad_conn protocol]://www.phigita.net
    ###set host http://localhost:8090/

    my instvar domDoc __jsNode 
    set newChild [$domDoc createElement script]
    $newChild setAttribute type "text/javascript"
    $newChild setAttribute src ${host}${targetFileName}
    [my body] insertBefore $newChild $__jsNode
}

::xo::ui::RenderingVisitor instproc ensureLoaded {{-targetName ""} args} {
    my instvar __loaded __ok
    
    if { $targetName ne {} } { my set __acc($targetName) "" }

    foreach what $args {
	if { ![info exists __loaded($what)] } {
	    my ensureNodeCmd elementNode link
	    my ensureNodeCmd elementNode script

	    set extVersion 2.2 ;# 2.1 ;#2.0.2 ;# 2.0.1 ;# 2.0 ;#2.0-beta1 ;# 2.0-alpha1 ;# 1.1.1 ;#1.1 ;# 1.1-rc1 ;#1.1-beta2 ;#1.0.1
	    set yuiVersion 2.2.2
	    set xoVersion 1.0.0

	    set __loaded($what) yes
	    [my head] appendFromScript {
		switch -exact -- $what {
		    EXT.Core {
			my importCSS "/lib/ext-${extVersion}/resources/css/ext-all.css"
			#my importJS -targetName $targetName "/lib/ext-${extVersion}/adapter/jquery/jquery.js"
			#my importJS -targetName $targetName "/lib/ext-${extVersion}/adapter/jquery/jquery-plugins.js"
			#my importJS -targetName $targetName "/lib/ext-${extVersion}/adapter/jquery/ext-jquery-adapter.js"
			#my loadjs "/lib/ext-${extVersion}/ext-core-debug.js"

			#my importJS -targetName $targetName "/lib/ext-${extVersion}/adapter/yui/yui-utilities.js"
			#my importJS -targetName $targetName "/lib/ext-${extVersion}/adapter/yui/ext-yui-adapter.js"
			#my importJS -targetName $targetName "/lib/ext-${extVersion}/source/experimental/ext-base.js"

			my importJS -targetName $targetName "/lib/ext-${extVersion}/adapter/ext/ext-base.js"
			my importJS -targetName $targetName "/lib/ext-${extVersion}/ext-all.js"
		    }
		    Ext.Base {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/adapter/ext-base.js"
		    }
		    Ext.core.GlobalObject {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/core/Ext.js"
		    }
		    Ext.core.EventManager {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/core/EventManager.js"
		    }
		    Ext.core.UpdateManager {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/core/UpdateManager.js"
		    }
		    Ext.core.Element {
			#my ensureLoaded Ext.util.KeyMap
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/core/Element.js"
		    }
		    Ext.core.CompositeElement {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/core/CompositeElement.js"
		    }
		    Ext.core.DomHelper {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/core/DomHelper.js"
		    }
		    Ext.core.DomQuery {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/core/DomQuery.js"
		    }
		    Ext.core.Template {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/core/Template.js"
		    }
		    Ext.util.XTemplate {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/util/XTemplate.js"
		    }
		    Ext.util.Format {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/util/Format.js"
		    }
		    Ext.util.TextMetrics {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/util/TextMetrics.js"
		    }
		    Ext.core.Fx {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/core/Fx.js"
		    }

		    Ext.core {
			my ensureLoaded XO.Core
		    }




		    Ext.util.Observable {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/util/Observable.js"
		    }
		    Ext.util.DelayedTask {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/util/DelayedTask.js"
		    }
		    Ext.util.JSON {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/util/JSON.js"
		    }
		    Ext.util.KeyMap {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/util/KeyMap.js"
		    }
		    Ext.util.KeyNav {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/util/KeyNav.js"
		    }
		    Ext.util.Date {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/util/Date.js"
		    }
		    Ext.util.MixedCollection {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/util/MixedCollection.js"
		    }
		    Ext.util.ClickRepeater {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/util/ClickRepeater.js"
		    }
		    Ext.util.TaskMgr {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/util/TaskMgr.js"
		    }
		    Ext.util.CSS {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/util/CSS.js"
		    }
		    Ext.util.History {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/util/History.js"
		    }





		    Ext.widgets.MessageBox {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/MessageBox.js"			
		    }
		    Ext.widgets.ProgressBar {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/ProgressBar.js"
		    }

		    Ext.widgets.Layer {
			#my ensureLoaded Ext.widgets.Shadow
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/Layer.js"
		    }

		    Ext.widgets.View {
			#my ensureLoaded Ext.util.Observable
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/legacy/View.js"
		    }

		    Ext.widgets.Menu.BaseItem {
			my ensureLoaded XO.ComponentShadowLayer
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/menu/BaseItem.js"
		    }
		    Ext.widgets.Menu.CheckItem {
			#my ensureLoaded Ext.widgets.Menu.Item
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/menu/CheckItem.js"
		    }
		    Ext.widgets.Menu.Adapter {
			#my ensureLoaded Ext.widgets.Menu.BaseItem
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/menu/Adapter.js"
		    }
		    Ext.widgets.Menu.TextItem {
			#my ensureLoaded Ext.widgets.Menu.BaseItem
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/menu/TextItem.js"
		    }
		    Ext.widgets.ColorPalette {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/ColorPalette.js"
		    }
		    Ext.widgets.Menu.ColorItem {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/menu/ColorItem.js"
		    }
		    Ext.widgets.Menu.ColorMenu {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/menu/ColorMenu.js"
		    }
		    Ext.widgets.Menu.Separator {
			#my ensureLoaded Ext.widgets.Menu.BaseItem
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/menu/Separator.js"
		    }
		    Ext.widgets.Menu.Item {
			#my ensureLoaded Ext.widgets.Menu.BaseItem
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/menu/Item.js"
		    }
		    Ext.widgets.Menu.MenuMgr {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/menu/MenuMgr.js"
		    }

		    Ext.data.DataReader {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/data/DataReader.js"
		    }

		    Ext.data.JsonReader {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/data/JsonReader.js"
		    }
		    Ext.data.JsonStore {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/data/JsonStore.js"
		    }

		    Ext.data.ArrayReader {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/data/ArrayReader.js"
		    }

		    Ext.data.DataProxy {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/data/DataProxy.js"
		    }

		    Ext.data.MemoryProxy {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/data/MemoryProxy.js"
		    }

		    Ext.data.HttpProxy {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/data/HttpProxy.js"
		    }

		    Ext.data.ScriptTagProxy {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/data/ScriptTagProxy.js"
		    }

		    Ext.data.StoreMgr {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/data/StoreMgr.js"
		    }


		    Ext.data.SortTypes {
			my ensureLoaded Ext.util.Date
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/data/SortTypes.js"
		    }

		    Ext.data.DataField {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/data/DataField.js"
		    }

		    Ext.data.Record {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/data/Record.js"
		    }

		    Ext.data.Store {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/data/Store.js"
		    }

		    Ext.data.SimpleStore {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/data/SimpleStore.js"
		    }

		    Ext.state.Manager {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/state/StateManager.js"
		    }
		    Ext.state.CookieProvider {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/state/CookieProvider.js"
		    }
		    Ext.state.Provider {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/state/Provider.js"
		    }

		    XO.Store {
			my ensureLoaded XO.ComponentShadowLayer
		    }

		    XO.Fx {
			my ensureLoaded XO.Core
		    }

		    XO.Base {
			my ensureLoaded -targetName B0 \
			    Ext.core.GlobalObject \
			    Ext.util.JSON \
			    Ext.Base
		    }

		    XO.Core {
			my ensureLoaded XO.Base
			my ensureLoaded -targetName C0 \
			    Ext.util.Observable \
			    Ext.util.MixedCollection \
			    Ext.util.TaskMgr \
			    Ext.util.DelayedTask \
			    Ext.util.KeyMap \
			    Ext.util.KeyNav \
			    Ext.util.ClickRepeater \
			    Ext.util.Date \
			    Ext.util.Format \
			    Ext.core.DomHelper \
			    Ext.core.DomQuery \
			    Ext.core.Template \
			    Ext.util.XTemplate \
			    Ext.data.Connection \
			    Ext.core.EventManager \
			    Ext.core.Element \
			    Ext.core.CompositeElement \
			    Ext.core.UpdateManager \
			    Ext.util.TextMetrics \
			    Ext.core.Fx
			my inlineJavascript "Ext.BLANK_IMAGE_URL='[ad_conn protocol]://www.phigita.net/graphics/s.gif';"

			my ensureLoaded CSS.Core
		    }

		    XO.Core.Extra {
			my ensureLoaded Core 
			my ensureLoaded -targetname C0E \
			    Ext.util.CSS \
			    Ext.util.History \
			    Ext.state.Provider \
			    Ext.state.Manager \
			    Ext.state.CookieProvider 
		    }

		    CSS.Core {

			my importCSS "/lib/ext-${extVersion}/resources/css/reset-min.css"
			my importCSS "/lib/ext-${extVersion}/resources/css/core.css"
			### my importCSS "/lib/ext-${extVersion}/resources/css/box.css"

		    }
		    CSS.TabPanel {
			my ensureLoaded CSS.Core
			my importCSS "/lib/ext-${extVersion}/resources/css/tabs.css"
		    }


		    XO.State {
			my ensureLoaded XO.Core.Extra
		    }

		    XO.ComponentShadowLayer {
			my ensureLoaded XO.Core
			my ensureLoaded XO.State
			my ensureLoaded -targetName DS_CSL \
			    Ext.data.DataProxy \
			    Ext.data.MemoryProxy \
			    Ext.data.HttpProxy \
			    Ext.data.ScriptTagProxy \
			    Ext.data.SortTypes \
			    Ext.data.DataField \
			    Ext.data.Record \
			    Ext.data.Store \
			    Ext.data.DataReader \
			    Ext.data.JsonReader \
			    Ext.data.ArrayReader \
			    Ext.data.SimpleStore \
			    Ext.data.JsonStore \
			    Ext.data.StoreMgr \
			    Ext.widgets.ComponentMgr \
			    Ext.widgets.Component \
			    Ext.widgets.Shadow \
			    Ext.widgets.Layer \
			    Ext.widgets.BoxComponent \
			    Ext.widgets.LoadMask
		    }


		    XO.Button {
			my ensureLoaded XO.Core
			my ensureLoaded XO.ComponentShadowLayer
			my ensureLoaded XO.L_DD_P
			my ensureLoaded XO.Store
			my ensureLoaded -targetName BTN \
			    Ext.widgets.Button \
			    Ext.widgets.SplitButton \
			    Ext.widgets.CycleButton \
			    Ext.widgets.Menu.BaseItem \
			    Ext.widgets.Menu.Item \
			    Ext.widgets.Menu.CheckItem \
			    Ext.widgets.Menu.TextItem \
			    Ext.widgets.Menu.MenuMgr \
			    Ext.widgets.Menu \
			    Ext.widgets.Menu.Separator \
			    Ext.widgets.Menu.Adapter \
			    Ext.widgets.Menu.CheckItem \
			    Ext.widgets.Menu.TextItem \
			    Ext.widgets.ColorPalette \
			    Ext.widgets.Menu.ColorItem \
			    Ext.widgets.Menu.ColorMenu \
			    Ext.widgets.Menu.DateItem \
			    Ext.widgets.Menu.DateMenu \
			    Ext.widgets.Toolbar \
			    Ext.widgets.PagingToolbar \
			    Ext.widgets.Editor \
			    Ext.widgets.DataView \
			    Ext.widgets.DataView.Plugins \
			    Ext.widgets.DatePicker

		    }

		    XO.KeyNav {
			my ensureLoaded XO.Core
		    }

		    XO.Menu {
			my ensureLoaded XO.Button
		    }

		    XO.Menu.Extra {
			my ensureLoaded XO.Menu
		    }

		    XO.DD {
			my ensureLoaded L_DD_P
		    }



		    XO.MessageBox {
			my ensureLoaded XO.WM
		    }

		    XO.ImageDragZone {
			my ensureLoaded -targetName IMZ \
			    Ext.ux.ImageDragZone
		    }

		    XO.Multiselect {
			my ensureLoaded XO.Core
			my ensureLoaded XO.Store
			my ensureLoaded XO.Tree
			my ensureLoaded XO.Menu
			my ensureLoaded XO.DataView
			my ensureLoaded XO.Form
			my ensureLoaded -targetName MS \
			    Ext.ux.DDView \
			    Ext.ux.Multiselect
		    }

		    XO.Form {
			my importCSS "/lib/ext-${extVersion}/resources/css/form.css"
			my ensureLoaded XO.Core
			my ensureLoaded XO.Store
			my ensureLoaded XO.Menu
			my ensureLoaded XO.Button
			my ensureLoaded XO.MessageBox
			my ensureLoaded XO.Panel
			my ensureLoaded -targetName FRM1 \
			    Ext.form.BasicForm \
			    Ext.form.Layout \
			    Ext.form.VTypes \
			    Ext.form.Field \
			    Ext.form.TextField \
			    Ext.form.Hidden \
			    Ext.form.TextArea \
			    Ext.form.FieldSet \
			    Ext.form.Checkbox \
			    Ext.form.CheckboxGroup \
			    Ext.form.Radio \
			    Ext.form.RadioGroup \
			    Ext.form.Label \
			    Ext.widgets.Form \
			    Ext.form.Action \
			    Ext.form.TriggerField \
			    Ext.ux.SearchField \
			    Ext.form.ComboBox \
			    Ext.ux.SelectBox \
			    Ext.form.NumberField \
			    Ext.form.DateField \
			    Ext.form.TimeField \
			    Ext.ux.form.DateTime 

		    }



		    FormPanelOverride {
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/widgets/form/FormPanelOverride.js"
		    }
		    Ext.desktop.StartMenu {
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/desktop/StartMenu.js"
		    }
		    Ext.desktop.TaskBar {
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/desktop/TaskBar.js"
		    }
		    Ext.desktop.Desktop {
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/desktop/Desktop.js"
		    }
		    Ext.desktop.App {
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/desktop/App.js"
		    }
		    Ext.desktop.Module {
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/desktop/Module.js"
		    }

		    Ext.widgets.Window {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/Window.js"
		    }
		    Ext.widgets.WindowManager {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/WindowManager.js"
		    }

		    XO.WM {
			my ensureLoaded XO.Core
			my ensureLoaded XO.L_DD_P
			my ensureLoaded -targetName WM \
			    Ext.widgets.WindowManager \
			    Ext.widgets.Window \
			    Ext.widgets.ProgressBar \
			    Ext.widgets.MessageBox

			my importCSS "/lib/ext-${extVersion}/resources/css/window.css"
			my importCSS "/lib/ext-${extVersion}/resources/css/dialog.css"
		    }


		    XO.Desktop {
			my ensureLoaded XO.Core
			my ensureLoaded XO.Menu
			my ensureLoaded XO.WM
			my ensureLoaded XO.Tree
			my ensureLoaded -targetName Desktop \
			    Ext.desktop.StartMenu \
			    Ext.desktop.TaskBar \
			    Ext.desktop.Desktop \
			    Ext.desktop.App \
			    Ext.desktop.Module
			my importCSS "/lib/xo-${xoVersion}/resources/css/desktop.css"
		    }

		    XO.FotoNotes {
                        ##my jsLoad -targetName FN "/lib/fnclient-0.6.0/fnclientlib/js/fnclient.js"
			##my importCSS "/lib/fnclient-0.6.0/fnclientlib/styles/fnclient.css"
		    }


		    XO.Form.TextArea {
			my ensureLoaded XO.Form
		    }

		    XO.Form.TriggerField {
			my ensureLoaded XO.Form.Extra
		    }

		    XO.Form.Number {
			my ensureLoaded XO.Form.Extra
		    }

		    XO.Form.ComboBox {
			my ensureLoaded XO.Form.Extra
		    }

		    XO.Form.Extra {
			my ensureLoaded XO.Form
			#my ensureLoaded XO.Store
			#my ensureLoaded XO.Menu
			#my ensureLoaded -targetName F0E
		    }

		    XO.Form.Date {
			my ensureLoaded XO.Form.Extra
		    }

		    XO.ImageChooser {
			my ensureLoaded XO.DataView
			my ensureLoaded XO.L_DD_P
			my ensureLoaded XO.Menu
			my ensureLoaded XO.Form.Extra
		    }


		    XO.HtmlEditor {
                        my ensureLoaded XO.QuickTips
                        my ensureLoaded XO.Core
                        my ensureLoaded XO.ImageChooser
                        my ensureLoaded XO.Form
                        my ensureLoaded XO.Dialog
                        my ensureLoaded XO.WM
                        my ensureLoaded XO.Menu
                        my ensureLoaded XO.Toolbar

			my initHeaders
			my importCSS "/lib/xo-${xoVersion}/resources/css/image-chooser.css"
			my importCSS "/lib/xo-${xoVersion}/resources/css/editor.css"


			set filelist [list]
			lappend filelist "/lib/xinha/XinhaCore.js"

			if { [my set is_gecko] } {
			    set suffix FF
			    lappend filelist "/lib/xinha/modules/Gecko/Gecko.js"
			} elseif { [my set is_ie] } {
			    set suffix IE
			    lappend filelist "/lib/xinha/modules/InternetExplorer/InternetExplorer.js"
			} else {
			    set suffix ALL
			    lappend filelist "/lib/xinha/modules/Gecko/Gecko.js"
			    lappend filelist "/lib/xinha/modules/InternetExplorer/InternetExplorer.js"
			}

			#lappend filelist "/lib/xinha/modules/StructuredText/structured-text.js"
			#lappend filelist "/lib/xinha/modules/FullScreen/full-screen.js"
			#lappend filelist "/lib/xinha/modules/GetHtml/DOMwalk.js"
			#lappend filelist "/lib/xinha/modules/CreateLink/link.js"
			#lappend filelist "/lib/xinha/modules/InsertImage/insert-image.js"

                        lappend filelist "/lib/xinha/XinhaExtra.js"

			set targetName HE_65y${suffix}
			#my importJS -compile_p no -targetName ${targetName} $filelist
			my importJS -targetName ${targetName} $filelist

		    }


		    Ext.widgets.DatePicker {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/DatePicker.js"
			my importCSS "/lib/ext-${extVersion}/resources/css/date-picker.css"
		    }


		    XO.DatePicker {
			my ensureLoaded XO.DataView
			# Moved DatePicker
		    }

		    Ext.widgets.Menu {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/menu/Menu.js"
			my importCSS "/lib/ext-${extVersion}/resources/css/menu.css"
		    }


		    XO.JSON {
			my ensureLoaded XO.Core
		    }


		    Ext.widgets.DataView {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/DataView.js"
		    }

		    Ext.widgets.DataView.Plugins {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/examples/view/data-view-plugins.js"
		    }

		    XO.DataView {
			my ensureLoaded XO.Button
		    }

		    Ext.widgets.JsonView {
			#my ensureLoaded Ext.util.JSON
			#my ensureLoaded Ext.widgets.View
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/legacy/JsonView.js"
		    }

		    Ext.widgets.Layout.LayoutManager {
			#my ensureLoaded Ext.util.Observable
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/legacy/layout/LayoutManager.js"
		    }

		    Ext.widgets.Layout.LayoutRegion {
			my importJS -targetName $targetName [list \
							       "/lib/ext-${extVersion}/source/legacy/layout/BasicLayoutRegion.js" \
							       "/lib/ext-${extVersion}/source/legacy/layout/LayoutRegion.js"]
		    }

		    Ext.widgets.Layout.ContentPanels {
			#my ensureLoaded Ext.util.Observable
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/legacy/layout/ContentPanels.js"
		    }

		    XO.Legacy.Layout {
			my ensureLoaded -targetName LegacyLayout \
			    Ext.widgets.Layout.ContentPanels \
			    Ext.widgets.Layout.LayoutManager \
			    Ext.widgets.Layout.LayoutRegion \
			    Ext.widgets.Layout.SplitLayoutRegion \
			    Ext.widgets.SplitBar \
			    Ext.widgets.Layout.BorderLayoutRegions \
			    Ext.widgets.Layout.BorderLayout 
		    }

		    Ext.widgets.FitLayout {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/layout/FitLayout.js"
		    }
		    Ext.widgets.ColumnLayout {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/layout/ColumnLayout.js"
		    }
		    Ext.widgets.FormLayout {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/layout/FormLayout.js"
		    }
		    Ext.widgets.TableLayout {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/layout/TableLayout.js"
		    }
		    Ext.widgets.AnchorLayout {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/layout/AnchorLayout.js"
		    }
		    Ext.widgets.CardLayout {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/layout/CardLayout.js"
		    }
		    Ext.widgets.ContainerLayout {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/layout/ContainerLayout.js"
		    }
		    Ext.widgets.BorderLayout {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/layout/BorderLayout.js"
		    }
		    Ext.widgets.AccordionLayout {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/layout/AccordionLayout.js"
		    }
		    Ext.widgets.Viewport {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/Viewport.js"
		    }

		    XO.Layout {
			my ensureLoaded L_DD_P
		    }
		    XO.L_DD_P {
			my ensureLoaded XO.Core
			my ensureLoaded XO.ComponentShadowLayer
			my ensureLoaded -targetName L0 \
			    Ext.widgets.SplitBar \
			    Ext.widgets.Container    \
			    Ext.widgets.ContainerLayout \
			    Ext.widgets.FitLayout \
			    Ext.widgets.CardLayout \
			    Ext.widgets.AnchorLayout \
			    Ext.widgets.ColumnLayout \
			    Ext.widgets.BorderLayout \
			    Ext.widgets.AccordionLayout \
			    Ext.widgets.FormLayout \
			    Ext.widgets.TableLayout \
			    Ext.widgets.Viewport \
			    Ext.dd.Core \
			    Ext.dd.DragSource \
			    Ext.dd.ScrollManager \
			    Ext.dd.DropTarget \
			    Ext.dd.DropZone \
			    Ext.dd.DragSource \
			    Ext.dd.DragZone \
			    Ext.dd.StatusProxy \
			    Ext.dd.Registry \
			    Ext.dd.DragTracker \
			    Ext.widgets.TreeDropZone \
			    Ext.widgets.TreeDragZone \
			    Ext.widgets.Resizable \
			    Ext.widgets.Panel \
			    Ext.widgets.PanelDD \
			    Ext.widgets.TabPanel \
			    Ext.ux.TabCloseMenu \
			    Ext.widgets.Tip \
			    Ext.widgets.ToolTip \
			    Ext.widgets.QuickTip \
			    Ext.widgets.QuickTips 

			my inlineJavascript "Ext.QuickTips.init();"
		    }


		    Ext.widgets.Layout.BorderLayout {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/legacy/layout/BorderLayout.js"
		    }
		    Ext.widgets.Layout.BorderLayoutRegions {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/legacy/layout/BorderLayoutRegions.js"
		    }
		    Ext.widgets.Layout.SplitLayoutRegion {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/legacy/layout/SplitLayoutRegion.js" 
		    }
		    Ext.form.BasicForm {
			my ensureLoaded XO.Core
			#my ensureLoaded Ext.util.MixedCollection
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/BasicForm.js"
		    }

		    Ext.form.Layout {
			#my ensureLoaded Ext.widgets.Component

			my ensureLoaded XO.ComponentShadowLayer

			my importCSS "/lib/ext-${extVersion}/resources/css/layout.css"
#HERE			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/Layout.js"
		    }

		    Ext.form.Action {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/Action.js"
		    }

		    Ext.form.Field {
			#my ensureLoaded Ext.widgets.BoxComponent
			my ensureLoaded ComponentShadowLayer
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/Field.js"
		    }
		    Ext.form.FileUploadField {
			my importCSS "/lib/xo-${xoVersion}/resources/css/file-upload.css"
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/widgets/form/FileUploadField.js"
		    }
		    Ext.form.TextField {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/TextField.js"
		    }
		    Ext.form.Hidden {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/Hidden.js"
		    }

		    Ext.form.FieldSet {
			#my ensureLoaded Ext.form.Field
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/FieldSet.js"
		    }

		    Ext.form.TextArea {
			#my ensureLoaded Ext.form.Field
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/TextArea.js"
		    }
		    Ext.form.Checkbox {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/Checkbox.js"
		    }
		    Ext.form.Radio {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/Radio.js"
		    }
		    Ext.form.CheckboxGroup {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/CheckboxGroup.js"
		    }
		    Ext.form.RadioGroup {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/RadioGroup.js"
		    }
		    Ext.form.Label {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/Label.js"
		    }

		    Ext.form.TriggerField {
			#my ensureLoaded Ext.form.Field
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/TriggerField.js"
		    }

		    Ext.form.NumberField {
			#my ensureLoaded Ext.form.Field
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/NumberField.js"
		    }

		    Ext.form.ComboBox {
			#my ensureLoaded Ext.form.Field
			my importCSS "/lib/ext-${extVersion}/resources/css/combo.css"
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/Combo.js"
		    }

		    Ext.form.DateField {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/DateField.js"
		    }
		    Ext.form.TimeField {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/TimeField.js"
		    }

		    Ext.widgets.Form {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/form/Form.js"
		    }

		    Ext.form.VTypes {
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/widgets/form/VTypes.js"
		    }

		    Ext.dd.Core {
			my ensureLoaded XO.Core
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/dd/DDCore.js"
			my importCSS "/lib/ext-${extVersion}/resources/css/dd.css"
		    }

		    Ext.dd.DragSource {
			my ensureLoaded XO.Core
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/dd/DragSource.js"
		    }

		    Ext.dd.ScrollManager {
			my ensureLoaded XO.Core
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/dd/ScrollManager.js"
		    }
		    Ext.dd.DropZone {
			my ensureLoaded XO.Core
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/dd/DropZone.js"
		    }
		    Ext.dd.DropTarget {
			my ensureLoaded XO.Core
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/dd/DropTarget.js"
		    }
		    Ext.dd.DragZone {
			my ensureLoaded XO.Core
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/dd/DragZone.js"
		    }
		    Ext.dd.DragSource {
			my ensureLoaded XO.Core
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/dd/DragSource.js"
		    }
		    Ext.dd.StatusProxy {
			my ensureLoaded XO.Core
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/dd/StatusProxy.js"
		    }
		    Ext.dd.Registry {
			my ensureLoaded XO.Core
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/dd/Registry.js"
		    }
		    Ext.dd.DragTracker {
			my ensureLoaded XO.Core
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/dd/DragTracker.js"
		    }

		    Ext.widgets.ComponentMgr {
			my ensureLoaded XO.Core
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/ComponentMgr.js"
		    }

		    Ext.widgets.Component {
			#my ensureLoaded Ext.util.MixedCollection
			my ensureLoaded XO.Core
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/Component.js"
		    }

		    Ext.widgets.Container {
			my ensureLoaded XO.Core
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/Container.js"
		    }

		    Ext.widgets.SplitBar {
			#my ensureLoaded Ext.util.Observable
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/SplitBar.js"
		    }

		    Ext.widgets.SplitButton {
			my importCSS "/lib/ext-${extVersion}/resources/css/button.css"
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/SplitButton.js"
		    }

		    Ext.widgets.CycleButton {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/CycleButton.js"
		    }

		    Ext.widgets.Menu.DateMenu {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/menu/DateMenu.js"
		    }

		    Ext.widgets.Menu.DateItem {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/menu/DateItem.js"
		    }

		    XO.Toolbar {
			my ensureLoaded XO.Menu
		    }

		    Ext.widgets.Toolbar {
			my importCSS "/lib/ext-${extVersion}/resources/css/toolbar.css"		    
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/Toolbar.js"
		    }

		    Ext.widgets.PagingToolbar {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/PagingToolbar.js"
		    }


		    Ext.widgets.BoxComponent {
			#my ensureLoaded XO.ComponentShadowLayer
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/BoxComponent.js"
		    }

		    Ext.widgets.Button {
			my ensureLoaded XO.Core
			#my ensureLoaded Ext.util.Observable
			my importCSS "/lib/ext-${extVersion}/resources/css/button.css"
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/Button.js"
		    }

		    Ext.widgets.Resizable {
			my ensureLoaded XO.Core
			my importCSS "/lib/ext-${extVersion}/resources/css/resizable.css"
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/Resizable.js"
		    }

		    Ext.widgets.Shadow {
			my ensureLoaded XO.Core
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/Shadow.js"
		    }

		    XO.Dialog {
			my ensureLoaded XO.Core
			my ensureLoaded XO.ComponentShadowLayer
			###my ensureLoaded -targetName Dialog Ext.widgets.BasicDialog
		    }
		    Ext.widgets.BasicDialog {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/legacy/BasicDialog.js"
			my importCSS "/lib/ext-${extVersion}/resources/css/dialog.css"
		    }


		    Ext.data.Connection {
			#my ensureLoaded Ext.util.Observable
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/data/Connection.js"
		    }


		    Ext.Data.Tree {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/data/Tree.js"
			my importCSS "/lib/ext-${extVersion}/resources/css/tree.css"
		    }
		    Ext.widgets.TreePanel {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/tree/TreePanel.js"
		    }
		    Ext.widgets.TabPanel {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/TabPanel.js"
			my importCSS "/lib/ext-${extVersion}/resources/css/tabs.css"
		    }
		    Ext.ux.TabCloseMenu {
			my ensureLoaded XO.Menu
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/ux/TabCloseMenu.js"
		    }
		    Ext.ux.SearchField {
			my ensureLoaded XO.Form
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/ux/SearchField.js"
		    }
		    Ext.ux.SelectBox {
			my ensureLoaded XO.Form
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/ux/SelectBox.js"
		    }
		    Ext.ux.ImageDragZone {
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/ux/ImageDragZone.js"
		    }
		    Ext.ux.Multiselect {
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/ux/Multiselect/Multiselect.js"
                        my importCSS "/lib/xo-${xoVersion}/resources/css/Multiselect.css"
		    }
		    Ext.ux.DDView {
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/ux/Multiselect/DDView.js"
		    }
		    Ext.ux.form.DateTime {
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/ux/Ext.ux.form.DateTime.js"
		    }
		    Ext.widgets.TreeLoader {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/tree/TreeLoader.js"
		    }
		    Ext.widgets.TreeSorter {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/tree/TreeSorter.js"
		    }
		    Ext.widgets.TreeEventModel {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/tree/TreeEventModel.js"
		    }
		    Ext.widgets.AsyncTreeNode {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/tree/AsyncTreeNode.js"
		    }
		    Ext.widgets.TreeNode {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/tree/TreeNode.js"
		    }
		    Ext.widgets.TreeNodeUI {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/tree/TreeNodeUI.js"
		    }
		    Ext.widgets.tree.ColumnNodeUI {
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/tree/ColumnNodeUI.js"
                        my importCSS "/lib/xo-${xoVersion}/resources/css/column-tree.css"
		    }
		    Ext.widgets.TreeEditor {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/tree/TreeEditor.js"
		    }
		    Ext.widgets.TreeDropZone {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/tree/TreeDropZone.js"
		    }
		    Ext.widgets.TreeDragZone {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/tree/TreeDragZone.js"
		    }
		    Ext.widgets.TreeSelectionModel {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/tree/TreeSelectionModel.js"
		    }


		    XO.Tree {
			my ensureLoaded XO.Core
			my ensureLoaded XO.Panel
			my ensureLoaded XO.Form
			my ensureLoaded XO.Editor
			my ensureLoaded -targetName Tree \
			    Ext.Data.Tree \
			    Ext.widgets.TreePanel \
			    Ext.widgets.TreeEventModel \
			    Ext.widgets.TreeNodeUI \
			    Ext.widgets.TreeNode \
			    Ext.widgets.TreeEditor \
			    Ext.widgets.TreeSelectionModel \
			    Ext.widgets.TreeEventModel \
			    Ext.widgets.AsyncTreeNode \
			    Ext.widgets.TreeLoader \
			    Ext.widgets.TreeSorter \
			    Ext.widgets.tree.ColumnNodeUI
		    }

		    XO.Editor {
			my ensureLoaded XO.DataView
		    }

		    Ext.widgets.Editor {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/Editor.js"
		    }

		    Ext.widgets.Panel {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/Panel.js"
			my importCSS "/lib/ext-${extVersion}/resources/css/panel.css"
			my importCSS "/lib/ext-${extVersion}/resources/css/borders.css"
			my importCSS "/lib/ext-${extVersion}/resources/css/layout.css"
		    }

		    Ext.widgets.PanelDD {
			my ensureLoaded XO.DD
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/PanelDD.js"
		    }

		    Ext.grid.RowNumberer {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/grid/RowNumberer.js"
		    }
		    Ext.grid.ColumnDD {
			my ensureLoaded XO.DD
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/grid/ColumnDD.js"
		    }
		    Ext.grid.ColumnSplitDD {
			my ensureLoaded XO.DD
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/grid/ColumnSplitDD.js"
		    }
		    Ext.grid.ColumnModel {
			my ensureLoaded Ext.grid.RowNumberer
			my ensureLoaded Ext.grid.ColumnDD
			my ensureLoaded Ext.grid.ColumnSplitDD
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/grid/ColumnModel.js"
		    }
		    Ext.grid.AbstractSelectionModel {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/grid/AbstractSelectionModel.js"
		    }
		    Ext.grid.CellSelectionModel {
			my ensureLoaded Ext.grid.AbstractSelectionModel
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/grid/CellSelectionModel.js"
		    }
		    Ext.grid.RowSelectionModel {
			my ensureLoaded Ext.grid.AbstractSelectionModel
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/grid/RowSelectionModel.js"
		    }
		    Ext.grid.RowExpander {
			my ensureLoaded XO.Base
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/Ext.grid.RowExpander-2.0.2.js"
		    }
		    Ext.grid.CheckboxSelectionModel {
			my ensureLoaded Ext.grid.AbstractSelectionModel
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/grid/CheckboxSelectionModel.js"
		    }
		    Ext.grid.GridDD {
			my ensureLoaded XO.DD
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/grid/GridDD.js"
		    }
		    Ext.grid.GridView {
			my ensureLoaded Ext.grid.GridDD
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/grid/GridView.js"
		    }
		    Ext.grid.GroupingView {
			my ensureLoaded Ext.grid.GridView
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/grid/GroupingView.js"
		    }
		    Ext.grid.GridPanel {
			my ensureLoaded Ext.grid.ColumnModel
			my ensureLoaded Ext.grid.RowSelectionModel
			my ensureLoaded Ext.grid.GridView
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/grid/GridPanel.js"
		    }
		    Ext.grid.EditorGrid {
			my ensureLoaded Ext.grid.CellSelectionModel
			my ensureLoaded Ext.grid.GridPanel
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/grid/EditorGrid.js"
		    }
		    Ext.grid.GridEditor {
			my ensureLoaded XO.Editor
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/grid/GridEditor.js"
		    }
		    Ext.grid.PropertyGrid {
			my ensureLoaded Ext.grid.GridEditor
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/grid/PropertyGrid.js"
		    }

		    XO.Grid {
			my ensureLoaded XO.Core
			my ensureLoaded XO.Panel
			my ensureLoaded XO.Form.Extra
			my ensureLoaded XO.Store
			my ensureLoaded -targetName GP \
			    Ext.grid.RowNumberer \
			    Ext.grid.GridDD \
			    Ext.grid.GridView \
			    Ext.grid.ColumnDD \
			    Ext.grid.ColumnSplitDD \
			    Ext.grid.ColumnModel \
			    Ext.grid.AbstractSelectionModel \
			    Ext.grid.CellSelectionModel \
			    Ext.grid.RowSelectionModel \
			    Ext.grid.CheckboxSelectionModel \
			    Ext.grid.GridPanel \
			    Ext.grid.EditorGrid \
			    Ext.grid.GridEditor \
			    Ext.grid.PropertyGrid \
			    Ext.grid.GroupingView \
			    Ext.grid.RowExpander \
			    Ext.ux.grid.livegrid.Store \
			    Ext.ux.grid.livegrid.JsonReader \
			    Ext.ux.grid.livegrid.JsonStore \
			    Ext.ux.grid.livegrid.DragZone \
			    Ext.ux.grid.livegrid.GridView \
			    Ext.ux.grid.livegrid.RowSelectionModel \
			    Ext.ux.grid.livegrid.GridPanel \
			    Ext.ux.grid.livegrid.EditorGridPanel \
			    Ext.ux.grid.livegrid.Toolbar


			my importCSS "/lib/ext-${extVersion}/resources/css/grid.css"
			my importCSS "/lib/xo-${xoVersion}/resources/css/ext-ux-livegrid.css"
		    }

		    Ext.ux.grid.livegrid.Store {
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/ux/LiveGrid/Store.js"
		    }
		    Ext.ux.grid.livegrid.JsonReader {
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/ux/LiveGrid/JsonReader.js"
		    }
		    Ext.ux.grid.livegrid.JsonStore {
			my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/ux/LiveGrid/JsonStore.js"
		    }
		    Ext.ux.grid.livegrid.DragZone {
                        my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/ux/LiveGrid/DragZone.js"
                    }
		    Ext.ux.grid.livegrid.GridView {
                        my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/ux/LiveGrid/GridView.js"
                    }
		    Ext.ux.grid.livegrid.RowSelectionModel {
                        my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/ux/LiveGrid/RowSelectionModel.js"
                    }
		    Ext.ux.grid.livegrid.GridPanel {
                        my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/ux/LiveGrid/GridPanel.js"
                    }
		    Ext.ux.grid.livegrid.EditorGridPanel {
                        my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/ux/LiveGrid/EditorGridPanel.js"
                    }
		    Ext.ux.grid.livegrid.Toolbar {
                        my importJS -targetName $targetName "/lib/xo-${xoVersion}/source/ux/LiveGrid/Toolbar.js"
                    }

		    XO.Panel {
			my ensureLoaded XO.L_DD_P
		    }
		    XO.TabPanel {
			my ensureLoaded XO.L_DD_P
		    }

		    Ext.widgets.LoadMask {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/LoadMask.js"
		    }

		    
		    XO.QuickTips {
			my ensureLoaded XO.L_DD_P
		    }
		    Ext.widgets.Tip {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/tips/Tip.js"
		    }
		    Ext.widgets.ToolTip {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/tips/ToolTip.js"
		    }
		    Ext.widgets.QuickTip {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/tips/QuickTip.js"
		    }
		    Ext.widgets.QuickTips {
			my importJS -targetName $targetName "/lib/ext-${extVersion}/source/widgets/tips/QuickTips.js"
			my importCSS "/lib/ext-${extVersion}/resources/css/qtips.css"
		    }




		    EXT.CSS.Grid {
			my importCSS "/lib/ext-${extVersion}/resources/css/grid.css"
		    }



		    YUI.CSS.Reset {
			my importCSS "/lib/yui-${yuiVersion}/build/reset/reset.css"
		    }
		    YUI.CSS.Fonts {
			my importCSS "/lib/yui-${yuiVersion}/build/fonts/fonts.css"
		    }
		    YUI.CSS.Grids {
			my importCSS "/lib/yui-${yuiVersion}/build/grids/grids.css"
		    }
		    YUI.CSS.Reset-Fonts-Grids {
			my ensureLoaded YUI.CSS.Reset
			my ensureLoaded YUI.CSS.Fonts
			my ensureLoaded YUI.CSS.Grids
		    }


		    SWF {
			my importJS -targetName $targetName "/lib/xo-1.0.0/players/flv-3.12/swfobject.js"
		    }

		    MPL {
			my importJS -targetName $targetName "/lib/mpl-3.8/swfobject.js"
		    }

		    XO.SWF {
			my ensureLoaded -targetName SWF \
			    SWF
		    }

		    XO.CSS.NavTabView {
			my importCSS "/lib/xo-${xoVersion}/resources/css/NavTabView.css"
		    }


		    YUI-Carousel {
			my importCSS "/resources/yui-misc/css/carousel.css"
			my importJS -targetName $targetName "/js/yui-misc/widgets/Carousel.js"
		    }
		    YUI-MISC.widget.Accordion {
			my importCSS "/resources/yui-misc/css/accordion.css"
			my importJS -targetName $targetName "/js/yui-misc/widgets/Accordion.js"
		    }
		    YUI-SKIN.css.XP {
			my importCSS "/resources/yui-skin/css/xp.css"
		    }
		    YUI-SKIN.css.Aqua {
			my importCSS "/resources/yui-skin/css/aqua.css"
		    }
		    YUI-SKIN.css.BorderTabs {
			my importCSS "/css/yui/build/tabview/assets/border_tabs.css"
		    }
		    YUI-EXT.css.Tabs {
			my importCSS "/resources/yui-ext/css/tabs.css"
		    }
		    YUI-EXT.css.Layout {
			my importCSS "/resources/yui-ext/css/layout.css"
		    }
		    MISC.widget.MultiFile {
			my importJS -targetName $targetName "/js/multifile/multifile.js"
		    }

		    XO.CodePress {
			my ensureLoaded -targetName CP \
			    CodePress.MainCode \
			    CodePress.Editor-Javascript \
			    CodePress.Editor-Java \
			    CodePress.Editor-SQL \
			    CodePress.Editor-PHP \
			    CodePress.Editor-CSS \
			    CodePress.Editor-PERL \
			    CodePress.Editor-HTML \
			    CodePress.Editor-CSS
		    }

		    CodePress.MainCode {
			my importCSS "/resources/codepress/codepress.css"
			my importJS -targetName $targetName "/resources/codepress/codepress.js"
		    }
		    CodePress.Editor-Javascript {
			my ensureLoaded CodePress.MainCode
			my importCSS "/resources/codepress/languages/codepress-javascript.css"
			my importJS -targetName $targetName "/resources/codepress/languages/codepress-javascript.js"
		    }
		    CodePress.Editor-Java {
			my ensureLoaded CodePress.MainCode
			my importCSS "/resources/codepress/languages/codepress-java.css"
			my importJS -targetName $targetName "/resources/codepress/languages/codepress-java.js"
		    }
		    CodePress.Editor-SQL {
			my ensureLoaded CodePress.MainCode
			my importCSS "/resources/codepress/languages/codepress-sql.css"
			my importJS -targetName $targetName "/resources/codepress/languages/codepress-sql.js"
		    }
		    CodePress.Editor-PHP {
			my ensureLoaded CodePress.MainCode
			my importCSS "/resources/codepress/languages/codepress-php.css"
			my importJS -targetName $targetName "/resources/codepress/languages/codepress-php.js"
		    }
		    CodePress.Editor-CSS {
			my ensureLoaded CodePress.MainCode
			my importCSS "/resources/codepress/languages/codepress-css.css"
			my importJS -targetName $targetName "/resources/codepress/languages/codepress-css.js"
		    }
		    CodePress.Editor-PERL {
			my ensureLoaded CodePress.MainCode
			my importCSS "/resources/codepress/languages/codepress-perl.css"
			my importJS -targetName $targetName "/resources/codepress/languages/codepress-perl.js"
		    }
		    CodePress.Editor-HTML {
			my ensureLoaded CodePress.MainCode
			my importCSS "/resources/codepress/languages/codepress-html.css"
			my importJS -targetName $targetName "/resources/codepress/languages/codepress-html.js"
		    }

		    YUI-MISC.widget.Editor {
			my ensureLoaded YUI.util.Yahoo-DOM-Event
			my ensureLoaded YUI.util.Animation
			my ensureLoaded YUI.util.Container
			my ensureLoaded YUI.widget.Menu
			my importCSS "/resources/yui-misc/css/editor.css"
			my importJS -targetName $targetName "/js/yui-misc/widgets/create.js"
			my importJS -targetName $targetName "/js/yui-misc/widgets/editor.js"
		    }
		}
	    }
	}
    }

    ####if { $targetName ne {} } { my jsLoad -targetName $targetName [my set __acc($targetName)] }
    if { $targetName ne {} } {
	my lappend __jsList $targetName
    }

}


::xo::ui::RenderingVisitor instproc onDocumentReady {fn scope override} {
    my ensureLoaded YUI-EXT.EventManager
    my inlineJavascript [subst -nocommands -nobackslashes {
	YAHOO.ext.EventManager.onDocumentReady(${fn}, ${scope}, ${override});
    }]
}

::xo::ui::RenderingVisitor instproc onReady {fn scope override} {
    my ensureLoaded XO.Core
    my inlineJavascript [subst -nocommands -nobackslashes {
	Ext.onReady(${fn},${scope},${override});
    }]
}

::xo::ui::RenderingVisitor instproc onContentReady { domNodeId fn } {
    my inlineJavascript [subst -nocommands -nobackslashes { 
	YAHOO.util.Event.onContentReady("${domNodeId}", ${fn});
    }]
}

# Visitor instproc releaseOn {host}

################################################






Class ::xo::ui::PageMarshallerVisitor -superclass {::xo::base::NodeLabelVisitor} -parameter {
    {select ""}
    {action ""}
    {format "html"}
    {page_file "[ad_conn file]"}
    {debug_p false}
}

::xo::ui::PageMarshallerVisitor instproc init {} {


    my instvar select
    my instvar action


    #lastChar of action to check whether we need to check the signature

    set extension [file extension [ad_conn file]]
    set lastChar [string index [ad_conn path_info] end]
    if { $extension eq {.vuh} && ${lastChar} eq {X} } {
	lassign [split [ad_conn path_info] -] select action X
	if { $action eq {} } {
	    set action draw
	}
    } else {
	set select [::xo::kit::queryget select]
	set action [::xo::kit::queryget action draw]
    }

    set signature ""
    lassign [split $action _] action signature
    if { ${signature} ne {} } {
	set signature2 [ns_sha1 ${select}-${action}-sEcReT-7842134]
	if { ${signature} ne ${signature2} } {
	    ns_return 200 text/plain "Invalid Request"
	    return
	} else {
	    set action ${action}-S
	}
    }

    #ns_log notice "select=$select action=$action"
    # First Label the nodes
    set result [next]
    my iaccept -action setLabel [self]
    my go -select $select -action $action

    return $result
}

::xo::ui::PageMarshallerVisitor instproc go {-select -action} {
    set select [::util::coalesce $select [my domNodeId]]
    my set select $select
    ###ns_log notice "HERE: select=$select, action=$action file=[ad_conn file]"

    [my getElement ${select}] action(${action}) [self]

}

::xo::ui::PageMarshallerVisitor instproc action(draw) {marshaller} {

    set visitor [RenderingVisitor new]

    [$visitor content] appendFromScript {
	[my getElement [my select]] accept $visitor
    }

    $visitor instvar __jsNode __js __jsList
    my instvar debug_p
    if { [exists_and_not_null __js] } {
	if { $debug_p } {
	    $__jsNode appendFromScript { t -disableOutputEscaping $__js }
	} else {

	    $__jsNode appendFromScript { t -disableOutputEscaping [::xo::js::get_compiled UI.[string map {/ .} [ad_conn file]] $__js SIMPLE_OPTIMIZATIONS] }

	    #{  $__jsNode appendFromScript { t -disableOutputEscaping [jsmin::jsmin $__js] }  }
	}
    }
    if { [exists_and_not_null __jsList] } {
	set host [ad_conn protocol]://www.phigita.net/
	set targetURLs [$visitor prepareJS $__jsList]
	foreach url $targetURLs {
	    set href [::uri::canonicalize ${host}${url}]
	    [$visitor body] insertBeforeFromScript [subst {
		script -type "text/javascript" -src $href
	    }] $__jsNode
	}
    }

    $visitor instvar __styleNode __style __styleList
    if { [exists_and_not_null __style] } {
	$__styleNode appendFromScript { t -disableOutputEscaping $__style }
    }
    if { [exists_and_not_null __styleList] } {
	#ns_log notice styleList=$__styleList
	set host [ad_conn protocol]://www.phigita.net/
	set targetURLs [$visitor prepareCSS $__styleList]
	foreach url $targetURLs {
	    set href [::uri::canonicalize ${host}${url}]
	    [$visitor body] insertBeforeFromScript [subst {
		t -disableOutputEscaping {<link rel="stylesheet" type="text/css" href="$href" />}
	    }] $__styleNode
	}
    }
    doc_return 200 text/html [[$visitor domDoc] asHTML -doctypeDeclaration true]
}

::xo::ui::PageMarshallerVisitor instproc getElement {id} {
    my instvar objectFrom
    ###ns_log notice "objectFrom=[array names objectFrom]"
    if {[info exists objectFrom($id)]} {
	return $objectFrom($id)
    } else {
	return ""
    }
}

