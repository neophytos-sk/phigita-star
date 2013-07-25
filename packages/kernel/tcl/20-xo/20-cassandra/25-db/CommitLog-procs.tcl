namespace eval ::xo::db {;}

Object ::DB_DESCRIPTOR

::DB_DESCRIPTOR proc getLogFileLocation {} {
    return /web/db/commitlog
}


# experimental stuff
::xotcl::THREAD ::COMMIT_LOG {

    Class ::xo::db::CommitLog -parameter {
	{segment_size "[expr {128*1024*1024}]"}
	__logFile
	__clHeader
	__logWriter
	__lock
    }


    ::xo::db::CommitLog instproc init {recoveryMode} {
	if { ! $recoveryMode } {
	    my setNextFileName
	    my __logWriter [my createWriter [my __logFile]]
	    my writeCommitLogHeader
	}
    }

    ::xo::db::CommitLog instproc createWriter {filename} {
	return [::xo::io::File new -filename $filename -access {RDWR CREAT}]
    }

    ::xo::db::CommitLog instproc writeCommitLogHeader {} {
	### HERE ###
	return
	my instvar __clHeader __logWriter
	set cfSize [Table.TableMetadata getColumnFamilyCount]
	set __clHeader [CommitLogHeader new $cfSize]
	my writeCommitLogHeader.2 $__logWriter [$__clHeader toByteArray]
    }

    ::xo::db::CommitLog instproc writeCommitLogHeader.2 {logWriter bytes} {
	$logWriter writeLong [string bytelength $bytes]
	$logWriter write $bytes
	$logWriter sync
    }

    ::xo::db::CommitLog instproc setNextFileName {} {
	my instvar __logFile

	set __logFile [file join [::DB_DESCRIPTOR getLogFileLocation] "CommitLog.[clock milliseconds].log"]
    }

    ::xo::db::CommitLog instproc addLogRecord.2 {text} {
	my writeCommitLogHeader.2 [my __logWriter] $text
    }


    ::xo::db::CommitLog create logger false
    

} -persistent 1


::COMMIT_LOG proc addLogRecord {rm} {
    set text [$rm toString]
    my do logger addLogRecord.2 $text
}
###::COMMIT_LOG forward addLogRecord %self do logger %proc

return

::xo::db::CommitLog instproc getCreationTime {fileName} {
    return [lindex [split ${fileName} ".-"] end-1]
}

::xo::db::CommitLog instproc setSegmentSize {size} {
    my instvar segment_size
    set segment_size $size
}

::xo::db::CommitLog instproc getSegmentCount {} {
    my instvar __clHeader
    return [$__clHeader getCount]
}

::xo::db::CommitLog instproc seekAndWriteCommitLogHeader {bytes} {
    my instvar __logWriter
    set currentPos [$__logWriter getFilePointer]
    $__logWriter seek 0
    my writeCommitLogHeader.2 $__logWriter $__bytes
}

::xo::db::CommitLog instproc maybeUpdateHeader {rm} {
    my instvar __clHeader __logWriter
    foreach columnFamily [$rm getColumnFamilies] {
	set id [$rm getColumnFamilyId]
	if { ![$__clHeader isDirty $id] } {
	    $__clHeader turnOn $id [$__logWriter getFilePointer]
	    my seekAndWriteCommitLogHeader [$clHeader_ toByteArray]
	}
    }
}


#####################



proc ::xo::db::CommitLogFileComparator {f1 f2} {
    return [expr {[$f1 getCreationTime]-[$f2 getCreationTime]}]
}


#####################

Class ::xo::db::CommitLogContext -parameter {
    fileName
    position
}

::xo::db::CommitLogContext isValidContext {} {
    return [::util::boolean [expr { ${position} != -1 }]]
}