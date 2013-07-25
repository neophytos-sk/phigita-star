set layers [db_list get_layers "select name from architecture_layers"]

doc_return 200 text/html [join $layers <br>]
