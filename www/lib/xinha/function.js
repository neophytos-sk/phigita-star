Function.prototype.extend = function(Construct, prototype) {
  var Base = this, Extended = function() {
    Base.apply(this, arguments);
    Construct.apply(this, arguments);
  };	
  Extended.prototype = new Base();
  Extended.implement(prototype);
  return Extended;
}
Function.prototype.implement = function(face) {	
  for(var i in face){ this.prototype[i] = face[i]; }; 
}