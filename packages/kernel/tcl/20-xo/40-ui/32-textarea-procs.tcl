::xo::ui::Class ::xo::ui::TextArea -superclass { ::xo::ui::Form.Field} -parameter {
    {width ""}
    {height ""}
    {msgTarget ""}
    {allowBlank "false"}
    {blankText ""}
    {maxLength ""}
    {maxLengthText ""}
    {minLength ""}
    {minLengthText ""}
    {grow ""}
    {growMin ""}
    {growMax ""}
    {preventScrollbars ""}
    {vtype ""}
    {fieldLabel ""}
    {hideLabel ""}
    {emptyText ""}
    {value ""}
    {anchor ""}
} -jsClass Ext.form.TextArea -instmixin ::xo::ui::ControlTrait

::xo::ui::TextArea instproc getConfig {} {

    my instvar domNodeId

    set varList {
	hideLabel
	fieldLabel
	width
	height
	msgTarget
	allowBlank
	blankText
	maxLength
	maxLengthText
	minLength
	minLengthText
	grow
	growMin
	growMax
	preventScrollbars
	vtype
	labelStyle
	emptyText
	anchor
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

::xo::ui::TextArea instproc render {visitor} {

    my instvar domNodeId name msgTarget hideLabel label

    $visitor ensureNodeCmd elementNode div textarea label
    $visitor ensureLoaded XO.Form.TextArea




    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true

    [next] appendFromScript {
	if { $hideLabel ne {true} } {
	    label -for $domNodeId { t $label }
	}
	set node [textarea -id $domNodeId -class "x-form-textarea x-form-field" -name $name -autocomplete off { t -disableOutputEscaping [my value] }]
    }
    return $node
}









::xo::ui::Class ::xo::ui::StructuredText -superclass {::xo::ui::Form.Field} -configOptions {
    {height "450"}
    {width "600"}
    {get_images_proxy ""}
    {blank_url ""}
    {pageStyle {'pre {background-color:#DEE7EC;border:1px solid #8CACBB;color:#000000;padding:1em;white-space:pre-wrap;white-space:-moz-pre-wrap;white-space:-pre-wrap;white-space:-o-pre-wrap;word-wrap:break-word;}'}}
} -parameter {
    {value ""}
} -jsClass Ext.ux.HtmlEditor


::xo::ui::StructuredText instproc action(returnBlank) {marshaller} {
    ns_return 200 text/html ""
    return
}

::xo::ui::StructuredText instproc getConfig {} {
    
    my instvar domNodeId

    set varList [my getConfigOptions]

    set config ""
    lappend config "applyTo:'${domNodeId}'"
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config {,}]\}

}


::xo::ui::StructuredText instproc render {visitor} {

    my instvar domNodeId name height get_images_proxy

    $visitor ensureLoaded XO.HtmlEditor

    $visitor ensureNodeCmd elementNode div textarea label br p

    $visitor inlineStyle {
	.htmlarea { background: #fff; margin:2px; }
	    .htmlarea iframe.xinha_iframe, .htmlarea textarea.xinha_textarea {border: 1px dashed blue;margin:2px;padding:2px;font-family:courier;font-size:14px;}
    }



	my instvar blank_url
	set blank_url [::util::jsquotevalue [my uri -select [my domNodeId] -action returnBlank]]

    
	$visitor inlineJavascript [my getJS]
	$visitor onReady _${domNodeId}.init _${domNodeId} true    

    [next] appendFromScript {
        label -for ${domNodeId} { t [my label] }
        div -class x-form-element {
            set node [textarea -id ${domNodeId} -name [my name] -class "xinha_textarea x-form-textarea x-form-field" -style "width:[my width]px;height:[my height]px;" { t -disableOutputEscaping  [my value] }]
        }
    }
    return $node
}





::xo::ui::Class ::xo::ui::CodeArea -superclass { ::xo::ui::Form.Field} -parameter {
    {rows "40"}
    {cols "40"}
    {charwidth "14"}
    {charheight "10"}
    {language ""}
}

::xo::ui::CodeArea instproc action(returnIframe) {marshaller} {
    doc_return 200 text/html [subst -novariables -nobackslashes {
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
	<html>
	<head>
	<link type="text/css" href="/resources/codepress/codepress.css" rel="stylesheet" />
	<link type="text/css" href="/resources/codepress/languages/codepress-[my language].css" rel="stylesheet" id="cp-lang-style" />
	<script type="text/javascript" src="/resources/codepress/codepress.js"></script>
	<script type="text/javascript" src="/resources/codepress/languages/codepress-[my language].js"></script>
	<script type="text/javascript">CodePress.language = '[my language]';</script>
	<script type="text/javascript">
	var [my domNodeId] = function(){
	    var cpWindow;
	    return {
		init : function() {
		    cpWindow = top.document.getElementById('iframe-[my domNodeId]');
		    if(cpWindow!=null) {
			cpWindow.style.border = '1px solid gray';
			cpWindow.style.frameBorder = '0';
		    }

		    top.CodePress = CodePress;
		    CodePress.initialize('new');

		    cpOnload = top.document.getElementById('[my domNodeId]');
		    cpOndemand = top.document.getElementById('cp-[my domNodeId]-ondemand');

		    if(cpOnload!=null) {
			cpOnload.style.display = 'none';
			//cpOnload.id = 'codepress-loaded';
			CodePress.setCode('[my domNodeId]');
		    }
		    if(cpOndemand!=null) cpOndemand.style.display = 'none';
		}
	    }
	}();
	</script>
	</head>
    <body id="ffedt" onload="[my domNodeId].init();"><pre id="ieedt"></pre></body>
	</html>
    }]
}

::xo::ui::CodeArea instproc render {visitor} {
    $visitor ensureLoaded XO.CodePress
    $visitor ensureNodeCmd elementNode textarea label iframe


    set uri [my uri -select [my domNodeId] -action returnIframe]

    label -for [my domNodeId] -class l0 { t [my label] }
    iframe -id "iframe-[my domNodeId]" -width "[expr {[my cols]*[my charwidth]}]" -height "[expr {[my rows]*[my charheight]}]" -src $uri
    set node [textarea -id "[my domNodeId]" -lang [my language] -style "display:none;" { t "" }]
    return $node
}
