tmpl::master {

    foreach cl [DB_Class info instances] {
	t $cl
    }

}