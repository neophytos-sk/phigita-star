
ad_page_contract {
    @author Neophytos Demetriou
} {
    {numHours:naturalnum 48}
}


ad_schedule_proc -thread t -once t 0 ::bow::refreshClusters
doc_return 200 text/html ok
