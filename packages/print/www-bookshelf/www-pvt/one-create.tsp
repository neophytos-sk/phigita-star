tmpl::master {

    style {
	c {
	    #review {display:none;}
	}
    }

    form -name bf -action one-create-2 -method post {
	t "ISBN: "
	br
	input -name isbn -type text -size 20 -maxlength 20
	p
	input -value Add -type submit
    }

}