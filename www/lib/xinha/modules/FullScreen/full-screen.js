




// FullScreen -------------------------------------------------------------------------------------------------------------------------------------------------



/** fullScreen makes an editor take up the full window space (and resizes when the browser is resized)
 *  the principle is the same as the "popupwindow" functionality in the original htmlArea, except
 *  this one doesn't popup a window (it just uses to positioning hackery) so it's much more reliable
 *  and much faster to switch between
 */

Xinha.prototype._fullScreen = function()
{

  var e = this;
  function sizeItUp()
  {
    if(!e._isFullScreen || e._sizing) return false;
    e._sizing = true;
    // Width & Height of window
    var dim = Xinha.viewportSize();

    e.sizeEditor(dim.x + 'px',dim.y + 'px',true,true);
    e._sizing = false;
  }

  function sizeItDown()
  {
    if(e._isFullScreen || e._sizing) return false;
    e._sizing = true;
    e.initSize();
    e._sizing = false;
  }

  /** It's not possible to reliably get scroll events, particularly when we are hiding the scrollbars
   *   so we just reset the scroll ever so often while in fullscreen mode
   */
  function resetScroll()
  {
    if(e._isFullScreen)
    {
      window.scroll(0,0);
      window.setTimeout(resetScroll,150);
    }
  }

  if(typeof this._isFullScreen == 'undefined')
  {
    this._isFullScreen = false;
    if(e.target != e._iframe)
    {
      Xinha._addEvent(window, 'resize', sizeItUp);
    }
  }



	_xo_target = this._editMode == 'textmode' ? 'textarea' : 'iframe';
	e.setCC(_xo_target);


  // Gecko has a bug where if you change position/display on a
  // designMode iframe that designMode dies.
  if(Xinha.is_gecko)
  {
    this.deactivateEditor();
  }

  if(this._isFullScreen)
  {
    // Unmaximize
    this._xo_htmlarea().style.position = '';
    try
    {
      if(Xinha.is_ie)
      {
        var bod = document.getElementsByTagName('html');
      }
      else
      {
        var bod = document.getElementsByTagName('body');
      }
      bod[0].style.overflow='';
    }
    catch(e)
    {
      // Nutthin
    }
    this._isFullScreen = false;
    sizeItDown();

    // Restore all ancestor positions
    var ancestor = this._xo_htmlarea();
    while((ancestor = ancestor.parentNode) && ancestor.style)
    {
      ancestor.style.position = ancestor._xinha_fullScreenOldPosition;
      ancestor._xinha_fullScreenOldPosition = null;
    }

    window.scroll(this._unScroll.x, this._unScroll.y);
  }
  else
  {

    // Get the current Scroll Positions
    this._unScroll =
    {
     x:(window.pageXOffset)?(window.pageXOffset):(document.documentElement)?document.documentElement.scrollLeft:document.body.scrollLeft,
     y:(window.pageYOffset)?(window.pageYOffset):(document.documentElement)?document.documentElement.scrollTop:document.body.scrollTop
    };


    // Make all ancestors position = static
    var ancestor = this._xo_htmlarea();
    while((ancestor = ancestor.parentNode) && ancestor.style)
    {
      ancestor._xinha_fullScreenOldPosition = ancestor.style.position;
      ancestor.style.position = 'static';
    }

    // Maximize
    window.scroll(0,0);
    this._xo_htmlarea().style.position = 'absolute';
    this._xo_htmlarea().style.zIndex   = 999;
    this._xo_htmlarea().style.left     = 0;
    this._xo_htmlarea().style.top      = 0;
    this._isFullScreen = true;
    resetScroll();

    try
    {
      if(Xinha.is_ie)
      {
        var bod = document.getElementsByTagName('html');
      }
      else
      {
        var bod = document.getElementsByTagName('body');
      }
      bod[0].style.overflow='hidden';
    }
    catch(e)
    {
      // Nutthin
    }

    sizeItUp();
  }

  if(Xinha.is_gecko)
  {
    this.activateEditor();
  }
  this.focusEditor();
  e.findCC(_xo_target);
};