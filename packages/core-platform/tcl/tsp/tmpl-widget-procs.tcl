namespace eval tmpl {;}

ad_proc tmpl::tag=new {
    {-n_items ""}
    {-title ""}
} {
    @author Neophytos Demetriou
} {
    sup { span -style "color: red;font-size:10px;" -title ${title} { t -disableOutputEscaping "New!&nbsp;[ad_decode ${n_items} {} {} (${n_items})]" } }
}