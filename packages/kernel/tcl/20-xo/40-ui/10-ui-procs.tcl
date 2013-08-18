package require base64

# designMode, editMode, displayMode
# outputFormat (html, rss, csv, xml)
# dynamic server/user pages (where does the page gets created?)

namespace eval ::xo {;}
namespace eval ::xo::ui {;}


Class ::xo::ui::Class -superclass "::xotcl::Class" -parameter {
    {jsClass ""}
    {jsExpandConfig "false"}
    {tclInitTime "[clock seconds]"}
    {__configOptions ""}
}

::xo::ui::Class instproc configOptions {options} {
    my set __configOptions [::util::map ::util::head $options]
    my parameter [concat [my info parameter] $options]
    my instproc getConfigOptions {} {
	[self class] instvar __configOptions
	return [lsort -unique [concat [next] $__configOptions]]
    }
}


Class ::xo::ui::EventManager
::xo::ui::EventManager instproc subscribe { eventName eventHandler fn } {
    my appendChild -rel Event [Event new -eventHandler $eventHandler -eventName ${eventName} -fn ${fn} -scope [self]]
}


::xo::ui::EventManager instproc on {eventName eventHandler fn} {
    my subscribe $eventName $eventHandler ${fn}
}


::xo::ui::Class ::xo::ui::Element -superclass {::xo::base::Composite ::xo::ui::EventManager} -parameter {
    {domNodeId ""}
    {label ""}
    {style ""}
    {cssClass ""}
    {listeners ""}
    {extraInfo ""}
    {map ""}
}

::xo::ui::Element instproc getConfigOptions {} {
}

::xo::ui::Element instproc appendFromScript {script} {
    namespace path {::xo::ui ::template}
    return [next]
}

::xo::ui::Element instproc getConfig {} {
    [my info class] instvar jsExpandConfig

    set result ""
    foreach {key value} [my getConfigOptions] {
	if {$jsExpandConfig} {
	    lappend result $value
	} else {
	    lappend result ${key}:${value}
	}
    }

    set result [join ${result} {,}]
    if { !${jsExpandConfig} } {
	set result "\{${result}\}"
    }
    return $result
}

::xo::ui::Element instproc getConstructor {} {
    [my info class] instvar jsClass
    my instvar domNodeId
    set config [my getConfig]
    set aliases [my getAliases]
    return "${aliases}${domNodeId}=new ${jsClass}(${config});"
}

::xo::ui::Element instproc getPatches {} {
    return [next]
}

::xo::ui::Element instproc getJS {} {

    my instvar domNodeId

    set listeners [my getListeners]
    set extraInfoConfig [my getExtraInfoConfig]
    set code [my getConstructor]
    set patches [my getPatches]

    set result [subst -nobackslashes -nocommands {
	var ${domNodeId};
	var _${domNodeId} = function(){
	    return {
		init : function(){
		    ${code}
		    ${listeners}
		    ${extraInfoConfig}
		}
	    }
	}();
	${patches}
    }]

    return $result

}

::xo::ui::Element instproc getAliases {} {
    my instvar map
    set result ""
    foreach item $map {
	if { [llength $item] == 2 } {
	    lassign $item o aliasName
	    set objectName [$o domNodeId]
	} else {
	    set objectName [$item domNodeId]
	    set aliasName [namespace tail $item]
	}
	lappend result "${aliasName}=top.${objectName}"
    }
    if { ${result} ne {} } {
	set result "var [join ${result} {,}];"
    }
    return ${result}
}

::xo::ui::Element instproc getExtraInfoConfig {} {
    my instvar extraInfo
    set __xo__ ""
    foreach {varName o} $extraInfo {
	if { [string index $o 0] eq {'} } {
	    set value $o
	} else {
	    set value '[$o domNodeId]'
	}
	lappend __xo__ "${varName} : $value"
    }
    if { $__xo__ ne {} } {
	my instvar domNodeId
	set __xo__ \{[join $__xo__ ,]\}
	return "${domNodeId}.__xo__ = ${__xo__};Ext.applyIf(${domNodeId}.attributes,${__xo__});"
    } else {
	return
    }
}

::xo::ui::Element instproc getListeners {} {
    my instvar domNodeId
    set eventConfig ""
    foreach {eventName fnObject} [my listeners] {
	if {[llength $fnObject]>1} {
	    foreach {key value} $fnObject {
		if { $key eq {fn} } { set value ${value} }
		lappend line_conf ${key}:${value}
	    }
	    set line_conf \{[join $line_conf {,}]\}
	} else {
	    set line_conf "{fn:[${fnObject} domNodeId], scope:${domNodeId}}"
	}
	lappend eventConfig "'${eventName}' : $line_conf"
    }

    if { $eventConfig ne {} } {
	my instvar domNodeId
	return "${domNodeId}.on(\{[join $eventConfig ,]\});"
    } else {
	return
    }
}

::xo::ui::Element instproc iaccept {{-action "visit"} visitor} {
    $visitor $action [self]
    #HERE: FIX ME, CHECK base-procs.tcl AS WELL: foreach rel [my __rels]
    #my childNodes -rel ${rel}
    foreach child [my childNodes] {
	$child iaccept -action $action $visitor
    }
}



Class ::xo::ui::Event -superclass {::xo::ui::Element} -parameter {
    {eventName ""}
    {eventHandler ""}
    {fn ""}
    {scope ""}
    {override "true"}
}


::xo::ui::Event instproc render {visitor} {
    my instvar eventName eventHandler fn scope override
    $scope instvar {domNodeId scopeDomNodeId}
    $eventHandler instvar {domNodeId handlerDomNodeId}
    #set visitor [self callingobject]

    $visitor inlineJavascript [subst -nobackslashes {
	var [my domNodeId] = function(){
	    return {
		init : function(){
		    Ext.get('${scopeDomNodeId}').on('${eventName}',${handlerDomNodeId}.${fn},${handlerDomNodeId},${override});
		}
	    };
	}();
    }]

    $visitor onReady [my domNodeId].init [my domNodeId] true
}



#_[string trimleft [namespace tail [self]] _\#]
::xo::ui::Class ::xo::ui::Widget -superclass {::xo::ui::Element} -parameter {
    {name "[namespace tail [self]]"}
    {domNode ""}
    {cssClass ""}
    {style ""}
    {skin ""}
    {export_vars ""}
    {override_vars ""}
    {master ""}
    varNameIn
    varNameOut
}


::xo::ui::Widget instproc new {args} {
    set o [next]
    $o name ""
    return $o
}


::xo::ui::Widget instproc init {} {
    my instvar master
    if { $master ne {} } {
	my mixin add ${master}
    }
    set result [next]
    return $result
}

::xo::ui::Widget instproc accept {{-rel "default"} {-action "visit"} visitor} {
    my instvar domNode
    set domNode [$visitor $action [self]]
    if { $domNode ne {} } {
	$domNode appendFromScript {
	    # here: -rel $rel
	    foreach child [my childNodes] {
		set innerNode [$child accept -action $action $visitor]
	    }
	}
    }
    return $domNode
}


::xo::ui::Widget instproc render {visitor} {
    #set visitor [self callingobject]

    $visitor ensureNodeCmd elementNode div

    if { [my style] ne {} } {
	$visitor inlineStyle "\#_[my domNodeId] \{ [my style] \}"
    }

    my instvar varNameIn
    if { [info exists varNameIn] } {
	$visitor instvar [list $varNameIn node]
    }
    if { ![info exists node] } {
	set node [div -id _[my domNodeId]]
    }


    if { [my cssClass] ne {} } {
	$node setAttribute class [my cssClass]
    }
    return $node
}

::xo::ui::Widget instproc getSignature {text} {
    return [ns_sha1 ${text}-sEcReT-7842134]
}

::xo::ui::Widget instproc uri {{-sign "false"} {-base ""} {-baseParams ""} {-select ""} {-action ""} {-exportIf ""} {-allow_vuh_p "true"} args} {

    my instvar {override_vars override} export_vars

    if { $base eq {} } {
	set base [ns_conn url]
    }

    foreach pair $args {
	lassign $pair key value
	lappend override [list ${select}_${action}_${key} $value]
    }

    foreach {key value} $baseParams {
	lappend override [list $key $value]
    }

    ### URI Signature
    #    set time [ns_time]
    #    lappend override [list ${select}_${action}.time ${time}]
    #    lappend override [list ${select}_${action}.signature [ns_sha1 SiGnAtUrE-${action}-${select}-${time}]
    
#    set cmd [join [list $select $action $time $signature] -]
#    lappend override [list q $cmd]
#    return [export_vars -base [ns_conn url] -override $override

    set signature ""
    if { ${sign} } {
	set signature [my getSignature ${select}-${action}]
	set action ${action}_${signature}
    }

    set extension [file extension [ad_conn file]]
    if { $allow_vuh_p && $extension eq {.vuh} } {
	return [export_vars -base ${base}[join [concat $select $action X] -] -override $override $export_vars]
    } else {
	return [export_vars -base $base -override $override [join "{select action} $exportIf $export_vars"]]
    }
}

::xo::ui::Widget instproc queryget {{-select ""} {-action ""} key} {
    return [::xo::kit::queryget ${select}_${action}_${key}]
}

::xo::ui::Widget instproc singlequote {name} {
    return '[string map {{'} {\'}} [my $name]]'
}

::xo::ui::Widget instproc doublequote {name} {
    return \"[string map {{"} {\"}} [my $name]]\"
}



::xo::ui::Class ::xo::ui::Page -parameter {
    {title ""}
    {alt ""}
} -superclass {::xo::ui::Widget}

# Move the following into the request handler
::xo::ui::Page instmixin add ::xo::ui::PageMarshallerVisitor end

