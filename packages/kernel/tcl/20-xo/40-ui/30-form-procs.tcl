namespace eval ::xo {;}
namespace eval ::xo::ui {;}



Class ::xo::ui::ControlTrait


Class ::xo::ui::Box -superclass {::xo::ui::Widget}

::xo::ui::Box instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureNodeCmd elementNode div

    [next] appendFromScript {
	div -class "x-box-tl" { 
	    div -class "x-box-tr" { 
		div -class "x-box-tc" 
	    } 
	}
	div -class "x-box-ml" {
	    div -class "x-box-mr" { 
		set innerNode [div -class "x-box-mc"]
	    }
	}
	div -class "x-box-bl" {
	    div -class "x-box-br" {
		div -class "x-box-bc"
	    }
	}
    }
    return $innerNode
}



Class ::xo::ui::Form.Component -superclass {::xo::base::Component}

::xo::ui::Form.Component instproc init {args} {
    global __FORM_CONTEXT__
    if { [info exists __FORM_CONTEXT__] } {
	set o [lindex $__FORM_CONTEXT__ end]
	$o appendChild -rel __FORM_FIELD__ [self]
    }
    return [next]
}

::xo::ui::Class ::xo::ui::Action -superclass {::xo::ui::Widget} -parameter {
    {name ""}
    {body ""}
    {sign "true"}
    {exportIf ""}
}


::xo::ui::Action instproc init {args} {
    set result [next]
    my instvar name body sign
    set extra [::util::decode [::util::boolean $sign] 1 "-S" 0 ""]
    my proc action(${name}${extra}) {marshaller} ${body}
    #ns_log notice procs=[my info procs]
    return $result
}

::xo::ui::Action instproc render {visitor} {
    my instvar domNodeId name sign exportIf 
    set uri [my uri -sign ${sign} -exportIf $exportIf -select ${domNodeId} -action ${name}]
    $visitor inlineJavascript "${domNodeId}='${uri}';"
    return [next]
}

::xo::ui::Class ::xo::ui::Form -superclass {::xo::ui::Widget} -parameter {
    {url ""}
    {action "validate"}
    {method "POST"}
    {layout ""}
    {enctype "multipart/form-data"}
    {labelAlign "'left'"}
    {labelWidth ""}
    {iconCls ""}
    {layoutConfig ""}
    {title ""}
    {allowDomMove ""}
    {monitorValid "true"}
    {monitorPoll "200"}
    {monitorResize "true"}
    {activeItem ""}
    {autoWidth ""}
    {autoHeight ""}
    {width ""}
    {height ""}
    {defaults ""}
    {standardSubmit true}
    {disabled ""}
    {maskDisabled ""}
    {style ""}
    {submitText "Submit"}
    {submitOptions ""}
} -jsClass Ext.form.FormPanel



::xo::ui::Form instproc getConfig {} {

    my instvar domNodeId submitText style submitOptions

    set varList {
	labelAlign
	labelWidth
	layout
	iconCls
	layoutConfig
	title
	allowDomMove
	monitorValid
	monitorPoll
	monitorResize
	activeItem
	autoWidth
	autoHeight
	width 
	height
	defaults
	standardSubmit
	disabled
	maskDisabled
    }


    set config ""
    lappend config "applyTo:'_$domNodeId'"
    #lappend config "autoEl:Ext.get('$domNodeId')"
    #lappend config "body:'${domNodeId}'"
    lappend config [subst -nocommands {
	buttons:[{
	    text: '${submitText}',
	    type:'submit',
	    formBind:true,
	    handler:function(btn,e){
		var frm=${domNodeId}.getForm();
		frm.items.each(function(f){
		    if (f.syncValue) {
			try {
			    f.syncValue();
			} catch (ex) {
			    e.stopEvent();
			    alert('Our apologies... An error has occured! Send us an email to report this problem.');
			}
		    }
		});
		frm.submit(${submitOptions});
	    }
	}]
    }]
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    set items ""
    foreach o [my getFields] {
	set cl [$o info class]
	if { $cl eq {::xo::ui::FileField} } {
	    lappend config "fileUpload:true"
	}
	if { [$cl info class] eq {::xo::ui::Class} } {
	    lappend items [$o domNodeId]
	} else {
	    ns_log notice "$cl must be rewritten as an ::xo::ui::Class"
	}
    }
    if { $style ne {} } { 
	lappend config "style:'${style}'"
    }
    if { $items ne {} } { 
	lappend config "items: \[[join ${items} {,}]\]"
    }

    return \{[join $config {,}]\}

}

::xo::ui::Form instproc appendFromScript {args} {
    global __FORM_CONTEXT__
    lappend __FORM_CONTEXT__ [self]
    ### ::xo::ui::Form.Field instmixin ::xo::ui::Form.Component
    set result [next]
    ### ::xo::ui::Form.Field instmixin delete ::xo::ui::Form.Component

    return $result
}

::xo::ui::Form instproc action(upload_stats) {marshaller} {
    set url [ns_conn url]
    set stats [ns_upload_stats $url]

    # HERE: nginx needs upload progress module
    #ns_log notice "upload_stats = $stats url = $url"

     # Calculate percentage
    if { $stats != "" } {
	foreach { current size } $stats {}
	set stats [expr round($current.0*100/$size.0)]
    }
     ns_return 200 text/html $stats
}
::xo::ui::Form instproc getFields {} {
    return [my set __childNodes(__FORM_FIELD__)]
}

::xo::ui::Form instproc getDict {} {
    set mydict [dict create]
    foreach o [my getFields] {
	set mydict [dict merge $mydict [$o getValue]]
    }
    #ns_log notice "mydict=$mydict"
    return $mydict
}

::xo::ui::Form instproc initFromDict {mydict} {
    array set myfields [list]
    foreach o [my getFields] {
	set myfields([$o set name]) $o
    }
    foreach {key value} $mydict {
	#ns_log notice "initFromDict: key=$key value=$value o=$myfields($key) cl=[$myfields($key) info class]"
	$myfields($key) setValueTo $value
    }
}

::xo::ui::Form instproc initFromObject {o} {
    #ns_log notice "initFromObject, info vars= [$o info vars]"
    foreach ff [my getFields] {
	if { [$o exists [$ff name]] } {
	    $ff setValueTo [$o set [$ff name]]
	}
    }
}


::xo::ui::Form instproc markInvalidFields {} {
    foreach o [my getFields] {
	$o set value [$o getRawValue]
	if { ![$o isValid] } {
	    $o markInvalid "Failed Validation"
	}
    }
}

::xo::ui::Form instproc isValid {} {
    set result 1
    foreach o [my getFields] {
	### ns_log notice "[$o info class] $o isValid=[$o isValid]"
	### if { ![$o isValid] } { ns_log notice "$o->[$o name] is not valid" }
	set result [expr { ${result} && [$o isValid] }]
    }
    
    return $result

    set comment {
	foreach o [my set childNodes -rel __FORM_GUARD__] {
	    set result [expr { ${result} && [$o check [self]] }]
	}
    }
}

::xo::ui::Form instproc getConstructor {} {
    my instvar domNodeId;
    return "Ext.get('p_${domNodeId}').setDisplayed(false);[next];"
}

::xo::ui::Form instproc accept {{-rel default} {-action "visit"} visitor} {

    set result [next]

    my instvar domNodeId


    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true
    return $result

}

::xo::ui::Form instproc render {visitor} {

    $visitor ensureNodeCmd elementNode form input h3 div table tbody tr td em button i img span
    $visitor ensureLoaded XO.Form

    my instvar domNodeId label labelAlign action url method enctype


    $visitor ensureLoaded XO.Form.Date


    set node [next] 
    $node setAttribute class x-panel-mc
    $node appendFromScript {
	set formNode [form -id $domNodeId -class "x-form x-panel-body" -method $method -style "border:0;" {
	    set innerNode [div -class "x-form-ct" {
		input -type hidden -name select -value $domNodeId
		input -type hidden -name action -value $action
	    }]
	    div  -class "x-panel-footer" {
		div -id p_$domNodeId -class "x-form-btns-ct" {
		    div -class "x-form-btns x-form-btns-center" {
			button -id btn_$domNodeId -type submit -class "x-btn-text" { t [my submitText] }
		    }
		}
	    }

	}]
	
	if { $enctype ne {} } {
	    $formNode setAttribute enctype $enctype
	}
	if { $url ne {} } {
	    $formNode setAttribute action $url
	}			    
	if { [my style] ne {} } {
	    $node setAttribute style [my style]
	}

    }
    return $innerNode
}


::xo::ui::Form instproc render-OLD2 {visitor} {

    $visitor ensureNodeCmd elementNode form input h3 div table tbody tr td em button i img span
    $visitor ensureLoaded XO.Form

    my instvar domNodeId label labelAlign action url method enctype


    $visitor ensureLoaded XO.Form.Date


    set node [next] 
    $node setAttribute class "x-panel"
    if { [my style] ne {} } {
	$node setAttribute style [my style]
    }
    $node appendFromScript {
	div -class "x-panel-tl" {
	    if { $label ne {} } {
		div -class "x-panel-tr" {
		    div -class "x-panel-tc" {
			div -class "x-panel-header x-unselectable" {
			    span -class "x-panel-header-text" {
				t $label
			    }
			}
		    }
		}
	    }
	}
	div -class "x-panel-bwrap" {
            div -class "x-panel-ml" {
                div -class "x-panel-mr" {

		    div -id __${domNodeId} -class x-panel-mc {
			div -class "x-panel-body" {
			    set formNode [form -id $domNodeId -class "x-form" -method $method {
				set innerNode [div -class "x-form-ct" {
				    input -type hidden -name select -value $domNodeId
				    input -type hidden -name action -value $action
				}]
				div -id p_$domNodeId  -class "x-form-btns-ct x-panel-bwrap" {
				    div -class "x-form-btns x-form-btns-center" {
					table -cellspacing "0" {
					    tbody {
						tr {
						    td -class "x-form-btn-td" {
							table -class "x-btn-wrap x-btn" -cellspacing "0" -cellpadding "0" -border "0" -style "width:75px;" {
							    tbody {
								tr {
								    td -class "x-btn-left" { i }
								    td -class "x-btn-center" {
									em {
									    button -id btn_$domNodeId -type submit -class "x-btn-text" { t Submit }
									}
								    }
								    td -class "x-btn-right" { i }
								}
							    }
							}
						    }
						}
					    }
					}
				    }
				}

			    }]
			    if { $enctype ne {} } {
				$formNode setAttribute enctype $enctype
			    }
			    
			    if { $url ne {} } {
				$formNode setAttribute action $url
			    }			    
			}
		    }
		}
	    }
	}
	div -class "x-panel-tl" {
            div -class "x-panel-tr" {
                div -class "x-panel-tc" {
                    div -class "x-panel-noheader x-unselectable"
                }
            }
        }
    }
    return $innerNode
}


::xo::ui::Form instproc renderOLD {visitor} {

    set upload_stats_uri [my uri -select [my domNodeId] -action upload_stats]

    set COMMENT {

        function showResult() {
            alert('test');
        }



	function [my domNodeId]__upload_stats() {
	    var now = new Date();
	    try { req = new ActiveXObject('Msxml2.XMLHTTP'); } catch (e) {
		try { req = new ActiveXObject('Microsoft.XMLHTTP'); } catch (e) {
		    if(typeof XMLHttpRequest != 'undefined') req = new XMLHttpRequest();
		}
	    }
	    req.open('GET','${upload_stats_uri}&t='+now.getTime(),false);
	    req.send(null);
	    var rc = parseInt(req.responseText);
	    var obj = document.getElementById('p_[my domNodeId]');
	    if(!isNaN(rc)) {
		obj.innerHTML = 'Progress: ' + rc + '%';
		setTimeout('[my domNodeId]__upload_stats()',1000);
	    } else {
		if(obj.innerHTML == '') setTimeout('[my domNodeId]__upload_stats()',1000);
	    }
	}
    }

    $visitor inlineJavascript [subst -nobackslashes {


        var [my domNodeId] = function(){
            return {
                init : function(){
		    var f = new Ext.form.FormPanel('[my domNodeId]',{
			labelAlign: 'right',
			labelWidth: 75
		    });
		    //f.applyTo(Ext.get('[my domNodeId]'));

		    Ext.get('[my domNodeId]').on('submit', function(e){
			
			Ext.MessageBox.show({
			    title: 'That\'s a test, Confirm',
			    width:300,
			    progress: true,
			    closable: false,
			    fn: showResult,
			    animEl: '[my domNodeId]'
			});

			//parent.setTimeout('[my domNodeId]__upload_stats()',1000);
			document.[my domNodeId].submit();
			return true;
		    });
		}
            };
        }();
    }]
    #$visitor onReady [my domNodeId].init [my domNodeId] true


    set node [next]
    $node appendFromScript {
	h3 { t [my label] }
	set formNode [form -id [my domNodeId] -name [my domNodeId] -class "x-form" -method [my method] -enctype [my enctype] -onsubmit "parent.setTimeout('[my domNodeId]__upload_stats()',1000);return true;"]
	if { [my url] ne {} } {
	    $formNode setAttribute action [my url]
	}
	$formNode appendFromScript {
	    #  x-form-label-top
	    set innerNode [div -class "x-form-ct" {
		input -type hidden -name select -value [my domNodeId]
# HERE: parameterize action
		input -type hidden -name action -value [my action]
	    }]

	    div -class "x-form-btns-ct" {
		div -class "x-form-btns x-form-btns-center" {
		    table -cellspacing "0" {
			tbody {
			    tr {
				td -class "x-form-btn-td" {
				    table -class "x-btn-wrap x-btn" -cellspacing "0" -cellpadding "0" -border "0" -style "width: 75px;" {
					tbody {
					    tr {
						td -class "x-btn-left" { i }
						td -class "x-btn-center" -id p_[my domNodeId] {
						    em {
							button -type submit -class "x-btn-text" { t Submit }
						    }
						}
						td -class "x-btn-right" { i }
					    }
					}
				    }
				}
			    }
			}
		    }
		}
	    }

	}
    }
    return $innerNode
}

::xo::ui::Form instproc action(validate) {marshaller} {
    ### upload file
    #set setid [ns_getform]
    #set filename [ns_set iget $setid upload_file]
    #set tmpfile [ns_queryget upload_file.tmpfile]
    #ns_return 200 text/html "Upload completed $filename [ns_set array $setid] size=[file size $tmpfile]"
    #return 

    #set visitor [self callingobject]
    set result ""
    set form [ns_getform]
    set size [ns_set size $form]
    lappend result "form=$form "
    for {set i 0} {$i < $size} {incr i} {
	set key [ns_set key $form $i]
	set value [ns_set value $form $i]
	set o [$visitor getElement $key]
	if { $o ne {} } {
	    lappend result r($key)=[$o action(validate) $value]
	} else {
	    lappend result "r($key)=non-validated($value)"
	}
    }

    set values ""
    foreach o [my set __childNodes(__FORM_FIELD__)] {
	lappend values "v([$o set name],[$o isValid])=[$o getValue]"
    }

    doc_return 200 text/plain ok-\nvalues=${values}\n-$result-\n-[::aux::mapobj "info class" [my set __childNodes(__FORM_FIELD__)]]\n

#-[my array names __childNodes]\n-[my info vars]

}





Class ::xo::ui::Form.Element -superclass {::xo::ui::Widget}

::xo::ui::Form.Element instproc render {visitor} {
    dom createNodeCmd -returnNodeCmd elementNode div
    set outerNode [div -class "x-form-item"]
    div -class x-form-clear-left
    return $outerNode
}



Class ::xo::ui::Form.Section -superclass {::xo::ui::Form.Element}

::xo::ui::Form.Section instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureNodeCmd elementNode fieldset legend div

    # x-form-label-top
    set node [fieldset { 
	legend { t [my label] }
	div -class "x-form-clear"
    }]

    return $node
}

::xo::ui::Class ::xo::ui::Form.Field -superclass {::xo::ui::Form.Element ::xo::ui::Form.Component} -parameter {
    {name ""}
    {field_value ""}
    {markInvalid ""}
    {value ""}
} -configOptions {
    {allowBlank "false"}
    {width 200}
    {columnWidth ""}
    {hideLabel ""}
    {labelStyle ""}
    {fieldLabel ""}
    {disabled ""}
}

::xo::ui::Form.Field instproc setValueTo {value} {
    my set value $value
}

# preventMark
::xo::ui::Form.Field instproc isValid {} {
    set value [my getRawValue]
    return [expr { [my allowBlank] || ${value} ne {} }]
    #return "r([my name])=v($value),len([string length $value])"
}

# Returns the raw data value which may or may not be a valid, defined value. To return a normalized value see getValue.
::xo::ui::Form.Field instproc getRawValue {} {
    return [::xo::kit::queryget [my name]]
}

# Returns the normalized data value (undefined or emptyText will be returned as ''). To return the raw value see getRawValue.
::xo::ui::Form.Field instproc getValue {} {
    return [my __getValue]
}
::xo::ui::Form.Field instproc __getValue {} {
    return [dict create [my name] [my getRawValue]]
}

::xo::ui::Form.Field instproc getConstructor {} {
    set result [next]
    my instvar markInvalid domNodeId
    if { $markInvalid ne {} } {
	ns_log notice Invalid=[my name]
	append result ";${domNodeId}.markInvalid([::util::jsquotevalue ${markInvalid}]);"
    }
    return $result
}



#Y-m-d H:i:s
::xo::ui::Class ::xo::ui::DateTimeField -superclass {::xo::ui::Form.Field} -parameter {
    {value ""}
} -configOptions {
    {allowBlank "false"}
    {dateFormat "'Y-m-d'"}
    {timeFormat "'H:i'"}
    {msgTarget ""}
    {width ""}
    {dateConfig ""}
    {timeConfig ""}
    {timePosition ""}
    {columnWidth ""}
    {disabled ""}
    {emptyToNow ""}
    {otherToNow ""}
} -jsClass Ext.ux.form.DateTime

::xo::ui::DateTimeField instproc getConstructor {} {
    set result [next]
    my instvar markInvalid domNodeId
    if { $markInvalid ne {} } {
	append result ";${domNodeId}.df.markInvalid([::util::jsquotevalue ${markInvalid}]);"
	### append result ";${domNodeId}.tf.markInvalid([::util::jsquotevalue ${markInvalid}]);"
    }
    return $result
}

::xo::ui::DateTimeField instproc getConfig {} {

    my instvar domNodeId name label

    my set dateConfig [::json::encode(M) [my set dateConfig]]
    my set timeConfig [::json::encode(M) [my set timeConfig]]


    set varList [my getConfigOptions]

    set config ""
    lappend config "applyTo:'$domNodeId'"
    lappend config "name:'$name'"
    lappend config "fieldLabel:'$label'"
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config {,}]\}

}


::xo::ui::DateTimeField instproc render {visitor} {
 
    my instvar domNodeId hideLabel

    $visitor ensureNodeCmd elementNode input img
    $visitor ensureLoaded XO.Form.Date

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true

    [next] appendFromScript {
	if { $hideLabel ne {true} } {
	    label -for $domNodeId { t [my label] }
	}
	div -class x-form-element {
	    set node [input -type "text" -id $domNodeId -class "x-form-text x-form-field" -size 20 -autocomplete off -name [my name] -value [my value]]
	}
    }
    $visitor inlineJavascript [subst {
	Ext.onReady(function(){Ext.get('${domNodeId}').setDisplayed(false);});
    }]
    return $node  
}


::xo::ui::Class ::xo::ui::TriggerField -superclass {::xo::ui::Form.Field} -parameter {
    {applyToObject ""}
    {onTriggerClick ""}
    {triggerClass ""}
    {allowBlank ""}
} -jsClass Ext.form.TriggerField

::xo::ui::TriggerField instproc getConfig {} {

    my instvar domNodeId applyToObject

    set varList {
	onTriggerClick
	triggerClass
	allowBlank
	disabled
    }

    set config ""
    lappend config "applyTo:[::util::coalesce ${applyToObject}.getEl() '$domNodeId']"
    #lappend config "applyTo:'$domNodeId'"
    #lappend config "el:'$domNodeId'"
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config {,}]\}

}


::xo::ui::TriggerField instproc render {visitor} {
 
    my instvar domNodeId

    $visitor ensureNodeCmd elementNode div
    $visitor ensureLoaded XO.Form.TriggerField

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true

    set node [next]
    $node appendFromScript {
	input -type hidden -id $domNodeId
    }
    return $node  
}


::xo::ui::Class ::xo::ui::DateField -superclass {::xo::ui::Form.Field} -parameter {
    {allowBlank ""}
    {format "'Y-m-d'"}
    {msgTarget ""}
    {width ""}
} -jsClass Ext.form.DateField

::xo::ui::DateField instproc getConfig {} {

    my instvar domNodeId

    set varList {
	allowBlank
	format
	msgTarget
	width
	columnWidth
	disabled
    }

    set config ""
    lappend config "applyTo:'$domNodeId'"
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config {,}]\}

}


::xo::ui::DateField instproc render {visitor} {
 
    my instvar domNodeId

    $visitor ensureNodeCmd elementNode input img
    $visitor ensureLoaded XO.Form.Date

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true

    [next] appendFromScript {
	label -class x-form-item-label -for $domNodeId { t [my label] }
	div -class x-form-element {
	    set node [input -type "text" -id $domNodeId -class "x-form-text x-form-field" -size 20 -autocomplete off -name [my name]]
	}
    }
    return $node  
}


#Y-m-d H:i:s
::xo::ui::Class ::xo::ui::TimeField -superclass {::xo::ui::Form.Field} -parameter {
    {allowBlank ""}
    {format ""}
    {msgTarget ""}
    {width ""}
    {increment ""}
    {invalidText ""}
    {maxText ""}
    {maxValue ""}
    {minText ""}
    {minValue ""}
} -jsClass Ext.form.TimeField

::xo::ui::TimeField instproc getConfig {} {

    my instvar domNodeId

    set varList {
	allowBlank
	format
	msgTarget
	width
	increment
	invalidText
	minText
	minValue
	maxText
	maxValue
	columnWidth
	disabled
    }

    set config ""
    lappend config "applyTo:'$domNodeId'"
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config {,}]\}

}


::xo::ui::TimeField instproc render {visitor} {
 
    my instvar domNodeId

    $visitor ensureNodeCmd elementNode input img

    $visitor ensureLoaded XO.Form
    $visitor ensureLoaded XO.Form.Date 
    $visitor ensureLoaded XO.DataView

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true

    [next] appendFromScript {
	label -class x-form-item-label -for $domNodeId { t [my label] }
	div -class x-form-element {
	    set node [input -type "text" -id $domNodeId -class "x-form-text x-form-field" -size 20 -autocomplete off -name [my name]]
	}
    }
    return $node  
}





::xo::ui::Class ::xo::ui::ItemSelector -superclass {::xo::ui::Form.Field} -parameter {
    {fieldLabel ""}
    {dataFields ""}
    {fromData ""}
    {toData ""}
    {msWidth ""}
    {msHeight ""}
    {valueField ""}
    {displayField ""}
    {imagePath "'http://www.phigita.net/lib/xo-1.0.0/resources/images/multiselect/'"}
    {switchToFrom ""}
    {toLegend ""}
    {fromLegend ""}
} -jsClass Ext.ux.ItemSelector

::xo::ui::ItemSelector instproc getConfig {} {

    my instvar domNodeId name

    set varList {
	fieldLabel
	dataFields
	fromData
	toData
	msWidth
	msHeight
	valueField
	displayField
	imagePath
	switchToFrom
	toLegend
	fromLegend
	disabled
    }

    set config ""
    lappend config "name:'$name'"
    lappend config "applyTo:'$domNodeId'"
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config {,}]\}

}


::xo::ui::ItemSelector instproc render {visitor} {

    my instvar domNodeId

    $visitor ensureNodeCmd elementNode input img

    $visitor ensureLoaded XO.Multiselect

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true

    [next] appendFromScript {
	label -for [my domNodeId] -class "x-form-item-label" { t [my label] }
	div -class x-form-element {
	    set node [div -id $domNodeId]
	}
    }
    return $node
}







::xo::ui::Class ::xo::ui::Input -superclass {::xo::ui::Form.Field} -parameter {
    {field_control_type ""}
    {field_data_type ""}
    {value ""}
    {name ""}
    {msgTarget "'side'"}
    {vtype ""}
    {anchor ""}
} -instmixin ::xo::ui::ControlTrait


::xo::ui::Input instproc getConfig {} {

    my instvar domNodeId name

    set varList {
	msgTarget
	vtype
	allowBlank
	width
	labelStyle
	disabled
	anchor
    }

    set config ""
    lappend config "applyTo:'$domNodeId'"
    lappend config "name:'$name'"
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config {,}]\}

}


::xo::ui::Input instproc render {visitor} {
 
    my instvar domNodeId

    $visitor ensureNodeCmd elementNode div label input img
    $visitor ensureLoaded XO.Form.Date

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true

    [next] appendFromScript {
	label -class x-form-item-label -for $domNodeId { t [my label] }
	div -class x-form-element {
	    set node [input -type [my field_control_type] -id $domNodeId -class "x-form-text x-form-field" -size 20 -autocomplete off -name [my name] -value [my value]]
	}
    }
    return $node  
}


::xo::ui::Class ::xo::ui::TextField -superclass { ::xo::ui::Input} -parameter {
    {field_control_type "text"}
} -jsClass Ext.form.TextField

Class ::xo::ui::Password -superclass { ::xo::ui::Input}  -parameter {
    {field_control_type "password"}
}


::xo::ui::Class ::xo::ui::HiddenField -superclass {::xo::ui::Input} -parameter {
    {field_control_type "hidden"}
} -jsClass Ext.form.Hidden



::xo::ui::Class ::xo::ui::FileField -superclass {::xo::ui::Form.Field} -configOptions {
    {inputType "'file'"}
    {msgTarget "'side'"}
    {vtype ""}
    {allowBlank "false"}
    {labelStyle ""}
    {buttonText ""}
    {buttonOnly ""}
    {buttonOffset ""}
    {anchor "'90%'"}

} -jsClass Ext.form.TextField

::xo::ui::FileField instproc getConfig {} {
    my instvar domNodeId

    set varList [my getConfigOptions]

    set config ""
    lappend config "applyTo:'$domNodeId'"
    #lappend config "renderTo:'fi-basic'"
    foreach varName $varList {
        if { [my set $varName] ne {} } {
            lappend config "${varName}:[my set $varName]"
        }
    }

    return \{[join $config {,}]\}

}


::xo::ui::FileField instproc render {visitor} {
    my instvar domNodeId name
    $visitor ensureNodeCmd elementNode label input div

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true

    [next] appendFromScript {
	label -for [my domNodeId] { t "[my label]" }
	div -class x-form-element {
	    set node [input -type "file" -class "x-form-file" -name $name -id $domNodeId -value ""]
	}
    }
    return $node
}



::xo::ui::FileField instproc init {args} {

    return [next]
}

::xo::ui::FileField instproc identify {tmpfile filename} {
    return [__FILE_MANAGER__ identify $tmpfile $filename]
}

::xo::ui::FileField instproc magic {} {
    set tmpfile [ns_queryget [my name].tmpfile]
    set filename [::xo::kit::queryget [my name]]
    return [my identify $tmpfile $filename]
}


::xo::ui::FileField instproc filetype {} {
    return [::xo::media::content_type [lindex [my magic] 0]]
}

::xo::ui::FileField instproc getValue {} {

    my mixin add {::xo::ui::FileField=PDF -guard {[lindex [my magic] 0] eq {PDF}}}
    my mixin add {::xo::ui::FileField=MP3 -guard {[lindex [my magic] 0] eq {MP3}}}

    my mixin add {::xo::ui::FileField=Video -guard {[my filetype] eq {video}}}
    my mixin add {::xo::ui::FileField=Audio -guard {[my filetype] eq {audio}}}

    if { [my is_image_p] } {
	my mixin add ::xo::ui::FileField=Image
	if {[my is_photo_p]} {
	    my mixin add ::xo::ui::FileField=Photo
	}
    }

    return [my __getValue]

}

::xo::ui::FileField instproc __getValue {} {

    set tmpfile [ns_queryget [my name].tmpfile]
    #set filename [ns_queryget [my name]]

    package require md5
    set md5sum [string tolower [::md5::md5 -hex -file $tmpfile]]

###  The following does not work so we are using the tcllib md5 package
#    set fp [open $tmpfile]
#    fconfigure $fp -encoding binary
#    set md5sum [ns_md5 [read $fp]]
#    close $fp

    #set dict [encoding convertfrom utf-8 [next]]
    set dict [next]
    set original_filename [dict get $dict [my name]]
    set filename [lindex [split $original_filename "\\\/"] end]
    dict set dict [my name] $filename

    set list [list "XO.File.Name \{${original_filename}\}" "XO.File.Type [my filetype]" "XO.File.Size [file size $tmpfile]" "XO.File.Magic [lindex [my magic] 0]" "XO.File.MD5 $md5sum"]
    set extension [file extension $filename]
    if { $extension ne {} } {
	lappend list "XO.File.Extension $extension"
    }
    return [dict merge $dict [dict create [my name].extra $list]]
}

::xo::ui::FileField instproc isValid {} {
    set tmpfile [ns_queryget [my name].tmpfile]
    #check if filename is not blank
    return [expr { [next] }]
}


::xo::ui::FileField instproc is_image_p {} {
    return [expr {[my filetype] eq {image}}]
}

Class ::xo::ui::FileField=ANTIVIRUS_PROTECTION
::xo::ui::FileField=ANTIVIRUS_PROTECTION instproc isValid {} {
    set tmpfile [ns_queryget [my name].tmpfile]
    return [expr { [ns_clamav scanfile $tmpfile] eq {} }]
}

Class ::xo::ui::FileField=MAGIC_PROTECTION


::xo::ui::FileField=MAGIC_PROTECTION instproc isValid {} {
#    set magic_list {JPEG PNG GIF BMP TIFF DOC PDF PS XLS PPT MDB WAV MP3 MOV AVI MPEG FLV}
    set magic_list {JPEG PNG GIF BMP TIFF PS PDF DOC DOCX MP3 MP2 MOV WMV XLS XLSX PPT PPTX MDB SXC SXD SXI SXW ODC ODG ODI ODW ODB ODT DJVU}

    set magic [my magic]
    set result 0
    foreach format_name $magic_list {
	set result [expr { $result || (-1 != [lsearch -exact $magic $format_name]) }]
    }
    if { 0 == $result } { ns_log notice "magic=$magic"  }
    return $result
}



Class ::xo::ui::FileField=PDF -superclass {::xo::ui::FileField} -instmixin ::xo::ui::ControlTrait

::xo::ui::FileField=PDF instproc getPDFInfo {} {
    set filename [ns_queryget [my name].tmpfile]
    set data [exec -- /bin/sh -c "/opt/poppler/bin/pdfinfo $filename || exit 0" 2> /dev/null]    
    set result ""
    foreach line [split $data \n] {
	set index [string first ":" $line]
	set key [string range $line 0 [expr { -1+$index }]]
	set value [string range $line [expr { 1+$index }] end]
	lappend result [list PDF.Info.[string map {" " _} [string tolower [string trim $key]]] [string trim $value]]
    }
    return $result
}

::xo::ui::FileField=PDF instproc __getValue {} {
    set data [my getPDFInfo]
    set mydict [next]
    foreach item $data {
	dict lappend mydict [my name].extra $item
    }
    return $mydict
}



Class ::xo::ui::FileField=MP3 -superclass {::xo::ui::FileField} -instmixin ::xo::ui::ControlTrait

::xo::ui::FileField=MP3 instproc getMP3Info {} {
    set filename [ns_queryget [my name].tmpfile]

    set data [exec -- /bin/sh -c "/usr/bin/mp3info -p 'Title:%t\nArtist:%a\nAlbum:%l\nTrack:%n\nGenre:%g\nYear:%y\nDuration:%S\nComment:%c\nGood_Frames:%u\nCorrupt_Frames:%b\nSampling_Frequency:%Q\n' $filename 2>&1 || exit 0" 2> /dev/null]    

    if { [string match "*does not have an ID3 1.x tag*" $data] } {
	ns_log notice "getMP3INFO: $data"
	return [list]
    } else {
	foreach line [split $data \n] {
	    lassign [split $line :] key value
	    lappend result [list MP3.Info.${key} [string trim ${value}]]
	} 
	return $result
    }
}

::xo::ui::FileField=MP3 instproc __getValue {} {
    set data [my getMP3Info]
    set mydict [next]
    foreach item $data {
	dict lappend mydict [my name].extra $item
    }
    return $mydict
}


Class ::xo::ui::FileField=Video -superclass {::xo::ui::FileField} -instmixin ::xo::ui::ControlTrait

::xo::ui::FileField=Video instproc getVideoInfo {} {
    set filename [ns_queryget [my name].tmpfile]
    set data [exec -- /bin/sh -c "/usr/bin/ffmpeg -i $filename 2>&1 || exit 0" 2> /dev/null]    

    regexp -- {Duration: +([0-9:.]+)[ ,]} $data _ duration

    set result ""
    lappend result [list XO.Info.duration $duration]
    return $result
}

::xo::ui::FileField=Video instproc __getValue {} {
    set data [my getVideoInfo]
    set mydict [next]
    foreach item $data {
	dict lappend mydict [my name].extra $item
    }
    return $mydict
}




Class ::xo::ui::FileField=Audio -superclass {::xo::ui::FileField} -instmixin ::xo::ui::ControlTrait

::xo::ui::FileField=Audio instproc getAudioInfo {} {
    set filename [ns_queryget [my name].tmpfile]

    set data [exec -- /bin/sh -c "/usr/bin/ffmpeg -i $filename 2>&1 || exit 0" 2> /dev/null]    
    regexp -- {Duration: +([0-9:.]+)[ ,]} $data _ duration

    set result ""
    lappend result [list XO.Info.duration $duration]
    return $result
}

::xo::ui::FileField=Audio instproc __getValue {} {
    set data [my getAudioInfo]
    set mydict [next]
    foreach item $data {
	dict lappend mydict [my name].extra $item
    }
    return $mydict
}



Class ::xo::ui::FileField=Image -superclass {::xo::ui::FileField} -instmixin ::xo::ui::ControlTrait

::xo::ui::FileField=Image instproc init {args} {
    #my mixin add {::xo::ui::FileField=Photo -guard {[my is_photo_p]}}
    return [next]
}

::xo::ui::FileField=Image instproc isValid {} {


    lassign [my getImageData] width_item height_item
    lassign $width_item dummy1 width
    lassign $height_item dummy2 height

    return [expr { [next] && [string is integer -strict $width] && [string is integer -strict $height] }]
}

::xo::ui::FileField=Image instproc __getValue {} {
    set data [my getImageData]
    set mydict [next]
    foreach item $data {
	dict lappend mydict [my name].extra $item
    }
    return $mydict
}

::xo::ui::FileField=Image instproc getImageData {} {
    set filename [ns_queryget [my name].tmpfile]
    set data [exec -- /bin/sh -c "/usr/bin/identify -format 'XO.Image.Width %w XO.Image.Height %h' $filename || exit 0" 2> /dev/null]
    set result ""
    foreach {key value} $data {
	lappend result [list $key $value]
    }
    return $result
}

::xo::ui::FileField=Image instproc is_photo_p {} {
    return [expr { [my getExifData] ne {} }]
}

::xo::ui::FileField=Image instproc getExifData {} {
    set filename [ns_queryget [my name].tmpfile]
    
    set data [exec -- /bin/sh -c "/usr/bin/exiv2 -u -b -Pklycvt $filename || exit 0" 2> /dev/null]
    set result ""
    set data [string map {"\n\x00" "\x00"} $data] ;# needed for removing the newline between the value and the translated value
    foreach item [split $data "\n"] {
	regsub -all {\s{2,}} $item {|} item
	lassign [split $item {|}] key label type count value translated_value

#	set key [lindex $item 0]
#	set value  [lrange $item 1 end]

	set index [string first \x00 $value]
	if { $index >= 0 } {
	    set value [string range $value 0 [expr { $index - 1}]]
	}

	set index [string first \x00 $translated_value]
	if { $index >= 0 } {
	    set translated_value [string range $translated_value 0 [expr { $index - 1}]]
	}
	if {$key eq {Exif.Photo.UserComment} } {
	    #continue
	    # test with dsc_0975.jpg which is id ~206
	}
	lappend result [list $key $label [string tolower $type] $count $value $translated_value]

    }
    return $result
}



Class ::xo::ui::FileField=Photo -superclass {::xo::ui::FileField=Image} -instmixin ::xo::ui::ControlTrait -parameter {
    {allowableFormatList "JPEG"}
}

::xo::ui::FileField=Photo instproc __getValue {} {
    set filename [ns_queryget [my name].tmpfile]
    set mydict [next]
    foreach item [my getExifData] {
	lassign $item key label type count value translated_value
	dict lappend mydict [my name].extra [list $key $value]
	dict lappend mydict [my name].translation [list $key label $label]
	if { $count == 1 && $type eq {short} && $value ne [string trim $translated_value {()}] } {
	    dict lappend mydict [my name].translation [list $key $value $translated_value]
	}
    }
#    set mydict [dict merge $mydict [dict create exif [my getExifData]]]
    return $mydict
}















set COMMENT {
    ::xo::ui::FileField instmixin {::xo::ui::FileField=PDF -guard {[lindex [my magic] 0] eq {PDF}}}
    ::xo::ui::FileField instmixin {::xo::ui::FileField=MP3 -guard {[lindex [my magic] 0] eq {MP3}}}

    ::xo::ui::FileField instmixin {::xo::ui::FileField=Video -guard {[lindex [my magic] 0] eq {MOV}}}
    ::xo::ui::FileField instmixin {::xo::ui::FileField=Audio -guard {[lindex [my magic] 0] eq {MP3}}}

    ::xo::ui::FileField instmixin {::xo::ui::FileField=Image -guard {[my is_image_p]}}
    ::xo::ui::FileField=Image instmixin {::xo::ui::FileField=Photo -guard {[my is_photo_p]}}
    ::xo::ui::FileField=Image instmixin ::xo::ui::FileField=Photo
}


::xo::ui::FileField instmixin ::xo::ui::FileField=ANTIVIRUS_PROTECTION
::xo::ui::FileField instmixin ::xo::ui::FileField=MAGIC_PROTECTION



Class ::xo::ui::MultiFile -superclass { ::xo::ui::Widget} -instmixin ::xo::ui::ControlTrait -parameter {
    {maxfiles "3"}
    {style "margin:2px;border:1px solid black;padding:5px;font-size:x-small;"}
} -instmixin ::xo::ui::ControlTrait

::xo::ui::MultiFile instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureLoaded MISC.widget.MultiFile
    $visitor ensureNodeCmd elementNode input
    $visitor ensureNodeCmd elementNode label
    $visitor ensureNodeCmd elementNode div


    label -for [my domNodeId] { t "[my label]" }
    div -class x-form-element {
	div -class x-form-check-wrap {
	    set node [input -type "file" -name [my domNodeId] -id [my domNodeId] -value ""]
		div -id "files_list_[my domNodeId]" -style [my style] { t "Files (maximum [my maxfiles]):" }
	}
    }

    $visitor inlineJavascript [subst -nobackslashes {
	var [my domNodeId] = function(){
	    var multi_selector;
	    return {
		init : function() {
		    multi_selector = new MultiSelector( document.getElementById('files_list_[my domNodeId]'), [my maxfiles]);
		    multi_selector.addElement(document.getElementById('[my domNodeId]'));
		}
	    }
	}();
    }]
    $visitor onReady [my domNodeId].init [my domNodeId] true
    return $node
}




Class ::xo::ui::Option -superclass {::xo::ui::Form.Element} -parameter {
    {value ""}
    {checked_p "false"}
    {disabled ""}
}

::xo::ui::Option instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureNodeCmd elementNode div
    return [next]
}


Class ::xo::ui::ImageChooser -superclass {::xo::ui::Form.Element}
::xo::ui::ImageChooser instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureLoaded XO.ImageChooser
}






::xo::ui::Class ::xo::ui::FieldSet -superclass {::xo::ui::Form.Field} -parameter {
    {checkboxToggle "false"}
    {title ""}
    {autoHeight ""}
    {collapsible ""}
    {collapsed ""}
    {name ""}
    {checkboxName ""}
    {defaultType ""}
    {layout ""}
    {layoutConfig ""}
    {columnWidth ""}
    {defaults ""}
    {baseCls ""}
    {border ""}
    {labelWidth ""}
    {maskDisabled ""}
    {labelAlign ""}
    {anchor ""}
} -jsClass Ext.form.FieldSet

::xo::ui::FieldSet instproc setValueTo {value} {

    my instvar checkboxToggle
    if { $checkboxToggle } {
	my set collapsed [expr { [::util::boolean [my value]] ? false : true }]
    }
}

::xo::ui::FieldSet instproc getRawValue {} {
    return [::util::coalesce [next] f]
}

::xo::ui::FieldSet instproc isValid {} {
    set value [my getRawValue]
    return [expr { [my checkboxToggle] ne {true} || ${value} ne {} }]
}


::xo::ui::FieldSet instproc getConfig {} {

    my instvar domNodeId

    if { [my checkboxName] ne {} && [my value] ne {} } {
	### ns_log notice "[my checkboxName]=[my value]"
	my set collapsed [expr { [my value] eq {on} ? false : true }]
    }

    set varList {
	checkboxToggle
	title
	autoHeight
	collapsible
	collapsed
	checkboxName
	defaultType
	layout
	layoutConfig
	columnWidth
	defaults
	baseCls
	border
	labelWidth
	maskDisabled
	labelAlign 
	anchor
	style
	disabled
    }

    set config ""
    lappend config "applyTo:'$domNodeId'"
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    set items ""
    foreach o [my childNodes] {	
	set cl [$o info class]
	if { [$cl info class] eq {::xo::ui::Class} } { lappend items [$o domNodeId] }
    }
    if { $items ne {} } { 
	lappend config "items: \[[join ${items} {,}]\]"
    }
    
    return \{[join $config {,}]\}

}

::xo::ui::FieldSet instproc accept {{-rel default} {-action "visit"} visitor} {

    set result [next]

    my instvar domNodeId


    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true

    return $result
}

::xo::ui::FieldSet instproc render {visitor} {

    my instvar domNodeId checkboxToggle

    $visitor ensureLoaded XO.Form


    $visitor ensureNodeCmd elementNode fieldset legend div input span

    ### $visitor inlineJavascript [my getJS]
    ### $visitor onReady _${domNodeId}.init ${domNodeId} true

    # x-form-label-top
    set node [fieldset -id $domNodeId -class "x-fieldset" { 
	legend -class "x-fieldset-header" { 
	    if { $checkboxToggle } {
		input -id check_$domNodeId -type checkbox -name [my name]
	    }
	    span -class "x-fieldset-header-text" {
		t [string trim [my title]  \']
	    }
	}
	div -class "x-fieldset-bwrap" {
	    set innerNode [div -class "x-fieldset-body"]
	}
    }]
    return $innerNode
}








### Select Lists

::xo::ui::Class ::xo::ui::ComboBox -superclass { ::xo::ui::Form.Field} -parameter {
    {name ""}
    {value ""}
    {hidden_field_p "false"}
} -configOptions {
    {anchor ""}
    {mode ""}
    {selectOnFocus ""}
    {editable ""}
    {forceSelection ""}
    {typeAhead ""}
    {triggerAction ""}
    {transform ""}
    {emptyText ""}
    {width ""}
    {msgTarget ""}
    {forceSelection ""}
    {store ""}
    {valueField ""}
    {displayField ""}
    {loadingText ""}
    {pageSize ""}
    {hideTrigger ""}
    {tpl ""}
    {applyTo ""}
    {itemSelector ""}
    {onSelect ""}
    {queryDelay ""}
    {queryParam ""}
    {allowBlank ""}
    {helpText ""}
    {minChars ""}
    {style ""}
    {readOnly ""}
} -jsClass Ext.form.ComboBox



::xo::ui::ComboBox instproc getConstructor {} {
    my instvar domNodeId name
    set result [next]
    if { [my hidden_field_p] } {
	append result ";${domNodeId}_Obj=Ext.get('${domNodeId}_${name}'); if (${domNodeId}_Obj) ${domNodeId}_Obj.remove();"
    }
    return $result
    
}


::xo::ui::ComboBox instproc getHiddenValue {} {
    return [::xo::kit::queryget hidden_[my name]]
}
::xo::ui::ComboBox instproc __getValue {} {
    set dict [next]
    if { [my hidden_field_p] } {
	set dict [dict merge $dict [dict create hidden_[my name] [my getHiddenValue]]]
    }
    return $dict
}

::xo::ui::ComboBox instproc isValid {} {
    set value [my getRawValue]
    set hidden_value ""
    if { [my hidden_field_p] } {
	set hidden_value [my getHiddenValue]
    }
    return [expr { [my allowBlank] || ${value} ne {} || ${hidden_value} ne {} }]
}


::xo::ui::ComboBox instproc getConfig {} {

    my instvar domNodeId name

    set varList [my getConfigOptions]

    set config ""
    lappend config "applyTo:'$domNodeId'"
    if { [my hidden_field_p] } {
	lappend config "hiddenName:'hidden_${name}'"
	lappend config "hiddenId:'${domNodeId}_${name}'"
    }
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }


    return \{[join $config {,}]\}

}
::xo::ui::ComboBox instproc getPatches {} {
    # HERE: Get the version from a Mgr
    set extVersion 2.2
    set patch ""
    if { ${extVersion} eq {2.2} } {
	# http://extjs.com/forum/showthread.php?p=204817
	set patch {
	    Ext.form.TriggerField.override({
		afterRender : function(){
		    Ext.form.TriggerField.superclass.afterRender.call(this);
		    var y;
		    if(Ext.isIE && !this.hideTrigger && this.el.getY() != (y = this.trigger.getY())){
			this.el.position();
			this.el.setY(y);
		    }
		}
	    });
	}
    }
    return [concat [next] ${patch}]
}

::xo::ui::ComboBox instproc render {visitor} {

    $visitor ensureLoaded XO.Form.ComboBox
    my instvar domNodeId name helpText value
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true
    
    [next] appendFromScript {
        label -for ${domNodeId} { t [my label] }
        div -class x-form-element {
	    div -class x-form-field-wrap {
		if { [my hidden_field_p] } {
		    # HERE: FIX ME
		    set hidden_node [input -id ${domNodeId}_${name} -type hidden -name hidden_${name}]
		}
		set node [input -type text -id ${domNodeId} -name $name]
		if { $value ne {} } {
		    if { [my hidden_field_p] } {
			# HERE: FIX ME
			#ns_log notice [my name]=$value
			$hidden_node setAttribute value $value
		    } else {
			$node setAttribute value $value
		    }
		}
	    }
	    if { $helpText ne {} } {
		div -style "padding-top:2px;padding-bottom:4px;font-size:12px;" {
		    t $helpText
		}
	    }
        }
    }

    return $node
}




::xo::ui::Class ::xo::ui::RadioGroup -superclass {::xo::ui::Form.Field} -parameter {
    {name ""}
    {style ""}
    {columns ""}
    {vertical ""}
} -jsClass Ext.form.Label


::xo::ui::RadioGroup instproc getConfig {} {

    my instvar domNodeId value

    set varList {
	allowBlank
	columns
	vertical
    }

    set config ""
    lappend config "id:'$domNodeId'"
    lappend config "applyTo:'$domNodeId'"
    if { $value ne {} } {
	lappend config "value:'$value'"
    }
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }
    set items ""
    foreach o [my findChildren CLASS_EQ ::xo::ui::Radio] {	
	lappend items [$o domNodeId]
    }
    if { $items ne {} } { 
	lappend config "items: \[[join ${items} {,}]\]"
    }
    return \{[join $config {,}]\}

}


::xo::ui::RadioGroup instproc render {visitor} {
    my instvar domNodeId label value

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true


    $visitor ensureNodeCmd elementNode div label
    [next] appendFromScript {
	label -class x-form-item-label { t $label }
	set innerNode [div -id $domNodeId -class x-form-element]
    }

    my setOptionByValue $value

    return $innerNode
}

::xo::ui::RadioGroup instproc setValueTo {value} {
    my set value $value
}

::xo::ui::RadioGroup instproc setOptionByValue {value} {
    foreach o [my findChildren CLASS_EQ ::xo::ui::Radio] {
	if { [$o set value] eq ${value} } {
	    $o set checked true
	    ###$o set value true
	}
    }
}

::xo::ui::Class ::xo::ui::Radio -superclass {::xo::ui::Form.Field} -parameter {
    {handler ""}
    {msgTarget ""}
    {vtype ""}
    {width ""}
    {labelStyle ""}
    {boxLabel ""}
    {inputValue ""}
    {checked ""}
    {cls ""}
    {ctCls ""}
    {inputType "'radio'"}
    {allowBlank "true"}
    {hideLabel ""}
} -jsClass Ext.form.Radio


::xo::ui::Radio instproc getConfig {} {

    my instvar domNodeId value
    #[my parentNode] instvar name
    [my findParent CLASS_EQ ::xo::ui::RadioGroup] instvar name

    set varList {
	handler
	msgTarget
	vtype
	width
	labelStyle
	checked
	cls
	ctCls
	disabled
	inputType
	hideLabel
    }

    set config ""
    lappend config "id:'$domNodeId'"
    lappend config "applyTo:'$domNodeId'"
    lappend config "name:'$name'"
    lappend config "inputValue:[::util::jsquotevalue [my value]]"
    if { [my label] ne {} } {
	lappend config "boxLabel:[::util::jsquotevalue [my label]]"
    }
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }
    ###lappend config [subst -nocommands {	onClick:function(){ ${domNodeId}.setValue(true);alert(this.el.dom.name);alert(${domNodeId}.getGroupValue());${domNodeId}.setValue('${value}');}    }]
    return \{[join $config {,}]\}

}

::xo::ui::Radio instproc getConstructor {} {
    my instvar domNodeId
    return "[next];${domNodeId}_labelObj=Ext.get('${domNodeId}_label'); if (${domNodeId}_labelObj) ${domNodeId}_labelObj.remove();"
}

::xo::ui::Radio instproc render {visitor} {
    my instvar domNodeId value checked
    #[my parentNode] instvar name
    [my findParent CLASS_EQ ::xo::ui::RadioGroup] instvar name

    $visitor ensureNodeCmd elementNode input label div

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true
    ####$visitor inlineJavascript [subst -nocommands {Ext.ComponentMgr.register('${domNodeId}');}]
    
    set outerNode [div -id _$domNodeId {
	set innerNode [input -id $domNodeId -name $name -type radio -class "x-form-radio x-form-field" -autocomplete off -value $value]
	if { [my checked] eq {true} } {
	    $innerNode setAttribute checked ""
	}
	set labelNode [label -for $domNodeId -class "x-form-cb-label" -id "${domNodeId}_label" { t [my label] }]
	#t -disableOutputEscaping " &nbsp; "
    }]
    return $outerNode
}



::xo::ui::Class ::xo::ui::CheckboxGroup -superclass {::xo::ui::Form.Field} -parameter {
    {allowBlank "true"}
    {name ""}
    {style ""}
    {value ""}
} -jsClass Ext.form.CheckboxGroup

::xo::ui::CheckboxGroup instproc getConfig {} {

    my instvar domNodeId name
    ###[my parentNode] instvar name

    set varList {
    }

    set config ""
    lappend config "id:'$domNodeId'"
    lappend config "applyTo:'$domNodeId'"
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }
    set items ""
    foreach o [my findChildren CLASS_EQ ::xo::ui::Checkbox] {	
	set cl [$o info class]
	if { [$cl info class] eq {::xo::ui::Class} } { lappend items [$o domNodeId] }
    }
    if { $items ne {} } { 
	lappend config "items: \[[join ${items} {,}]\]"
    }
    return \{[join $config {,}]\}

}


::xo::ui::CheckboxGroup instproc render {visitor} {
    my instvar domNodeId label value

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true


    $visitor ensureNodeCmd elementNode div label
    [next] appendFromScript {
	label { t $label }
	set innerNode [div -id $domNodeId]
    }
    my setOptionByValue $value
    return $innerNode
}

::xo::ui::CheckboxGroup instproc setValueTo {value} {
    my set value $value
}

::xo::ui::CheckboxGroup instproc setOptionByValue {value} {
    foreach o [my findChildren CLASS_EQ ::xo::ui::Checkbox] {
	if { [$o set value] eq ${value} } {
	    $o set checked true
	    ###$o set value true
	}
    }
}


::xo::ui::Class ::xo::ui::Checkbox -superclass { ::xo::ui::Form.Field } -parameter {
    {hideLabel ""}
    {msgTarget ""}
    {width ""}
    {labelStyle ""}
    {checked ""}
    {cls ""}
    {ctCls ""}
    {disabled ""}
    {allowBlank true}
} -jsClass Ext.form.Checkbox



::xo::ui::Checkbox instproc getConfig {} {

    my instvar domNodeId name

    set varList {
	hideLabel
	msgTarget
	width
	labelStyle
	checked
	cls
	ctCls
	disabled
	allowBlank
    }

    set config ""
    lappend config "id:'$domNodeId'"
    lappend config "applyTo:'$domNodeId'"
    lappend config "name:'$name'"
    #lappend config "inputValue:[ns_dbquotevalue [my value]]"
    lappend config "boxLabel:[ns_dbquotevalue [my label]]"
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }
    ###lappend config [subst -nocommands {	onClick:function(){}    }]
    return \{[join $config {,}]\}

}

::xo::ui::Checkbox instproc render {visitor} {
    my instvar domNodeId value checked label name

    $visitor ensureNodeCmd elementNode input label div

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true

    
    set outerNode [div -id _$domNodeId -class "x-form-field" {
	set innerNode [input -name $name -class "x-form-checkbox" -type checkbox -id $domNodeId -value $value]
	if { [my checked] eq {true} || [my value] eq {true} } {
	    $innerNode setAttribute checked true
	}
	#label -for $domNodeId -class "x-form-cb-label" { t $label }
	t -disableOutputEscaping " &nbsp; "
    }]
    return $innerNode
}


#####


Class ::xo::ui::CheckList -superclass { ::xo::ui::Form.Field} -instmixin ::xo::ui::ControlTrait -parameter {
    {name ""}
}

::xo::ui::CheckList instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureNodeCmd elementNode label
    $visitor ensureNodeCmd elementNode div

    [next] appendFromScript {
	label -for [my domNodeId] -class l0 { t [my label] }
	set innerNode [div -id [my domNodeId]]
    }
    return $innerNode
}

::xo::ui::CheckList instproc accept {{-rel default} {-action "visit"} visitor} {
    set instmixins [Option info instmixin -guards]
    set o [self]
    Option instmixin [subst -nobackslashes -nocommands {::xo::ui::CheckListOption -guard {[my parentNode] eq {$o} }}]
    set node [next]
    Option instmixin $instmixins
    return $node
}



### List Options

Class ::xo::ui::ComboBoxOption -superclass {::xo::ui::Option}
::xo::ui::ComboBoxOption instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureNodeCmd elementNode option
    [next] appendFromScript {
	set node [option -value [my value] { t [my label] }]
    }
    return $node
}



Class ::xo::ui::CheckListOption -superclass {::xo::ui::Option}

::xo::ui::CheckListOption instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureNodeCmd elementNode label
    $visitor ensureNodeCmd elementNode input
    $visitor ensureNodeCmd elementNode div

    [next] appendFromScript {
	div -class x-form-element {
	    div -class x-form-check-wrap {
		input -name [[my parentNode] name] -class "x-form-checkbox x-form-field" -type checkbox -id "[my domNodeId]" -value [my value]
		label -for [my domNodeId] -class "x-form-cb-label x-form-field" { t " [my label]" }
	    }
	}
    }
}







############################################################################################

Class ::xo::ui::Button -superclass { ::xo::ui::Widget} -instmixin ::xo::ui::ControlTrait

::xo::ui::Button instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureNodeCmd elementNode input
    div -class x-form-element {
	set node [input -type "button" -id "[my domNodeId]" -class x-btn-text { t "[my label]" }]
    }
    return $node
}
Class ::xo::ui::Submit -superclass { ::xo::ui::Widget}  -instmixin ::xo::ui::ControlTrait

::xo::ui::Submit instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureNodeCmd elementNode button
    $visitor ensureNodeCmd elementNode em
    $visitor ensureNodeCmd elementNode table
    $visitor ensureNodeCmd elementNode tbody
    $visitor ensureNodeCmd elementNode tr
    $visitor ensureNodeCmd elementNode td
    $visitor ensureNodeCmd elementNode i

    table -class "x-btn-wrap x-btn" -cellspacing "0" -cellpadding "0" -border "0" -style "width: 75px;" {
	tbody {
	    tr {
		td -class "x-btn-left" {
		    i
		}
		td -class "x-btn-center" {
		    em {
			set node [button -class "x-btn-text x-btn-center" { t [my label] }]
		    }
		}
		td -class "x-btn-right" {
		    i
		}
	    }
	}
    }
    return $node
}


Class ::xo::ui::Form::Item -superclass {::xo::ui::Widget} -parameter {
    {name ""}
}

::xo::ui::Form::Item instproc render {visitor} {
    dom createNodeCmd -returnNodeCmd elementNode div
    div -class x-form-item { set innerNode [next] }
    div -class x-form-clear-left
    return $innerNode
}



Class ::xo::ui::FormColumn -superclass {::xo::ui::Widget}

::xo::ui::FormColumn instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureNodeCmd elementNode div
    set node [div -class "x-form-ct x-form-column" -style "margin-left: 10px;"]
    div -class x-form-clear-left
    return $node
}

