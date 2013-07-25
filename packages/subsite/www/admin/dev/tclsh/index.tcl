if { ![::util::boolean [ad_conn issecure]] } {
    ad_returnredirect https://[ad_host][ns_conn url]
    return
}
permission::require_permission -object_id [ad_conn package_id] -privilege admin
#source [acs_root_dir]/packages/kernel/tcl/20-templating/32-textarea-procs.tcl
namespace inscope ::xo::ui {

    Page new -master ::xo::ui::DefaultMaster -title "TCL Shell" -appendFromScript {

	JS.Function onSpecialKeyFn -argv {f e} -body {
	    if (e.getKey()==e.TAB && !e.shiftKey) {
		e.stopEvent();
		var myValue = '    ';
		if (Ext.isIE) {
		    var sel = document.selection.createRange();
		    sel.text=myValue;
		} else {
		    var htmlEl = f.el.dom;
		    var startPos = htmlEl.selectionStart;
		    var endPos = htmlEl.selectionEnd;
		    htmlEl.value = htmlEl.value.substring(0, startPos) + myValue + htmlEl.value.substring(endPos, htmlEl.value.length);
		    htmlEl.setSelectionRange(endPos+myValue.length, endPos+myValue.length);
		}
	    }
	}

	JS.Function saveScriptFn -body {
	    alert('save not yet implemented');
	}

	Toolbar tb0 -appendFromScript {

            Toolbar.Button new \
                -text "'Save'" \
                -map {saveScriptFn} \
                -handler saveScriptFn

	}

	Panel new \
	    -title "'TCL Shell'" \
	    -tbar tb0 \
	    -width 700 \
	    -style "'margin:auto;'" \
	    -appendFromScript {

		Form new \
		    -label "TCL Shell" \
		    -action eval \
		    -height 400 \
		    -width 700 \
		    -labelAlign 'top' \
		    -standardSubmit true \
		    -submitText "Submit" \
		    -appendFromScript {
			
			TextArea new \
			    -label "Body" \
			    -name body \
			    -anchor "'100% 50%'" \
			    -allowBlank false \
			    -map {onSpecialKeyFn} \
			    -listeners {
				specialKey onSpecialKeyFn
			    }
			
			TextArea new \
			    -label "Result" \
			    -name result \
			    -anchor "'100% 50%'" \
			    -allowBlank true
			
			
		    } -proc action(eval) {marshaller} {
			if { [my isValid] } {
			    set mydict [my getDict]
			    set body [dict get $mydict body]
			    if { [catch {
				set result [eval $body]
			    } errmsg] } {
				global errorInfo errorCode 
				set result ERROR\n${errmsg}\n\n($errorCode,$errorInfo
							    }
				dict set mydict result $result
				my initFromDict $mydict
				$marshaller go -select "" -action draw
				return
			    } else {
				foreach o [my getFields] {
				    $o set value [$o getRawValue]
				    if { ![$o isValid] } {
					$o markInvalid "Failed Validation"
					ns_log notice "failed validation $o [$o info class] [$o getRawValue]"
				    }
				}
				$marshaller go -select "" -action draw
			    }
			}
		    }

	    }
    }