// mutex.js 

function Map() { 
  this.map  = new Object(); 
  // Map API 
  this.add      = function(k,o){ this.map[k] = o;    } 
  this.remove   = function( k ){ delete this.map[k]; } 
  this.get      = function( k ){ return k==null ? null : this.map[k]; } 
  this.first    = function(   ){ return this.get( this.nextKey( ) ); } 
  this.next     = function( k ){ return this.get( this.nextKey(k) ); } 
  this.nextKey  = function( k ){ for (i in this.map) { 
                                   if (!k) return i; 
                                   if (k==i) k=null; /*tricky*/ 
                                 } 
                                 return null; 
                               } 
} 

function Mutex( cmdObject, methodName ) { 
  // define static variable and method 
  if (!Mutex.Wait) Mutex.Wait = new Map(); 
  Mutex.SLICE = function( cmdID, startID ) { 
    Mutex.Wait.get(cmdID).attempt( Mutex.Wait.get(startID) ); 
  } 
  // define instance method 
  this.attempt = function( start ) { 
    for (var j=start; j; j=Mutex.Wait.next(j.c.id)) { 
      if (j.enter || (j.number && (j.number < this.number || 
           (j.number == this.number && j.c.id < this.c.id) ) ) ) 
       return setTimeout("Mutex.SLICE("+this.c.id+","+j.c.id+")",10); 
    } 
    this.c[ this.methodID ](); //run with exclusive access 
    this.number = 0;           //release exclusive access 
    Mutex.Wait.remove( this.c.id ); 
  } 
  // constructor logic 
  this.c        = cmdObject; 
  this.methodID = methodName; 
  Mutex.Wait.add( this.c.id, this ); //enter and number are “false” 
  this.enter    = true; 
  this.number   = (new Date()).getTime(); 
  this.enter    = false; 
  this.attempt( Mutex.Wait.first() ); 
} 
