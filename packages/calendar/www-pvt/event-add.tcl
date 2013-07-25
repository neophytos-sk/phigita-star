ad_maybe_redirect_for_registration
package require crc32

#source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/30-form-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/32-textarea-procs.tcl

namespace inscope ::xo::ui {

    Page new -appendFromScript {

	StyleFile new -style_file [acs_root_dir]/packages/blogger/resources/css/combos.css

	JsonStore ds0 \
            -url 'http://my.phigita.net/blog/get-tags' \
            -totalProperty 'totalCount' \
            -root 'tags' \
	    -fields [subst -nobackslashes {
                'tagName' 'numOccurs'
	    }]

        Template tpl0 -html {
	    <tpl for="."><div class="search-item">
	    <h3><span>{numOccurs} entries</span>{tagName}</h3>
	    </div></tpl>
	}

	JS.Function removeDuplicates -argv {arr} -body {
	    var result = new Array(0);
	    var seen = {};
	    for (var i=0; i<arr.length; i++) {
					      if (!seen[arr[i]]) {
						  result.length += 1;
						  result[result.length-1] = arr[i];
					      }
					      seen[arr[i]] = true;
  	    }
	    return result
	}

	JS.Function tagSelectFn -map {tags setCaretToEnd removeDuplicates} -argv {record} -body {
	    var oldValueArray = tags.getValue().split(',');
	    oldValueArray[oldValueArray.length-1] = record.get('tagName');
	    var newValueArray = new Array();
	    for (var i=0; i<oldValueArray.length;i++) {
		newValueArray[i]=oldValueArray[i].trim();
            }
	    var newValue=removeDuplicates(newValueArray).join(', ') + ', ';
	    tags.setValue(newValue);
	    setCaretToEnd(tags);
	    tags.collapse();
	}

	JS.Function setCaretToEnd -argv {el} -body {
	    var length=el.getRawValue().length;
	    el.selectText(length,length);
	}

	Form new -action store -style "width:500px;" -appendFromScript {

	    TextField new \
		-name title \
		-label Subject \
		-allowBlank false \
		-width 350 


	    DateField new \
		-name event_start_date \
		-label Date

	    TimeField new \
		-name event_start_time \
		-label "Time" \
		-format "'H:i'"

	    TextField new \
		-name location \
		-label Location \
		-allowBlank false \
		-width 350

	    TextArea new \
		-name "description" \
		-label "Description" \
		-width 350 \
		-height 150

	    StructuredText new \
		-name "body" \
		-label "Description" \
		-width 350 \
		-height 300 \
		-get_images_url 'http://my.phigita.net/media/view/get-images'

	    #ComboBox location -label "Location" ;# you need a store

	    ComboBox tags -map {
		    {ds0 ds} 
		    {tpl0 resultTpl} 
		    tagSelectFn
		} -name "tags" \
		-label "Tags" \
		-store ds \
		-typeAhead false \
		-width 350 \
		-hideTrigger true \
		-tpl resultTpl \
		-queryParam 'q' \
		-itemSelector 'div.search-item' \
		-onSelect tagSelectFn \
		-allowBlank true \
		-minChars 0 

	    #-collapsible true
	    FieldSet new \
		-title "'Repeating'" \
		-autoHeight true \
		-checkboxToggle "true" \
		-checkboxName "'Repeating Event'" \
		-name "repeating_event_p" \
		-collapsed true \
		-appendFromScript {
		    TextField new -name t1 -label t1
		    TextField new -name t2 -label t2
		    TextField new -name t3 -label t3
		}

	    FieldSet new \
		-title "'Invitations'" \
		-collapsed true \
		-collapsible true -appendFromScript {
		    TextArea new -name email_addresses -label "Email Addresses"
		}

	    FieldSet new \
		-title "'Reminders'" \
		-collapsed true \
		-collapsible true 

	    FieldSet new \
		-title "'Contact Information'" \
		-collapsed true \
		-collapsible true 

	} -proc action(store) {marshaller} {
	    if { [my isValid] } {
		set mydict [my getDict]

		ad_returnredirect $id
	    } else {
		doc_return 200 text/plain [my getDict]
		#doc_return 200 text/plain "Incomplete or Invalid Form"
	    }
	}

    }
}