namespace eval ::xo {;}
namespace eval ::xo::ui {;}

# buttons: OKCANCEL | YESNOCANCEL
Class ::xo::ui::MessageBox -superclass {::xo::ui::Widget} -parameter {
    {msg ""}
    {title ""}
    {fn ""}
    {autocreatebutton "true"}
    {closable "true"}
    {buttons "OKCANCEL"}
}

::xo::ui::MessageBox instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureLoaded Ext.Core

    $visitor inlineJavascript [subst -nobackslashes {
	function showResult() {
	    alert('test');
	}

	var [my domNodeId] = function(){
	    var dialog, showBtn;
	    return {
		init : function(){
		    Ext.get('mb_[my domNodeId]').on('click', function(e){
			Ext.MessageBox.show({
			    title: [my singlequote title],
			    msg: [my singlequote msg],
			    width:300,
			    buttons: Ext.MessageBox.[my buttons],
			    multiline: true,
			    progress: true,
			    closable: [my closable],
			    fn: [my fn],
			    animEl: 'mb_[my domNodeId]'
			});
		    });
		}
	    };
	}();
    }]
    $visitor onReady [my domNodeId].init [my domNodeId] true
    
    if { [my autocreatebutton] } {
	$visitor ensureNodeCmd elementNode input
	input -type "button" -id "mb_[my domNodeId]" -value "[my label]"
    }
}

if {[Object isobject ::xo::ui::Dialog] } {
    ::xo::ui::Dialog destroy
}
Class ::xo::ui::Dialog -superclass {::xo::ui::Widget} -parameter {
    {modal "false"}
    {autoTabs "true"}
    {width "500"}
    {height "300"}
    {minWidth "300"}
    {minHeight "250"}
    {shadow "false"}
    {constraintoviewport "true"}
    {proxyDrag "true"}
    {iframe "false"}
    {animateTarget ""}
    {draggable "true"}
    {autocreatebutton "true"}
}

::xo::ui::Dialog instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureLoaded EXT.Core

    if { [my draggable] } {
#	$visitor ensureLoaded YUI.util.DragDrop
    }
    if { [my animateTarget] ne {} } {
#	$visitor ensureLoaded YUI.util.Animation
    }

    $visitor inlineJavascript [subst -nobackslashes {
	var [my domNodeId] = function(){
	    var dialog, showBtn;
	    return {
		init : function(){
		    if(!dialog){ // lazy initialize the dialog and only create it once
			dialog = new Ext.BasicDialog("[my domNodeId]", { 
			    modal:[my modal],
			    autoTabs:[my autoTabs],
			    width:[my width],
			    height:[my height],
			    shadow:[my shadow],
			    constraintoviewport:[my constraintoviewport],
			    minWidth:[my minWidth],
			    minHeight:[my minHeight],
			    proxyDrag: [my proxyDrag],
			    iframe: [my iframe]
			});
			dialog.addKeyListener(27, dialog.hide, dialog);
			dialog.addButton('Close', dialog.hide, dialog);
			dialog.addButton('Submit', dialog.hide, dialog).disable();
		    }
		    showBtn = Ext.get('show-dialog-btn_[my domNodeId]');
		    showBtn.on('click', [my domNodeId].showDialog);
		},
		showDialog : function(){
		    dialog.show([my animateTarget]);
		}
	    };
	}();
    }]
    $visitor onReady [my domNodeId].init [my domNodeId] true

    if { [my autocreatebutton] } {
	$visitor ensureNodeCmd elementNode input
	input -type "button" -id "show-dialog-btn_[my domNodeId]" -value "[my label]"
    }

    [$visitor last] appendFromScript {
	set node [next]
    }
    $node setAttribute style "visibility:hidden;position:absolute;top:0px;"

    $node appendFromScript {
	div -class "x-dlg-hd" { t [my label] }
	set innerNode [div -class "x-dlg-bd"]
    }

    return $innerNode
}


::xo::ui::Dialog instproc accept {{-rel "default"} {-action "visit"} visitor} {
    if { [my autoTabs] } {
	set instmixins [Panel info instmixin]
	set self [self]
	Panel instmixin add [subst -nobackslashes -nocommands {::xo::ui::DialogTab -guard {[my parentNode] eq {$self}}}]
	set node [next]
	Panel instmixin $instmixins
	return $node
    } else {
	return [next]
    }
}

Class ::xo::ui::DialogTab -superclass {::xo::ui::Widget}
::xo::ui::DialogTab instproc render {visitor} {
    div -class "x-dlg-tab" -title [my label] {
	div -class "innerTab" {
	    set node [next]
	}
    }
    return $node
}
