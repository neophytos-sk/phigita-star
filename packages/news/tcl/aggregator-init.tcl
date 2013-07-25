if { [ns_config ns/server/[ns_info server] is_crawler_p 0] } {
    #ad_schedule_proc -thread t 90 ::aggregator::refresh
    ns_schedule_proc -once 0 ::crawler do -async ::aggregator::startCrawler
}