package require core
package require bloom_filter


config section ::persistence

config param address "127.0.0.1"
config param port "9900"
config param default_storage_type "fs"
#config param base_dir "/web/data/mystore"
config param base_dir "/web/data/mystore2"

config param use_server "off"
config param use_threads "off"

config param memtable "on"
config param bloom_filters "on"
config param client_server "on"
config param write_ahead_log "on"

# read_uncommitted -
#
#   dirty read, a transaction reads data written by a concurrent 
#   uncommitted transaction
#
#   nonrepeatable read, a transaction re-reads data it
#   has previously read and finds that data has been modified by
#   another transaction that committed since the initial read
#
#   phantom read, a transaction re-executes a query returning a
#   set of rows that satisfy a search condition and finds that
#   the set of rows satisfying the condition has changed due to
#   another recently committed transaction
#
# read_committed -
#   a statement can only see records committed before it began
#
# repeatable_read -
#   all statements of the current transaction can only see records
#   committed before the first query or data-modification statement
#   was executed in this transaction
#
# serializable -
#   all statements of the current transaction can only see rows
#   committed before the first query or data-modification 
#   statement was executed in this transaction, if a pattern of
#   reads and writes among concurrent serializable transactions
#   would create a situation which could not have occurred for
#   any serial (one-at-a-time) execution of those transactions,
#   one of them will be rolled back with a serialization_failure
#   error
#
config param isolation_level "read_uncommitted" ;# read_committed, repeatable_read, serializable




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

