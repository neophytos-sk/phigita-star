ad_page_contract {

    @author Neophytos Demetriou

} {
    {view "day"}
    {date ""}
}


doc_return 200 text/html [dt_widget_calendar_navigation "test" $view $date]
