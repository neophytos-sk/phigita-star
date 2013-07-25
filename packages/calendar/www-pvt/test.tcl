source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/30-form-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/55-grid-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/65-DatePicker-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/70-tab-procs.tcl
#source [acs_root_dir]/packages/persistence/tcl/ZZ-tablet-procs.tcl






namespace inscope ::xo::ui {

    Page new -master ::xo::ui::DefaultMaster -appendFromScript {

	Form new \
	    -monitorPoll 100 \
	    -labelAlign 'top' \
	    -standardSubmit false \
	    -submitText "Save" \
	    -autoHeight true \
	    -appendFromScript {
		RadioGroup new -label "Due" -name has_due_date_p -value "t" -appendFromScript {
		    Radio new -value t -label "Red"
		    Radio new -value f -label "Green"
		}
	    }
    }
}