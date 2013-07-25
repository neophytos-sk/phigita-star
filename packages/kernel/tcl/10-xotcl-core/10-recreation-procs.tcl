ad_library {
  Support for the recreation of classes objects without
  destroying foreign references. Normally, when a class
  definition is reloaded, the class is destroyed and created
  again with the same name. During the destruction of a class
  several references to this class are removed (e.g. in a
  class hierarchy, the relation from instances to this class, etc.).
  XOTcl provides support for altering this behavior through 
  the recreate method.

  @author Gustaf Neumann (neumann@wu-wien.ac.at)
  @creation-date 2005-05-13
  @cvs-id $Id: 10-recreation-procs.tcl,v 1.7 2006/01/26 01:23:51 gustafn Exp $
}

if {![::xotcl::Object isclass ::xotcl::RecreationClass]} {
  ::xotcl::Class create ::xotcl::RecreationClass -ad_doc {
    <p>This meta-class controlls the behavior of classes (and optionally
    their instances), when the classes (or their instances) are	
    overwritten by same named new objects; we call this situation
    a recreate of an object.</p>
					     
    <p>Normally, when files with e.g. class definitions are sourced,
    the classes and objects are newly defined. When e.g. class 
    definitions exists already in this file, these classes are 
    deleted first before they are newly created. When a class is 
    deleted, the instances of this class are changed into 
    instances of class ::xotcl::Object. </p>

    <p>This can be a problem when the class instances are not 
    reloaded and when they should survife the redefintion with the
    same class relationships. Therefore we define a 
    meta class RecreationClass, which can be used to parameterize 
    the behavior on redefinitions. Alternatively, Classes or objects
    could provide their own recreate methods.</p>

    <p>Per default, this meta-class handles only the class redefintion
    case and does only a reconfigure on the class object (in order
    to get e.g. ad_doc updated).</p>
    The following parameters are defined:
    <ul>
    <li><b>reconfigure:</b> reconfigure class (default 1)
    <li><b>reinit:</b> run init after configure for this class (default unset)
    <li><b>instrecreate:</b> handle recreate of class instances (default unset)
      When this flag is set to 0, instreconfigure and instreinit are ignored.
    <li><b>instreconfigure:</b> reconfigure instances of this class (default 1)
    <li><b>instreinit:</b> re-init instances of this class (default unset)
    </ul>
  } -parameter {
    {reconfigure 1}
    {reinit}
    {instrecreate}
    {instreconfigure 1}
    {instreinit}
  } -superclass ::xotcl::Class \
      -instproc recreate {obj args} {
	#my log "### recreateclass instproc $obj <$args>"
	# the minimal reconfiguration is to set the class and remove methods
	$obj class [self]
	foreach p [$obj info procs] {$obj proc $p {} {}}
	if {![my exists instrecreate]} {
	  #my log "### no instrecreate for $obj <$args>"
	  next
	  return
	}
	if {[my exists instreconfigure]} {
	  # before we set defaults, we must unset vars
	  foreach var [$obj info vars] {$obj unset $var}
	  set pcl [my info parameterclass]
	  # set defaults and run configure
	  $pcl searchDefaults $obj
	  eval $obj configure $args
	  #my log "### instproc recreate $obj + configure $args ..."
	}
	if {[my exists instreinit]} {
	  #my log "### instreinit for $obj <$args>"
	  eval $obj init 
	  #my log "### instproc recreate $obj + init ..."
	}
      } -proc recreate {obj args} {
	#my log "### recreateclass proc $obj <$args>"
	# the minimal reconfiguration is to set the class and remove methods
	$obj class [self]
	foreach p [$obj info instprocs] {$obj instproc $p {} {}}
	if {[my exists reconfigure]} {
	  # before we set defaults, we must unset vars
	  foreach var [$obj info vars] {$obj unset $var}
	  set pcl [my info parameterclass]
	  $pcl searchDefaults $obj
	  # set defaults and run configure
	  eval $obj configure $args
	}
	if {[my exists reinit]} {
	  eval $obj init 
	}
      }

  ::Serializer exportObjects {
    ::xotcl::RecreationClass 
  }
}

set version [package require XOTcl]
if {[string match "1.3.*" $version]} {
  Class ad_proc recreate {obj args} { 
    The re-definition of recreate makes reloading of class definitions via 
    apm possible, since the foreign keys of the class relations 
    to these classes survive these calls. One can define specialized
    versions of this for certain classes or use ::xotcl::RecreationClass.

    Class proc recreate is called on the class level, while 
    Class instproc recreate is called on the instance level.

    @param obj name of the object to be recreated
    @param args arguments passed to recreate (might contain parameters)
  } {
    # clean on the class level
    #my log "proc recreate $obj $args"
    foreach p [$obj info instprocs] {$obj instproc $p {} {}}
    $obj instmixin set {}
    $obj instfilter set {}
    next ; # clean next on object level
  }
  Class ad_instproc recreate {obj args} { 
    The re-definition of recreate makes reloading of class definitions via 
    apm possible, since the foreign keys of the class relations 
    to these classes survive these calls. One can define specialized
    versions of this for certain classes or use ::xotcl::RecreationClass.

    Class proc recreate is called on the class level, while 
    Class instproc recreate is called on the instance level.

    @param obj name of the object to be recreated
    @param args arguments passed to recreate (might contain parameters)
  } {
    # clean on the object level
    #my log "+++ instproc recreate $obj <$args> old class = [$obj info class], new class = [self]"
    $obj filter set {}
    $obj mixin set {}
    set cl [self] 
    foreach p [$obj info commands] {$obj proc $p {} {}}
    foreach c [$obj info children] {
      my log "recreate destroy <$c destroy"
      $c destroy
    }
    foreach var [$obj info vars] {
      $obj unset $var
    }
    # set p new values
    $obj class $cl 
    set pcl [$cl info parameterclass]
    $pcl searchDefaults $obj
    # we use uplevel to handle -volatile correctly
    set pos [my uplevel $obj configure $args]
    if {[lsearch -exact $args -init] == -1} {
      incr pos -1
      eval $obj init [lrange $args 0 $pos]
    }
  }

  #::xotcl::Object instforward unset -objscope 
  #  ::xotcl::Object instforward unset
  ::Serializer exportMethods {
    ::xotcl::Class instproc recreate
    ::xotcl::Class proc recreate
    ::xotcl::Object instforward unset
  }
} else {
  ns_log notice "-- softrecreate"
  ::xotcl::configure softrecreate true

  Class RR -instproc recreate args { 
    my log "-- [self args]"; next
  } -instproc create args { 
    my log "-- [self args]"; next
  }
  #::xotcl::Class instmixin RR
}