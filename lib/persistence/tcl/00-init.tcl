package require core
package require util_procs

config section ::persistence

config param use_server "off"
config param use_threads "off"
config param use_memtable "on"

config param client_server "on"
config param write_ahead_log "on"
config param address "127.0.0.1"
config param port "9900"
config param default_storage_type "fs"
config param base_dir "/web/data/mystore"

assert { ![use_p "server"] || [setting_p "client_server"] }

# no point having the commitlog code loaded on the client side,
# the assertion attempts to set the default value to off but if 
# the actual value was tampered with, i.e. if it was explicitly
# set, for example, via config set ::persistence write_ahead_log "on"
# then this assertion would raise an error as the code inside does
# not modify the actual value, only the default 
assert { [use_p "server"] || ![setting_p "write_ahead_log"] } {
    config param write_ahead_log "off"
}

proc can_connect_p {server port} {
    if { [catch {set sock [socket $server $port]} errmsg] } {
        return 0
    }
    close $sock
    return 1
}

set addr [config get ::persistence address]
set port [config get ::persistence port]
assert { 
    ![setting_p "client_server"] 
    || [use_p "server"] 
    || [can_connect_p $addr $port] 
}

