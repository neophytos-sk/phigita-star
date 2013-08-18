
#### JavaScript Classes

::xo::ui::Class ::xo::ui::HtmlText -superclass {::xo::ui::Widget} -parameter {

    {html_text ""}
    {inline_p "no"}

} -jsClass Ext.Panel

::xo::ui::HtmlText instproc getConfig {} {
    my instvar domNodeId
    lappend config "contentEl:'${domNodeId}'"
    return \{[join $config {,}]\}
}

::xo::ui::HtmlText instproc render {visitor} {
    my instvar domNodeId
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    $visitor ensureNodeCmd elementNode iframe
    set node [next]
    $node setAttribute id [my domNodeId]
    $node appendFromScript {
	if { [my inline_p] } {
	    t -disableOutputEscaping [my html_text]
	} else {
	    set uri [my uri -select [my domNodeId] -action returnHtmlText]
	    iframe -src $uri
	}
    }
    return $node
}

::xo::ui::HtmlText instproc action(returnHtmlText) {marshaller} {
    ns_return 200 text/html [my html_text]
}


Class ::xo::ui::HtmlFile -superclass {::xo::ui::Widget} -parameter {
    {html_file ""}
}

::xo::ui::HtmlFile instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureNodeCmd elementNode iframe
    [next] appendFromScript {
	set uri [my uri -select [my domNodeId] -action returnHtmlFile]
	iframe -src $uri
    }
}

::xo::ui::HtmlFile instproc action(returnHtmlFile) {marshaller} {
    ns_return 200 text/css [my html_file]
}

Class ::xo::ui::ImageFile -superclass {::xo::ui::Widget} -parameter {
    {image_file ""}
}

::xo::ui::ImageFile instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureNodeCmd elementNode img

    [next] appendFromScript {
	set uri [my uri -select [my domNodeId] -action returnImageFile -allow_vuh_p false]
	img -src $uri
    }
}

::xo::ui::ImageFile instproc action(returnImageFile) {marshaller} {
    ad_returnfile_background 200 [ns_guesstype [my image_file]] [my image_file]
}





###################
