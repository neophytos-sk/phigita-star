set form_name addBook
set form_mode edit

ad_conn_set form_count 0
ad_form  -name ${form_name} -mode ${form_mode} -edit_buttons ok -show_required_p n -method post -form {

    {isbn:text
	{label ISBN}}

}

