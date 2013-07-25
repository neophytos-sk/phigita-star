
namespace eval ::xo::db {;}


Class ::xo::db::RowMutation -parameter {
    key
}

::xo::db::RowMutation instproc init {args} {
    my instvar modifications_
    array set modifications_ [list]
}

::xo::db::RowMutation instproc addColumn {cf path value ts} {
    my instvar modifications_
    lappend modifications_($cf) [list SET $path $value $ts]
}

::xo::db::RowMutation instproc deleteColumn {cf path ts} {
    my instvar modifications_
    lappend modifications_($cf) [list DEL $path $ts]
}

::xo::db::RowMutation instproc toString {} {
    my instvar modifications_
    return [array get modifications_]
}

#StorageManager

Class ::xo::db::ObjectCommitLogger 


::xo::db::ObjectCommitLogger instproc rdb.self-delete {args} {
    set result [next]
    ns_log notice "sendOneWay delete [my getRowKey] [my getColumnPath] [my getTimestamp]"
    set line "delete [list [my getRowKey] [my getColumnPath] [my getTimestamp]]"
    bg_sendOneWay $line

    set key [my getRowKey]
    set cf [my getColumnFamily]
    set path [my getColumnPath] ;# HERE: Revise format of column path
    set ts [my getTimestamp]

    set rm [::xo::db::RowMutation new -key $key]
    $rm deleteColumn $cf $path $ts
    
    ::COMMIT_LOG addLogRecord $rm
    return $result
}

::xo::db::ObjectCommitLogger instproc rdb.self-insert {args} {
    set result [next]
    ns_log notice [list sendOneWay insert... [my getRowKey] [my getColumnPath] [my toDict] [my getTimestamp]]
    set line  "insert [list [my getRowKey] [my getColumnPath] [my toDict] [my getTimestamp]]"
    bg_sendOneWay $line

    set key [my getRowKey]
    set cf [my getColumnFamily]
    set path [my getColumnPath] ;# HERE: Revise format of column path
    set value [my toDict]
    set ts [my getTimestamp]

    set rm [::xo::db::RowMutation new -key $key]
    $rm addColumn $cf $path $value $ts

    ::COMMIT_LOG addLogRecord $rm
    $rm destroy
    return $result
}
::db::Object instmixin add ::xo::db::ObjectCommitLogger