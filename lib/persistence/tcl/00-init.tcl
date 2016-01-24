package require core
package require bloom_filter
package require critbit_tree


config section ::persistence

config param address "127.0.0.1"
config param port "9900"

# config param base_dir "/web/data/mystore"
config param base_dir "/web/data/mystore2"

config param storage_type "ss"


# config param base_nsp "::persistence::fs"
config param base_nsp "::persistence::commitlog"
config param compact_p "1"

config param sstable_fragment_size_threshold 100000000
config param commitlog_size_threshold 100000000
config param commitlog_n_entries_threshold 5000


config param use_server "off"
config param use_threads "off"

config param sstable "on"
config param commitlog "on"

config param memtable "off"
config param write_ahead_log "off"  ;# DEPRECATED
config param critbit_tree "off"
config param bloom_filters "off"
config param client_server "on"

config param process_commitlog_millis "120000" ;# 120 secs

# READ UNCOMMITTED -
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
# READ COMMITTED -
#
#   a statement can only see records committed before it began
#
# REPEATABLE READ -
#
#   all statements of the current transaction can only see records
#   committed before the first query or data-modification statement
#   was executed in this transaction
#
# SERIALIZABLE -
#
#   all statements of the current transaction can only see rows
#   committed before the first query or data-modification 
#   statement was executed in this transaction, if a pattern of
#   reads and writes among concurrent serializable transactions
#   would create a situation which could not have occurred for
#   any serial (one-at-a-time) execution of those transactions,
#   one of them will be rolled back with a serialization_failure
#   error
#
config param isolation_level "READ UNCOMMITTED"

# Multiversion Concurrency Control (MVCC) offers behavior where
# "readers never block writers, and writers never block readers."
# 
# MVCC snapshots control which tuples are visible for SQL 
# statements. A snapshot is recorded at the start of each SQL
# statement in READ COMMITTED transaction isolation mode, and
# at transaction start in SERIALIZABLE transaction isolation
# mode. In fact, it frequency of taking new snapshots that controls
# the transaction isolation behavior.
#
# When a new snapshot is taken, the following information is gathered:
# * the highest-numbered committed transaction
# * the transaction numbers currently executing
# Using this snapshot information, we can determine if a transaction's
# actions should be visible to an executing statement. 
# (PostgreSQL, MVCC unmasked, Bruce Momjian)
#
config param mvcc "on"

# any isolation level other than "READ UNCOMMITTED"
# requires both the commitlog and the mvcc features,
# note, however, that one may use either the commitlog
# or the mvcc features even if the isolation level
# is "READ UNCOMMITTED"
assert { [setting "isolation_level"] eq {READ UNCOMMITTED} || [setting_p "write_ahead_log"] }
assert { [setting "isolation_level"] eq {READ UNCOMMITTED} || [setting_p "mvcc"] }

assert { ![setting_p "write_ahead_log"] || [setting_p "memtable"] }
assert { ![setting_p "bloom_filters"] || [setting_p "write_ahead_log"] }
assert { ![setting_p "critbit_tree"] || [setting_p "write_ahead_log"] }

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

