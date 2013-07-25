/*
 * Claude Vervoort - December 2011 - claude.vervoort@gmail.com
 * Thanks to Sebastian Thurn and Peter Norvig and Stanford for
 * the Introduction to AI online course - ai-class.com 
 * Feel free to use and abuse this code at will :)
 */
 
 /*
  * Some wiring between UI and logic
  */
  
var toggleRobotMove = function( robot )
{
  if ( robot.moving )
  {
    robot.stop( );
    $('stop').update( 'Resume' );
  }
  else
  {
    robot.moving = true;    
    robot.moveCycle( );
    $('stop').update( 'Pause' );
  }
}

var toggleMoveTrace = function( filter )
{
  if ( filter.moveCanvas.style.opacity =="0" )
  {
    filter.moveCanvas.style.opacity = ".5";
    $('moveTrace').update( 'Hide   Debug Move Trace' );
  }
  else
  {
    filter.moveCanvas.style.opacity = "0";
    $('moveTrace').update( 'Show Debug Move Trace' );
  }
}

var startProbing = function( filter )
{
  //$('numParticles').disabled = true;
  //$('startProbing').addClassName( 'disabled' );
  //$('startProbing').disabled = true;
  filter.robot.startProbing( );
}

// Well, a sigmoid function, tried to use it to compute correlation
var sigmoid = function( t )
{
  return 1 / ( 1 + Math.exp( -t ) );
}  

/*
 Particle Filter main class, initiates the Canvases, spawn particles and Robot
 There are 4 canvases layed ontop one of another:
 - pfcanvas: where the background image is displayed
 - particle_canvas: where the particles are drawn
 - robot_canvas: where the robot is drawn
 - move_canvas (hidden): keeps a trace of the robot to lower probability to backtrac when picking random move
 
 A note on units: x and y are normalized, ranging from 0-1, and using filter.width and filter.height to translate
 to pixel coordinates
 */
var particleFilter = function( imageSrc )
{
  this.canvas = $( 'pfcanvas' );
  this.particlesCanvas = $( 'particles_canvas' );
  this.robotCanvas = $( 'robot_canvas' );
  this.moveCanvas = $( 'move_canvas' );
  this.canvasContext = this.canvas.getContext('2d');
  this.particlesContext = this.particlesCanvas.getContext('2d');
  this.robotContext = this.robotCanvas.getContext('2d');
  this.moveContext = this.moveCanvas.getContext('2d');
  this.img = new Image();  
  this.img.onload = this.init.bind( this );
  this.img.src = imageSrc ;
}

particleFilter.prototype = 
{
  init: function( )
  {
    // init all canvases so that they are of the proper size and properly aligned one ontop of another
    this.height = this.canvas.height = this.particlesCanvas.height = this.robotCanvas.height = this.moveCanvas.height = this.img.height;
    this.width = this.canvas.width = this.particlesCanvas.width = this.robotCanvas.width = this.moveCanvas.width = this.img.width;
    this.ratioHeightWidth = this.width / this.height;
    this.particles = [ ];
    this.stepX = 1 / this.width;
    this.stepY = 1 / this.height;
    this.ratio = {x: ( 1 / this.width ), y: ( 1 / this.height ) };
    this.particlesCanvas.style.top = this.canvas.offsetTop + "px";
    this.particlesCanvas.style.left = this.canvas.offsetLeft + "px";
    this.robotCanvas.style.top = this.canvas.offsetTop + "px";
    this.robotCanvas.style.left = this.canvas.offsetLeft + "px";
    this.moveCanvas.style.top = this.canvas.offsetTop + "px";
    this.moveCanvas.style.left = this.canvas.offsetLeft + "px";
    this.canvasContext.drawImage( this.img, 0, 0 );
    this.imageData = this.canvasContext.getImageData( 0, 0, this.width, this.height );
    this.particlesImageData = this.particlesContext.createImageData( this.width, this.height );
    // create a robot in a random position and start moving
    this.robot = new particleFilter.robot( this );
    this.robot.randomPosition( );
    this.robot.startMoving( );
  },
   
  // called when the robot starts probing, which involve spwaning particle and making a first observation
  initProbing: function( )
  {
    this.numParticles = Number( $('numParticles').value );
    this.spawnParticles( );
    this.robot.observe( );
    this.update( );
    this.draw( );
  },
  
  /*
   * Called by the robot, delta representing the move change since the last probing
   */
  probe: function( delta )
  {
    this.robot.observe( );
    this.update( delta );
    this.draw( );  
  },
  
  // initial random draw of particles
  spawnParticles: function( )
  {
    var particles = this.particles;
    for ( var i = 0, max = this.numParticles; i < max; )
    {
      var particle = new particleFilter.particle( this );
      particle.randomPosition( );
      if ( particle.isOnClearSpace( ) )
      {
        particles.push( particle );
        ++i;
      }
    }
    // now we share the probability equally across particles
    var weight = 1 / particles.length;
    for ( var i = 0, len = particles.length; i < len; ++i )
    {
      particle.weight = weight;
      particle.cumulWeight = ( i + 1 )/ particles.length;
    }
  },
  
  // draw the current state of particles
  draw: function( )
  {
    var particles = this.particles;
    this.particlesImageData = this.particlesContext.createImageData( this.width, this.height );
    var imageData = this.particlesImageData;
   // this.particlesContext.clearRect( 0, 0 , this.width, this.height );
    //var imageData = this.canvasContext.getImageData( 0, 0, this.width, this.height );
    for ( var i = 0, len = particles.length; i < len; ++i )
    {
      var offset = ( particles[ i ].ypx * this.particlesImageData.width  + particles[ i ].xpx ) * 4;
      // multiple points can be in the same pixel, in which case grow its intensity
      var color = ( 1 - particles[ i ].weight ) * 255 + imageData.data[ offset + 3 ];
      if ( color > 255 ) color = 255;
      imageData.data[ offset ] = 255;  // RED        
      imageData.data[ offset + 3 ] = color;
    }
    this.particlesContext.putImageData( imageData, 0, 0 );
  },
  
  // CORE FILTER function, that is where the logic of the filter
  // applies, spawning new set of particles based on prior probability
  // No delta means this is the 1st evaluation based on the just spawned particles
  update: function( delta )
  {
    var particles = this.particles;
    var newParticles = [];
    var totalWeight = 0;
    var robot = this.robot;
    var minWeight = 1; // 1 is full match
    var maxWeight = 0;
    for ( var i = 0, len = particles.length; i < len; ++i )
    {
      // pick particle pick one of the existing particle using its current weight
      var particle = delta?this.pickParticle( ):particles[ i ];
      if ( delta )
      {
        var randomizedDelta = this.randomizeMove( delta );
        particle.move( randomizedDelta );
        while ( !particle.isOnClearSpace( ) )
        {
          particle = this.pickParticle( );
          particle.move( randomizedDelta );          
        }
      }
      particle.observe( );
      particle.weight = particle.observation.correlation( robot.observation );
      if ( particle.weight < minWeight )
      {
        // new particle found that least matches the robot observation
        minWeight = particle.weight;
      }
      if ( particle.weight > maxWeight )
      {
        maxWeight = particle.weight;
      }
      totalWeight += particle.weight;
      newParticles.push( particle );
    }
    var cumulWeight = 0;
    // useful to evaluate how correlation creates differentiation: console.log( "min:"  + minWeight + " avg: " + totalWeight/particles.length + " max: " + maxWeight );
    // minWeight is used to scale weights from 0 to <1.
    totalWeight = totalWeight - ( particles.length * minWeight );
    for ( var i = 0, len = particles.length; i < len; ++i )
    {
      newParticles[ i ].weight = ( newParticles[ i ].weight - minWeight ) / totalWeight;
      cumulWeight+=newParticles[ i ].weight;
      newParticles[ i ].cumulWeight = cumulWeight;
    }
    this.particles = newParticles;
  },
  
  pickParticle: function( )
  {
    var low = 0;
    var up = this.particles.length-1;
    var ran = Math.random( );
    while ( true )
    {
      var pickedIndex = Math.floor( ( low + up ) / 2 );
      var particle = this.particles[ pickedIndex ] ;
      if ( particle.cumulWeight > ran )
      {
        up = pickedIndex;
      }
      else
      {
        low = pickedIndex;
      }
      if ( up == low )
      {
        return particle.clone( );
      }
      if ( ( up - low ) == 1 )
      {
        return this.particles[ up ].clone( );
      }      
    }
  },
  
  // clear space meaning all components less than 50, do not care about A
  isClearSpace: function( x, y )
  {
    if ( this.isOnCanvas( x, y ) )
    {
      var offset = ( y * this.imageData.width  + x ) * 4; // 4->RGBA
      return this.imageData.data[ offset ] > 50 && this.imageData.data[ offset + 2 ] > 50 
            && this.imageData.data[ offset + 4 ] > 50;
    }
    return false;
  },
  
  isOnCanvas: function( x, y )
  {
    return !( x < 0 || y < 0 || x >= particleFilter.width || y >= particleFilter.height );
  },
  
  toOffset: function( xpx, ypx )
  {
    return ( ypx * this.width  + xpx ) * 4;
  },
  
  randomizeMove: function( move )
  {
    // randomize move by +/-80% 
    return { x: this.randomize( move.x, 0.8 ), y: this.randomize( move.y, 0.8  ) };
  },
  
  randomize: function( x, maxDeltaRatio )
  {
    return x * ( 1 - maxDeltaRatio * 2 * ( Math.random( ) - 0.5 ) );
  }
};


/*
 * OBSERVATION
 * Observation of the environment, used by particles and robot
 * Correlation is used to compute how much an observation matches another one.
 */
 
particleFilter.observation = function( filter, xpx, ypx )
{
  this.distances = [];
  this.distances[ 0 ] = this.getClosestWallDistance( filter, xpx, ypx, 0,  -1 );
  this.distances[ 1 ] = this.getClosestWallDistance( filter, xpx, ypx, 0,   1 );
  this.distances[ 2 ] = this.getClosestWallDistance( filter, xpx, ypx, 1,   0 );
  this.distances[ 3 ] = this.getClosestWallDistance( filter, xpx, ypx, -1,  0 );
  // Here are observations based on diagonal, did not actuallt improve result
  //this.distances[ 4 ] = this.getClosestWallDistance( filter, xpx, ypx, -1,  -1 );
  //this.distances[ 5 ] = this.getClosestWallDistance( filter, xpx, ypx, -1,   1 );
  //this.distances[ 6 ] = this.getClosestWallDistance( filter, xpx, ypx, 1,   -1 );
  //this.distances[ 7 ] = this.getClosestWallDistance( filter, xpx, ypx, 1,  1 );
};

particleFilter.observation.prototype = 
{
  getClosestWallDistance: function( filter, xpx, ypx, incXpx, incYpx )
  {
    var currentXpx = xpx;
    var currentYpx = ypx;
    while ( true )
    {
      currentXpx += incXpx;
      currentYpx += incYpx;
      intXpx = Math.floor( currentXpx );
      intYpx = Math.floor( currentYpx );
      if ( !filter.isClearSpace( intXpx, intYpx ) )
      {
        break;
      }
    }
    return Math.sqrt( Math.pow( ( currentXpx - xpx ) / filter.width, 2 ) +   Math.pow( ( currentYpx - ypx ) / filter.height , 2 ) );
  },

  // Here are a few different correlation methods I tried, only correlation is called. Rename to switch to another one.
  // Finding a good correlation I have found was the most challenging part of this exercise.
  
  // uses the worse difference between the observations 
  correlationMin: function( observation )
  {
    var diff = 0;
    for ( var i = 0, len = this.distances.length; i < len; ++i )
    {
      var diffTemp = Math.pow( (this.distances[ i ] - observation.distances[ i ]) * 20, 2 );
      if ( diffTemp > diff ) diff = diffTemp;
    }
    return 1 - diff;
  },
  
  // Linear: average of delta across observed dimensions
  correlation: function( observation )
  {
    var diff = 0;
    for ( var i = 0, len = this.distances.length; i < len; ++i )
    {
      diff += Math.abs( (this.distances[ i ] - observation.distances[ i ]) / ( this.distances[ i ] + observation.distances[ i ] ) );
    }
    return 1 - diff/this.distances.length;
  },
  
  // Squarred error on each observed dimensions, dropping worse
  correlationPow: function( observation )
  {
    var diff = 0;
    var maxDiff = 0;
    for ( var i = 0, len = this.distances.length; i < len; ++i )
    {
        var tempDiff = Math.pow( (this.distances[ i ] - observation.distances[ i ]) , 2 );
        if ( tempDiff > maxDiff )
        {
          maxDiff = tempDiff;
        }
        diff+=tempDiff;
    }
    diff-=maxDiff;
    return 1 - diff/(this.distances.length-1);
  },
  
  // Squarred of the total of error
  correlationPowDropLowest: function( observation )
  {
    var diff = 0;
    var maxDiff = 0;
    for ( var i = 0, len = this.distances.length; i < len; ++i )
    {
        var tempDiff = Math.abs( (this.distances[ i ] - observation.distances[ i ]) );
        if ( tempDiff > maxDiff )
        {
          maxDiff = tempDiff;
        }
        diff+=tempDiff;
    }
    diff-=maxDiff;
    return 1 - Math.pow( diff, 3 )/(this.distances.length-1);
  },
  
  // Using a sigmoid as to lower the impact of wide delta
  correlationoSigmoid: function( observation )
  {
    var diff = 0;
    for ( var i = 0, len = this.distances.length; i < len; ++i )
    {
        diff+=Math.abs( sigmoid( (this.distances[ i ] - observation.distances[ i ]) * 5 ) );
    }
    return 1 - diff/this.distances.length;
  }
  
};


/* PARTICLE
 */
particleFilter.particle = function( filter )
{
  this.weight = 0;
  this.filter = filter;
};

particleFilter.particle.prototype = 
{
  
  setPosition: function( x, y )
  {
    this.x = x;
    this.y = y;
    this.xpx = Math.floor( this.x * this.filter.width );
    this.ypx = Math.floor( this.y * this.filter.height );  
  },
  
  randomPosition: function( )
  {
    this.setPosition( Math.random( ), Math.random( ) );  
  },
  
  move: function( delta )
  {
    this.setPosition( this.x + delta.x, this.y + delta.y );   
  },
  
  observe: function( )
  {
    this.observation = new particleFilter.observation( this.filter, this.xpx, this.ypx );  
  },
  
  isOnClearSpace: function( )
  {
    return this.filter.isClearSpace( this.xpx, this.ypx );
  },
  
  clone: function( )
  {
    var particle = new particleFilter.particle( );
    particle.id = this.id;
    particle.filter = this.filter;
    particle.x = this.x;
    particle.y = this.y;
    particle.observation = this.observation;
    return particle;
  }
};

/* ROBOT
 * To avoid complete random move (where the robot would wander around
 * its initial spawning position), a trace is drawn on the move canvas
 * and is used to compute the odd of picking a next pixel.
 * The trace also fades away so that eventuallt the user can backtrack.
 */
particleFilter.robot = function( filter )
{
  this.filter = filter;
  this.probesteps = 0;
  this.moveCounter = 0;
  this.xpx=0;
  this.ypx=0;
  this.x=0;
  this.y=0;
  this.lastProbeX=0;
  this.lastProbeY=0;
};

particleFilter.robot.prototype = 
{

  // same as particle
  
  setPosition: particleFilter.particle.prototype.setPosition,
  
  randomPosition: particleFilter.particle.prototype.randomPosition,
  
  isOnClearSpace: particleFilter.particle.prototype.isOnClearSpace,
  
  startMoving: function( )
  {
    this.initMoveMap( );
    this.moving = true;
    this.delay = 0.1;
    this.moveCycle( );
  },
  
  randomPosition: function( )
  {
    this.setPosition( Math.random( ), Math.random( ) );
    while( !this.isOnClearSpace( ) )
    {
      this.setPosition( Math.random( ), Math.random( ) );
    }
  },
  
  startProbing: function( )
  {
    this.filter.initProbing( );
    this.syncLastProbe( );
    this.probeSteps = Number( $('steps').value );
  },
  
  // used to compute the move delta across probing
  syncLastProbe: function( )
  {
    this.lastProbeX=this.x;
    this.lastProbeY=this.y;
  },
  
  stop: function( )
  {
    this.moving = false;
  },
  
  moveCycle: function( )
  {
    this.moveOnePixel( );
    this.draw( );
    if ( this.probeSteps > 0 ) 
    {
      this.moveCounter++;
      if ( this.moveCounter % this.probeSteps == 0 )
      {
        this.drawCross( 30 );
        this.filter.probe( {x:( this.x - this.lastProbeX ), y:( this.y - this.lastProbeY ) } );
        this.syncLastProbe( );
      }
    }
    if ( this.moving )
    {
      this.moveCycle.bind( this ).delay( this.delay ); 
    }
  },
  
  observe: function( )
  {
    this.observation = new particleFilter.observation( this.filter, this.xpx, this.ypx );  
  },
  
  initMoveMap: function( )
  {
    this.filter.moveContext.fillStyle = "rgba(255, 255, 255, 1)";  
    this.filter.moveContext.fillRect( 0, 0, this.filter.width, this.filter.height );
  },
  
  incMoveLikelyhood: function( )
  {
    this.filter.moveContext.fillStyle = "rgba(2, 2, 2, 1)";  
    this.filter.moveContext.globalCompositeOperation = "lighter";
    this.filter.moveContext.fillRect( 0, 0, this.filter.width, this.filter.height );
  },
  
  moveOnePixel: function( )
  {
    this.incMoveLikelyhood( );
    var pixelProb = [];
    var totalProb = 0;
    var image = this.filter.moveContext.getImageData( 0, 0, this.filter.width, this.filter.height );
    var imageData = image.data;
    for ( var i = 0; i < 9; ++i )
    {
      var prob = 0;
      var move = this.toPixelMove( i );
      var col = i % 3 - 1;
      if ( this.filter.isClearSpace( this.xpx + move.x, this.ypx + move.y ) &&  5 != i )
      {
        var offset = this.filter.toOffset( this.xpx + move.x, this.ypx + move.y );
        prob = imageData[ offset ];
      }
      pixelProb[ i ] = prob;
      totalProb+=prob;
    }
    this.lowerSurroundingProb( imageData, 1, 100 );
    this.lowerSurroundingProb( imageData, 2, 60 );
    this.filter.moveContext.putImageData( image, 0, 0 );
    // pick next move
    var nextMoveDraw = Math.random( ) * totalProb;
    var currentCumul = 0;
    var nextMoveIndex = -1;
    for ( var i = 0; i < 9; ++i )      
    {
      if ( pixelProb[ i ] > 0 )
      {
        nextMoveIndex = i;
        currentCumul+=pixelProb[ i ];
        if ( currentCumul >= nextMoveDraw )
        {
          break;
        }
      }
    }
    if ( nextMoveIndex == -1 ) alert( "-1" );
    // now we move to pixel designated by i
    var move = this.toPixelMove( nextMoveIndex );
    this.xpx += move.x;
    this.ypx += move.y;
    this.x = this.xpx / this.filter.width;
    this.y = this.ypx / this.filter.height;
  },
  
  toPixelMove: function( i )
  {
    return { 
      x: (Math.floor( i / 3 ) - 1), 
      y: (i % 3) - 1
      };
  },
  
  draw: function( )
  {
    // improvement: clear only around robot
    this.filter.robotContext.clearRect( 0, 0 , this.filter.width-1, this.filter.height-1 );
    this.drawCross( 2 );
  },
  
  drawCross: function( radius )
  {
    var context = this.filter.robotContext;
    context.strokeStyle = "rgba(55,65,235,1)";
    context.lineWidth=1;
    context.beginPath( );
    context.moveTo( (this.xpx-radius<0)?0:this.xpx-radius, this.ypx );
    context.lineTo( ((this.xpx+radius)<this.filter.width)?(this.xpx+radius):this.xpx, this.ypx );
    context.stroke( );
    context.closePath( );
    context.beginPath( );
    context.moveTo( this.xpx, (this.ypx-radius<0)?0:this.ypx-radius );
    context.lineTo( this.xpx, ( (this.ypx+radius)<this.filter.height)?this.ypx+radius:this.ypx );
    context.stroke( );
    context.closePath( );
  },
  
  lowerSurroundingProb: function( imageData, radius, decrease )
  {
    for ( var x = 0; x < ( 2 * radius + 1 ); ++x )
    {
      for ( var y = 0; y < ( 2 * radius + 1 ); ++y )
      {
        if ( this.filter.isOnCanvas( this.xpx + x - radius, this.ypx + y - radius) )
        {
          var offset = this.filter.toOffset( this.xpx + x - radius, this.ypx + y - radius );
          var newProb = imageData[ offset ] - decrease;
          newProb = (newProb < 0)?0:newProb;
          imageData[ offset ] = newProb;
          imageData[ offset + 1 ] = newProb;
          imageData[ offset + 2 ] = newProb;
        }
      }
    }
  }
}


