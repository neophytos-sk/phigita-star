#!/usr/bin/python

import sys

from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4.QtWebKit import *


class ConsolePrinter(QObject):
    def __init__(self, parent=None):
        super(ConsolePrinter, self).__init__(parent)
        self.f=open('/tmp/workfile', 'w')

    @pyqtSlot(str)
    def log(self, message):
        print message
        self.f.write(message)
        self.f.write('|')

    def __del__(self):
        self.f.close()

app = QApplication(sys.argv)
web = QWebView()
web.load(QUrl("http://www1.macys.com/shop/mens-clothing/mens-coats?id=3763"))
frame = web.page().mainFrame()

printer = ConsolePrinter()
frame.addToJavaScriptWindowObject("logger", printer);


# web.show()

def loadFinished(ok):
    # print 'loaded'
    frame.evaluateJavaScript("""
    //this is a hack to load an external javascript script 
    //credit to Vincent Robert from http://stackoverflow.com/questions/756382/bookmarklet-wait-until-javascript-is-loaded
    function loadScript(url, callback)
{
        var head = document.getElementsByTagName("head")[0];
        var script = document.createElement("script");
        script.src = url;
        // Attach handlers
        var done = false;
        script.onload = script.onreadystatechange = function()
        {
                if( !done && ( !this.readyState 
                                        || this.readyState == "loaded" 
                                        || this.readyState == "complete") )
                {
                        done = true;
                        // Continue your code
                        callback();
                }
        };

        head.appendChild(script);
}

/**
* Returns true if the given argument is an object. Otherwise, it returns false.
* @param {Mixed} value The value to test
* @return {Boolean}
*/
function am_isObject(v) {
    return !!v && Object.prototype.toString.call(v) === '[object Object]';
}


// If name is specified, returns the current value of that style property
// use style properties, not css attributes (i.e. fontFamily, not font-family)
// If name is an object instead of a string,
// creates a closure that caches the current/computed style properties
// specified in the provided object (i.e. {display:'',position:''} will cache
// those two properties.)
// In this case, it returns a function that
// has the same call signature as am_currentStyle but actually
// ignores the first argument and returns the style property value.
// Uncached properties will still work but slower.
// Note that all this caching is only worthwhile if things are changing
// in between. Otherwise, simple calls are plenty fast.
function am_currentStyle( elem, name ) {

    if (am_isObject(name)) {
        var style = elem.style || {};
        var curStyle = elem.currentStyle;
        // No caching appears to be necessary in IE - already fast.
        if (curStyle) {
            return function(ignore,prop) {
                if (typeof style[prop] != 'undefined' && style[prop] != "") {
                    return style[prop];
                }
                prop = prop.replace("float", "styleFloat");
                return curStyle[prop];
            }
        }
        if (document.defaultView && document.defaultView.getComputedStyle) {
            try {
                var s = document.defaultView.getComputedStyle(elem,"");
                if (s) {
                    // cache specified properties. Copying the entire object is too slow.
                    var computed = {};
                    for (p in name) {
                        computed[p] = s.getPropertyValue(p.replace(/([A-Z])/g,"-$1").toLowerCase());
                    }
                    return function(ignore,prop) {
                        if (typeof style[prop] != 'undefined' && style[prop] != "") {
                            return style[prop];
                        }
                        if (typeof computed[prop] != 'undefined') {
                            return computed[prop];
                        }
                        
                        return s.getPropertyValue(prop.replace(/([A-Z])/g,"-$1").toLowerCase());
                    }
                }
            } catch (err) {
                return function(){return null}
            }
        }
        return function(){return null}
    }

    if (elem.style && elem.style[name]) {

        return elem.style[name];
    } else if (elem.currentStyle) {
            name = name.replace("float", "styleFloat");
            return elem.currentStyle[name];
    } else if (document.defaultView && document.defaultView.getComputedStyle) {
        name = name.replace(/([A-Z])/g,"-$1");
        name = name.toLowerCase();
        try {
            var s = document.defaultView.getComputedStyle(elem,"");
            return s && s.getPropertyValue(name);
        } catch (err) {
            return null;
        }
    } else {
            return null;
    }
}



// returns height of element in px
// optional func parameter takes a style property
// retriever function with same call signature as am_currentStyle
function am_getHeight( elem, func ) {
    func = func || am_currentStyle;
    return parseInt( func( elem, 'height' ) );
}
 
// returns width of element in px 
// optional func parameter takes a style property
// retriever function with same call signature as am_currentStyle
function am_getWidth( elem, func ) {
    func = func || am_currentStyle;
    return parseInt( func( elem, 'width' ) );
} 

// return full width (with borders) of element
// optional func parameter takes a style property
// retriever function with same call signature as am_currentStyle
function am_fullWidth( elem, func ) {
    func = func || am_currentStyle;
    if ( func( elem, 'display' ) != 'none' ) {
        return elem.offsetWidth || am_getWidth( elem, func );
    }
 
    var old = _am_resetCSS( elem, {
        display: '',
        visibility: 'hidden',
        position: 'absolute'
    });
        
    var w = elem.clientWidth || am_getWidth( elem );
 
    _am_restoreCSS( elem, old );
 
    return w;
}


// return full height (with borders) of element
// optional func parameter takes a style property
// retriever function with same call signature as am_currentStyle
function am_fullHeight( elem, func ) {
    func = func || am_currentStyle;
    if ( func( elem, 'display' ) != 'none' ) {
        return elem.offsetHeight || am_getHeight( elem, func );
    }
 
    var old = _am_resetCSS( elem, {
        display: '',
        visibility: 'hidden',
        position: 'absolute'
    });
 
    var h = elem.clientHeight || am_getHeight( elem );
 
    _am_restoreCSS( elem, old );
 
    return h;
}

// helper function to reset css properties of element 
function _am_resetCSS( elem, prop ) {
    var old = {};
 
    for ( var i in prop ) {
        old[ i ] = elem.style[ i ];
        elem.style[ i ] = prop[i];
    }
 
    return old;
}


// helper function to restore css properties of element  
function _am_restoreCSS( elem, prop ) {
    for ( var i in prop ) {
        elem.style[ i ] = prop[ i ];
    }
}

function getInnerText(element,verbose) {

    if (!element) { return ''; }

    if(element.tagName) {
        var tagName = element.tagName.toLowerCase();
        switch(tagName) {
            case 'script':
                return ''; // ignore all script tags
            case 'a':
                if(!element.href) {
                    // ignore A tags w/ no href and all inside
                    return '';
                }
                break;
        }
    }

    if (!am_isRendered(element)) {
        return ''; // element and its subtree are not visible
    }

    if(element.nodeType != 3 && am_currentStyle(element, 'textDecoration') == 'line-through') {
        return '';
    }

    if(element.className && element.className.indexOf('ml-badgecontainer') >= 0) { return ''; }

    var text = '';
    if (element.nodeType == 3) {

        text = element.nodeValue;

        if(text) {

            text = text.replace(/^\s*/, "").replace(/\s*$/, "");
            if(text && text.substr(0,11) == '//<![CDATA[') {
                return '';
        }

        text = text.replace(skipInItemsNamesRegEx,'');
        text = text.replace(skipInItemsNamesSecondPassRegEx,'');
        text = text.replace(/\s{2,}/g, ' ');
        }

        return text;
    }

    var children = element.childNodes;
    if(!children || children.length == 0) { return ''; }

    for (var i = 0; i < children.length; i++) {

        var child = children[i];
        var childText = getInnerText(child,verbose);
        if(childText) {
            text = text + (text ? ' ':'') + childText;
            //if(verbose) console.log('childText[' + childText + ']')
        }
    }

    //if(verbose) console.log('text[' + text + ']')
    return text;
}


var imageProperties = {
        display:'',
        position:'',
        'float':'',
        height:'',
        width:'',
        left:'',
        right:'',
        top:'',
        bottom:'',zIndex:'',
        marginRight:'',
        marginLeft:'',
        marginTop:'',
        marginBottom:''
};

function getImageData(image, limits) {

    var img = { imageElement: image };

    img.currentStyle = am_currentStyle(image, imageProperties);


    img.imageWidth = am_fullWidth(image,img.currentStyle);
    img.imageHeight = am_fullHeight(image,img.currentStyle);

    var top, left;
    var isInsideDocument = true;
    var el = image.parentNode;
    while ((el && el.tagName && el.tagName.toUpperCase() != 'A') && el != document.body) {

        // check that a parent element in between the A tag and us
        // isn't shifting us offscreen - to eliminate carousel type alternate views
        top = parseInt(am_currentStyle(el, 'top'));
        if(top <= -1000) { isInsideDocument = false; break; }

        left = parseInt(am_currentStyle(el, 'left'));
        if(left <= -1000) { isInsideDocument = false; break; }

        el = el.parentNode;
    }

    img.anchorElement = el.tagName && el.tagName.toUpperCase() == 'A' ? el : undefined;
    img.pageUrl = img.anchorElement ? img.anchorElement.href : undefined;
    // var text = img.pageUrl ? getInnerText(img.anchorElement) : undefined;


    //eliminate really short and wide banner type images
    if (limits && isInsideDocument && img.imageHeight * 2 > img.imageWidth) {
        img.isSmallImage = (
                img.imageWidth >= limits.smallMinWidth && img.imageWidth <= limits.smallMaxWidth &&
                img.imageHeight >= limits.smallMinHeight && img.imageHeight <= limits.smallMaxHeight);

        img.isBigImage = (img.isSmallImage ? false :
                (img.imageWidth > limits.smallMinWidth &&
                 img.imageHeight >  limits.smallMinHeight &&
                 img.imageWidth <= limits.bigMaxWidth));
    } else {
        img.isSmallImage = img.isBigImage = false;
    }

    img.isPageItem = img.isSmallImage && img.pageUrl;

    return img;
}


function getInt(str){
    var num = parseInt(str,10);
    return (isNaN(num) ? 0 : num);
}

function am_findStrInArray(str, arr) {
    for (var i = 0; i < arr.length; i++) {
        if (arr[i].toLowerCase() == str.toLowerCase()) {
            return str;
        }
    }
    return null;
}

/*
 * Takes (currently a single) class name
 * and returns an array of elements containing that class
 * Uses high-performance native selector APIs if available
 * but always returns an Array, not a NodeList, etc.
 * @param {String} className
 * @param {HTMLElement} [parent] optionally narrow the search
 *                       to the specified element and its descendants.
 * @return {Array}
 */
function am_getElementsByClassName(className, parent) {
        var useNative = false,
                aElements, aLength,
                elements = [],
                i, el
        ;
        parent = parent || document;

        // Get all elements in a cross-browser way
    if (parent.getElementsByClassName) {
            aElements = parent.getElementsByClassName(className);
            useNative = true;
    } else if (parent.querySelectorAll) {
            aElements = parent.querySelectorAll('.'+className);
            useNative = true;
    } else if (parent.getElementsByTagName) {
            aElements = parent.getElementsByTagName('*');
    } else {
            aElements = parent.all || [];
    }

    aLength = aElements.length;
    
        if (!useNative) {
                for (i=0; i < aLength; i++) {
                        el = aElements[i];

                        if (el.className && am_findStrInArray(className, el.className.split(' '))) {
                                elements.append(el);
                        }
                }
        } else {
                if (parent.className && am_findStrInArray(className, parent.className.split(' '))) {
                        elements.append(parent);
                }
                for (i=0; i < aLength; i++) {
                        elements.append(aElements[i]);
                }
        }

    return elements;
}


function am_getDomElement(elem_or_elemID) {
    if (typeof elem_or_elemID == "string") {
        // support basic jQuery-type selectors
        var firstChar = elem_or_elemID.charAt(0);
        if (firstChar == "#") {
            return document.getElementById(elem_or_elemID.substring(1));
        }
        if (firstChar == ".") {
            return am_getElementsByClassName(elem_or_elemID.substring(1))[0];
        }
        return document.getElementById(elem_or_elemID);
    }
    var element = elem_or_elemID;
    // ExtJs:
    if (element && element.dom && typeof element.dom == "object") {
        return element.dom;
    }
    // jQuery:
    if (element && element.get && typeof element.get == "function") {
        return element.get(0);
    }
    return element;
}

function am_isRendered(elem_or_elemID, arr) {
    var el = am_getDomElement(elem_or_elemID);

    var display = am_currentStyle(el, 'display');

    // New jQuery-inspired high-performance non-recursive method
    // - can only be used for non-inline elements as inline
    // elements could contain block elements (though this is not proper)
    // which in WebKit causes them to have 0 width/height:
    // (see http://bugs.jquery.com/ticket/8564)
    if (!arr) {
        if (display == 'none') {return false;} // Safety check for some IE versions (see http://bugs.jquery.com/ticket/4512)
        if (el.tagName && el.tagName.toUpperCase() == 'INPUT' && el.type == 'hidden') {
            return false;
        }
        if (display != 'inline') {
            if (el.offsetWidth === 0 && el.offsetHeight === 0) {
                return false;
            }
            return true;
        } else {
                // for inline elements, non-zero offsetWidth means it IS visible.
                // but if offsetWidth = 0 then you can't tell if it is visible or not,
                // and you must fall through to the recursive code below to check the parent's visibility.
                if (el.offsetWidth > 0 && el.offsetHeight > 0) {
                        return true;
                }
        }
    }
    
    // Old recursive method - only used if am_showall provided an array to store the ancestor in
    // and for inline elements for which offsetWidth/offsetHeight is not sufficiently accurate.
    var visibility = am_currentStyle(el, 'visibility');
    if (display == 'none' || 
        visibility == 'hidden' ||
        (el.tagName && el.tagName.toUpperCase() == 'INPUT' && el.type == 'hidden')) {
        if (arr) {arr.append(el);}
        return false;
    }
    if (el.parentNode != document) {
        return am_isRendered(el.parentNode, arr);
    }
    return true;
}


var imageLimits = {
   smallMinWidth: 90,
   smallMaxWidth: 299,
   smallMinHeight: 90,
   smallMaxHeight: 399,
   bigMaxWidth: 600
};


var imageElements = document.getElementsByTagName('img');
for (var i=0, len=imageElements.length; i<len; i++) {
    var img = imageElements[i];

    // var rect = img.getBoundingClientRect();
    // var width = (rect && rect.width) || img.offsetWidth || img.clientWidth || getInt(img.width) || img.imageWidth;
    // var height = (rect && rect.height) || img.offsetHeight || img.clientHeight || getInt(img.height) || img.imageHeight;

    var imageData = getImageData(img, imageLimits);

    if(imageData.isPageItem) {
        logger.log(imageData.pageUrl);
    }
 
}


    """) 
    sys.exit(0)

app.connect(web, SIGNAL("loadFinished(bool)"), loadFinished)

sys.exit(app.exec_())
