Class IteratingRow -parameter {
    key
    finishedAt
    file
    sstable
    dataStart
    partitioner
}

IteratingRow instproc init { file sstable } {
    my instvar dataStart

    my set file $file
    my set sstable $sstable
    # HERE: my set partitioner [StorageService getPartitioner]
    # HERE: my set key [$partitioner convertFromDiskFormat [$file readUTF]]
    my set key [$file readJavaUTF]
    #my set key [$file readVarText] ;# utf-8

    set dataSize [$file readInt]
    set dataStart [$file getFilePointer]
    my set finishedAt [expr {$dataStart + $dataSize}]

}

IteratingRow instproc getEndPosition {} {
    return [my set finishedAt]
}

IteratingRow instproc getColumnFamily {} {
    my instvar file dataStart sstable
    $file seek $dataStart
    #IndexHelper.skipBloomFilter(file);
    #IndexHelper.skipIndex(file);
    #return ColumnFamily.serializer().deserializeFromSSTable(sstable, file);
    deserializeFromSSTable $sstable $file
}


Class SSTable -parameter {ssTableFile}
SSTable instproc getFileName {} {
    return [my set ssTableFile]
}

Class SSTableScanner -parameter {
    file
    sstable
    row
}

SSTableScanner instproc init {sstable} {
    my set file [::xo::io::BufferedRandomAccessFile new [$sstable getFileName] "r" [expr {256*1024}]]
    my set sstable $sstable
}

SSTableScanner instproc hasNext {} {
    my instvar file row
    return [expr { ![$file isEOF] || [$row getEndPosition] < [$file length] }]
}

SSTableScanner instproc nextRow {} {
    my instvar file sstable row
    set row [IteratingRow new $file $sstable]

    return $row
}

Class SSTableReader -superclass SSTable
SSTableReader instproc open {ssTableFile} {
    #my set ssTableFile $ssTableFile
}
SSTableReader instproc getScanner {} {
    return [SSTableScanner new [self]]
}

SSTableReader instproc getTableName {} {
    my instvar file
    return [my parseTableName $file]
}
SSTableReader instproc makeColumnFamily {} {
    return [Object new -set tableName [my getTableName] -set cfName [my getColumnFamilyName]]

    #return ColumnFamily.create(getTableName(), getColumnFamilyName());
}

Class SSTableExport

SSTableExport instproc serializeRow {row} {
    set cf [$row getColumnFamily]
    
}

SSTableExport instproc export {ssTableFile} {
    # SSTableReader 
    set reader [SSTableReader new -ssTableFile $ssTableFile]
    #puts [$reader getFileName]
    # SSTableScanner 
    set scanner [$reader getScanner]
    
    #outs.println("{");
    set result ""
    append result "\{"
    
    while { [$scanner hasNext] } {
	#IteratingRow 
	set row [$scanner nextRow]
	#try {
	    set jsonOut [my serializeRow $row]
	    #outs.print("  " + jsonOut);
	    append result "  "
	    append result $jsonOut

	    if { [$scanner hasNext] } {
		append result ","
	    } else {
		append result "\n"
	    }
	#} 
	#catch {IOException ioexcep} {
	# System.err.println("WARNING: Corrupt row " + row.getKey().key + " (skipping).");
	# continue;
	#}
	#catch (OutOfMemoryError oom)
	#{
	#System.err.println("ERROR: Out of memory deserializing row " + row.getKey().key);
	#continue;
	#}
    }
    append result "\}"
    #outs.println("}");
    #outs.flush();

}