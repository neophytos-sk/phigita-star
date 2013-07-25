ad_page_contract {
    @author Neophytos Demetriou
} {
    upload_file:trim,notnull
    upload_file.tmpfile:tmpfile,optional
    {input_format:trim,notnull "doc"}
    {output_format:trim,notnull "pdf"}
}


set ooo_port 8100




set time [ns_time]

set target_file ${upload_file.tmpfile}-${upload_file}-${time}.${output_format}
set input_file ${upload_file.tmpfile}-${upload_file}-${time}.${input_format}
file rename ${upload_file.tmpfile} ${input_file}

ns_log notice "OOO Converting ${upload_file} from ${input_format} to ${output_format} (${input_file} -> ${target_file})"

#set jar_file [acs_root_dir]/www/ooo-converter/jodconverter-2.2.0/lib/jodconverter-cli-2.2.0.jar
#exec -- /bin/sh -c "/usr/bin/java -jar $jar_file ${input_file} $target_file || exit 0" 2> /dev/null

set PYTHON_WITH_UNO /usr/lib/openoffice/program/python
exec -- /bin/sh -c "${PYTHON_WITH_UNO} [acs_root_dir]/scripts/DocumentConverter.py ${input_file} ${target_file} || exit 0" 2> /dev/null


ns_returnfile 200 [ns_guesstype $target_file] $target_file



