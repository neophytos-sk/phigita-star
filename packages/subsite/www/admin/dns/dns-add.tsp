tmpl::simple {

    ns_dns flush
    t [ns_dns del www.phigita.net A]
    t [ns_dns del ns1.phigita.net A]
#    t [ns_dns del ns2.phigita.net A]
    t [ns_dns add www.phigita.net A 81.4.161.50]
    t [ns_dns add ns1.phigita.net A 81.4.161.50]
#    t [ns_dns add ns2.phigita.net A 81.4.161.50]
    t [ns_dns add phigita.net NS ns1.phigita.net]
#    t [ns_dns add phigita.net NS ns2.phigita.net]
    t [ns_dns add phigita.net MX 1 ns1.phigita.net]


    t [ns_dns list]


}