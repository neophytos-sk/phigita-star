 # Place to look for the configuration file
 switch $tcl_platform(platform) {
    unix - mac {
       set ConfigFile ~/.tclSpamFilter/config.tcl
    }
    windows {
       # This seems to be the right spot on Win98...
       set ConfigFile "c:/windows/application data/Tcl Spam Filter/config.tcl"
    }
 }

 #----------------------------------------------------------------------
 # extendTable --
 #      Merges the words found in the given string into the given table.
 #      Takes an optional argument (which should be 1, the default, or
 #      -1) that allows you to instead request that the given string's
 #      words should be removed from the table.
 #
 # Return Value:
 #      Not believed to be useful.
 #
 # Side Effects:
 #      Updates three global variables; if the type argument is foo, the
 #      global variables affected will be fooTable, fooCount and access
 #      (which tracks the last time the words were updated, to allow for
 #      automatic pruning of uncommon words, like strings found in
 #      base64-encoded binaries.)
 #
 proc extendTable {type string {direction 1}} {
    global WordRE access
    upvar #0 ${type}Table t ${type}Count c
    set i 0
    set now [clock seconds]
    while {[regexp -indices -start $i $WordRE $string match]} {
       foreach {j i} $match {}
       set word [string range $string $j $i]
       if {[catch {
          if {[incr t($word) $direction] == 0} {
             unset t($word)
          } else {
             set access($word) $now
          }
       }]} then {
          set t($word) $direction
          set access($word) $now
       }
       incr i
    }
    incr c $direction
 }

 #----------------------------------------------------------------------
 # generateProbability --
 #      Computes the probability that the given word is something that
 #      is in a spammed message.  See the extended comments in
 #      http://www.paulgraham.com/spam.html for details of how this
 #      works and why particular magic values were chosen.
 #
 # Return Value:
 #      Probability value (in range [0.01,0.99])
 #
 # Side Effects:
 #      None
 #
 proc generateProbability {word} {
    global goodTable goodCount badTable badCount
    set g 0
    catch {
       # Bias towards good words for safety.
       set g [expr {$goodTable($word) * 2}]
    }
    set b 0
    catch {
       set b $badTable($word)
    }
    if {$g == 0 && $b == 0} {
       # Not seen before
       return 0.2
    }
    if {$g+$b < 5} {
       # Not frequent enough
       return 0.2
    }
    set bfreq [min 1.0 [expr {double($b)/$badCount}]]
    set gfreq [min 1.0 [expr {double($g)/$goodCount}]]
    return [max 0.01 [min 0.99 [expr {$bfreq / ($gfreq + $bfreq)}]]]
 }

 #----------------------------------------------------------------------
 # combine --
 #      Combines probability values.
 #
 # Return Value:
 #      Probability value (in range [0.0,1.0])
 #
 # Side Effects:
 #      None
 #
 proc combine {probs} {
    set p1 1.0
    set p2 1.0
    foreach prob $probs {
       set p1 [expr {$p1 * $prob}]
       set p2 [expr {$p2 * (1.0 - $prob)}]
    }
    return [expr {$p1 / ($p1 + $p2)}]
 }

 #----------------------------------------------------------------------
 # min, max --
 #      Find minimum/maximum of two values.
 #
 # Return Value:
 #      The minimum/maximum of the two arguments.
 #
 # Side Effects:
 #      None
 #
 proc min {x y} {expr {$x<$y ? $x : $y}}
 proc max {x y} {expr {$x>$y ? $x : $y}}

 #----------------------------------------------------------------------
 # isSpam --
 #      Guess whether a given message is spam.  This is done by finding
 #      the 16 most interesting words in the messages (i.e. those whose
 #      probabilities deviate most strongly from being neutral) and
 #      combining those words' probabilities to give an overall
 #      probability that a particular message is spam.  This is then
 #      converted into a boolean value with a trivial threshold
 #      function, so that messages are only found to be spam when the
 #      code is better than 90% sure of it.
 #
 # Return Value:
 #      Boolean indicating whether the message is (probably) spam.
 #
 # Side Effects:
 #      Appends a human-readable explanation of why the message is
 #      believed to be spam (or not) to the global variable "reasons",
 #      which can be used for logging purposes.
 #
 proc isSpam {message} {
    global WordRE reasons
    set i 0

    while {[regexp -indices -start $i $WordRE $message match]} {
       foreach {j i} $match {}
       set t([string range $message $j $i]) {}
       incr i
    }
    foreach word [array names t] {
       set p [generateProbability $word]
       lappend magic [list [expr {abs($p-0.5)}] $p $word]
    }
    foreach l [lrange [lsort -decreasing -real -index 0 $magic] 0 15] {
       append reasons "[lindex $l 2] (score=[lindex $l 1]) "
       lappend interesting [lindex $l 1]
    }
    set score [combine $interesting]
    append reasons "=> Overall Score $score"
    return [expr {$score > 0.9}]
 }

 #----------------------------------------------------------------------
 # saveTables --
 #      Writes the state variables to a file.
 #
 # Return Value:
 #      None
 #
 # Side Effects:
 #      Writes file.
 #
 # To Do:
 #      Make updates to this file be much more bullet-proof.  At the
 #      moment, if something goes wrong during the update, the system
 #      *will* fail horribly and lose all previously computed data.
 #
 proc saveTables {} {
    global TableFile goodTable goodCount badTable badCount
    set f [open $TableFile w]
    puts $f [list \
          [array get goodTable] $goodCount \
          [array get badTable]  $badCount  \
          [array get access]]
    close $f
 }

 #----------------------------------------------------------------------
 # loadTables --
 #      Reads the state variables from a file.
 #
 # Return Value:
 #      None
 #
 # Side Effects:
 #      Updates global state variables.
 #
 proc loadTables {} {
    global TableFile goodTable goodCount badTable badCount access
    set list {}
    catch {
       set f [open $TableFile r]
       set list [read $f]
       close $f
    }
    array unset goodTable
    array unset badTable
    set done 0; # Flag because of catch!
    catch {
       if {[llength $list] == 5} {
          foreach {gt gc bt bc ac} $list {}
          if {
             !([llength $gt] & 1) &&
             !([llength $bt] & 1) &&
             !([llength $ac] & 1) &&
             [string is integer -strict $gc] &&
             [string is integer -strict $bc]
          } then {
             array set goodTable $gt
             set goodCount $gc
             array set badTable $bt
             set badCount $bc
             array set access $ac
             set done 1
          }
       }
    }
    if {!$done} {
       array set goodTable {}
       set goodCount 0
       array set badTable {}
       set badCount 0
       array set access {}
    }
 }

 #----------------------------------------------------------------------
 # expireTables --
 #      Removes entries in the tables that haven't been written recently
 #      and that are not very common.  This allows the code to be used
 #      in fully automatic mode, because low-use entries from encoded
 #      binaries will get trimmed automatically.
 #
 # Return Value:
 #      None
 #
 # Side Effects:
 #      Might remove entries from global tables.
 #
 proc expireTables {} {
    global goodTable badTable access Expiry expires
    if {!$Expiry(Enabled)} {
       return
    }
    set expires [expr {[clock seconds]-$Expiry(Interval)}]
    foreach {word time} [array get access] {
       if {$time > $expires} {
          # Not expired yet!
          continue
       }
       set total 0
       catch {incr total $goodTable($word)}
       catch {incr total $badTable($word)}
       if {$total > $Expiry(InhibitCount)} {
          # Too common anyway
          continue
       }
       catch {unset goodTable($word)}
       catch {unset badTable($word)}
       unset access($word)
    }
 }

 #----------------------------------------------------------------------
 # log --
 #      Write a log message to the log file.  Tries to add potentially
 #      useful information extracted from the message being processed.
 #      Also used to log all errors that occur, so be careful with it!
 #
 # Return Value:
 #      None
 #
 # Side Effects:
 #      Appends to the log file.
 #
 proc log {string infoMsg {optMsg {}}} {
    global Log
    if {!($Log(Enabled) || [string length $optMsg])} {
       return
    }

    set s [clock format [clock seconds]]
    if {[string length $string] && $Log(Subject)} {
       if {[regexp -line {^Subject:\s+(.*)} $string -> subject]} {
          append s ": subject=$subject"
       } else {
          append s ": no subject"
       }
    } else {
       append s ":"
    }
    if {[string length $string] && $Log(Source)} {
       if {[regexp -line {^(?:Sender|From):\s+(.*)} $string -> source]} {
          append s ": source=$source"
       } else {
          append s ": no source"
       }
    } else {
       append s ":"
    }
    append s $infoMsg

    if {[string length $optMsg]} {
       append s "\n$optMsg"
    }

    set fid [open $Log(File) a]
    puts $fid $s
    close $fid
 }

 ###--------------------------------------------------------------------
 ### Basic functionality interfaces
 ###
 ###    These all read a message from a channel (stdin by default) and
 ###    then either add the message to the appropriate table, remove it
 ###    from the table or transfer it from one table to another.  They
 ###    also all save their state when done.
 ###
 ### addSpam          - add message as spam
 ### addNonspam       - add message as non-spam
 ### removeSpam       - remove message as no longer spam
 ### removeNonspam    - remove message as no longer non-spam
 ### convertToSpam    - transfer message from non-spam to spam
 ### convertToNonspam - transfer message from spam to non-spam

 #----------------------------------------------------------------------
 proc addSpam {{fid stdin}} {
    set message [read $fid]
    extendTable bad $message
    log $message "added as spam"
    saveTables
 }

 #----------------------------------------------------------------------
 proc addNonspam {{fid stdin}} {
    set message [read $fid]
    extendTable good $message
    log $message "added as non-spam"
    saveTables
 }

 #----------------------------------------------------------------------
 proc removeSpam {{fid stdin}} {
    set message [read $fid]
    extendTable bad $message -1
    log $message "removed from spam"
    saveTables
 }

 #----------------------------------------------------------------------
 proc removeNonspam {{fid stdin}} {
    set message [read $fid]
    extendTable good $message -1
    log $message "removed as non-spam"
    saveTables
 }

 #----------------------------------------------------------------------
 # Transfer message from one table to the other
 proc convertToSpam {{fid stdin}} {
    set message [read $fid]
    extendTable good $message -1
    extendTable bad $message
    log $message "converted to spam"
    saveTables
 }

 #----------------------------------------------------------------------
 proc convertToNonspam {{fid stdin}} {
    set message [read $fid]
    extendTable bad $message -1
    extendTable good $message
    log $message "converted to non-spam"
    saveTables
 }

 ###--------------------------------------------------------------------
 ### Filtering interfaces
 ###

 #----------------------------------------------------------------------
 # filterSpam --
 #      Determine if the given message (read from stdin or some other
 #      specified channel) is spam, log how it decided this, and then
 #      exit with an error if the message is spam, and exit normally
 #      otherwise.
 #
 # Return Value:
 #      Does not return
 #
 # Side Effects:
 #      Program exits, and writes to log file.
 #
 proc filterSpam {{fid stdin}} {
    global reasons exitCode
    set flag [isSpam [set message [read $fid]]]
    log $message "${reasons}: [expr {$flag ? $exitCode(0) : $exitCode(1)}]"
    exit $flag
 }

 #----------------------------------------------------------------------
 # aggressiveFilterSpam --
 #      Determine if the given message (read from stdin or some other
 #      specified channel) is spam, log how it decided this, and then
 #      exit with an error if the message is spam, and exit normally
 #      otherwise.  Also updates the internal database according to
 #      whether the message is spam or not, allowing the whole system to
 #      run almost without intervention (it only needs to be told about
 #      mistakes.)
 #
 # Return Value:
 #      Does not return
 #
 # Side Effects:
 #      Program exits, writes to log file and updates state file.
 #
 proc aggressiveFilterSpam {{fid stdin}} {
    ## This procedure not only reports via the process exit code
    ## whether the message is spam, but also updates its internal
    ## database accordingly.  Like that, it should be able to maintain
    ## the database in the face of slowly changing spam with
    ## absolutely no user intervention (except in the case of wholly
    ## new classes of spam.)
    global reasons exitCode
    set message [read $fid]
    set flag [isSpam $message]
    extendTable [expr {$flag ? "bad" : "good"}] $message
    log $message "${reasons}: [expr {$flag ? $exitCode(0) : $exitCode(1)}]: added"
    saveTables
    exit $flag
 }

 ###--------------------------------------------------------------------
 ### Init. code
 ###

 #----------------------------------------------------------------------
 # initialize --
 #      Source the configuration file at the global level.  Note that if
 #      the configuration file does not exist, it creates one.  Also
 #      note that the other files mentioned in the created config file
 #      will be based in the same directory as the created config file.
 #
 # Return Value:
 #      Whatever the [source] returns.
 #
 # Side Effects:
 #      Might create directories and files.  Might do other things too,
 #      depending on the contents of the config file.
 #
 proc initialize {} {
    global WordRE ConfigFile
    set WordRE {[-\w'$]+}
    if {![file exists $ConfigFile]} {
       set dir [file dirname $ConfigFile]
       if {![file exists $dir]} {
          file mkdir $dir
       }
       set cfg {### Tcl Spam Filter Configuration File

          ### Where to load and save the tables of word frequencies
          set TableFile @@APPDIR@@/tables.db

          ### Rarely-used word expiry
          set Expiry(Enabled) 1
          # If a word is not entered into the database for a month
          # and a half (measured in seconds) it should be removed.
          set Expiry(Interval) 3888000
          # However, if the word has come up at least this number of
          # times, don't bother.
          set Expiry(InhibitCount) 10

          ### Logging
          set Log(Enabled) 1
          set Log(File)    @@APPDIR@@/decisions.log
          # Log message subjects?
          set Log(Subject) 1
          # Log message senders?
          set Log(Source)  1

          ### Exit codes
          set exitCode(0) spam
          set exitCode(1) non-spam
          set exitCode(2) 2
          set exitCode(3) 3
       }
       set fid [open $ConfigFile w]
       puts $fid [string map [list @@APPDIR@@ $dir] $cfg]
       close $fid
    }
    uplevel #0 {source $ConfigFile}
 }

 #----------------------------------------------------------------------
 # main --
 #      Main app code.  Initializes the system and then runs whatever
 #      command was specified on the command line.  Also handles errors
 #      that arise from that.
 #
 # Return Value:
 #      Not useful, and may exit instead.
 #
 # Side Effects:
 #      Yes!  Lots of them!  ;^)
 #
 proc main {} {
    global argv errorInfo exitCode
    initialize
    loadTables
    if {[catch {[lindex $argv 0]} msg]} {
       set ei $errorInfo
       catch {
          log {} $msg $ei
          exit $exitCode(2)
       }
       # Logging system is stuffed!  :^/
       puts stderr $ei
       puts stderr $errorInfo
       exit $exitCode(3)
    }
 }
 main

 # This program must not be run multiple times simultaneously; when
 # installing it as a mail filter assistant, you *must* provide an
 # adequate level of locking yourself!
