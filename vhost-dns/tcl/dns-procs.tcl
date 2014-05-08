
ns_log notice "--->>> ns_dns loading tcl files"

proc dns_init {} {

    ns_log notice "--->>> ns_dns: dns_init"

    set ip "213.7.230.145"

    ns_dns flush
    ns_dns add phigita.com.cy A $ip

    #ns_dns del www.phigita.com.cy A
    #ns_dns del ns1.phigita.net A
    #ns_dns del ns2.phigita.net A
    #ns_dns add www.phigita.com.cy A $ip
    #ns_dns add ns1.phigita.net A $ip
    #ns_dns add ns2.phigita.net A $ip
    #ns_dns add phigita.com.cy NS ns1.phigita.net
#    ns_dns add phigita.net NS ns2.phigita.net
    #ns_dns add phigita.com.cy MX 1 ns1.phigita.net


    ns_log notice "dns list = [ns_dns list]"


}

dns_init
