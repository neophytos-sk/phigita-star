# Author: Vlad Seryakov vlad@crystalballinc.com
# March 2003

# Loads local hosts file
proc dns_reload { hosts } {

    if { [catch { set fd [open $hosts] }] } { return }
    ns_dns flush
    set count 0
    while { ![eof $fd] } {
      set line [string trim [gets $fd]]
      if { $line == "" || [string index $line 0] == "#" } { continue }
      set ipaddr [lindex $line 0]
      foreach name [lrange $line 1 end] {
        ns_dns add $name A $ipaddr 0
        incr count
      }
    }
    close $fd
    ns_log Notice nsdns: $hosts loaded, $count records
}

if { [info command ns_dns] != "" } {
  dns_reload /etc/hosts
}
