ka-Map - README.TXT
===================

ka-Map ("ka" as in  ka-boom!) is an open source javascript API for 
developing highly interactive web-mapping interfaces using features
available in modern web browsers.

For more information about the project and to get the latest release,
please visit the project webpage at:

    http://ka-map.maptools.org/



COPYRIGHT AND LICENSE TERMS:
----------------------------

ka-Map is covered by the following open source license:

 **********************************************************************
 * Copyright (c) 2005, DM Solutions Group Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 * DEALINGS IN THE SOFTWARE.
 **********************************************************************



INSTALLATION INSTRUCTIONS:
--------------------------

The current version of ka-Map requires MapServer's PHP MapScript on the
server. MapServer version 4.4.x will work, but better results will be 
obtained with MapServer 4.6 or more recent (not released yet as I'm
writing this). 

If you do not have a working MapServer environment then you may want to
look at the following precompiled packages:

- For Windows, MS4W at http://maptools.org/ms4w/
- For Linux, FGS at http://maptools.org/fgs/

The rest of those instructions assume that you have a working PHP MapScript,
accessible as php_mapscript_46.so. We use the GMap demo as an example here,
but any MapServer mapfile can be used.

1- Download and install the GMap demo data and mapfile. It may have come
   preinstalled with your MS4W or FGS, if not then you can get the source
   package from http://maptools.org/dl/gmap-ms40.zip

   From now on we'll assume the gmap75.map mapfile is located at 
     /opt/fgs/apps/gmap-ms40/htdocs/gmap75.map

2- Copy the contents of the ka-map/htdocs directory and sub-directories 
   to your web server's htdocs.
     cp -r ka-map/htdocs/ /opt/fgs/www/htdocs/ka-map/

   Note: there are cleaner ways to install packages in FGS and MS4W that 
         will be documented later.

3- Edit ka-Map's config.php to configure your installation for your local
   settings. All configurable parameters are documented in the file.
   Things to watch for:
    - Make sure the $szPHPMapScriptModule and $szPHPGDModule filenames match
      your installation
    - Make sure the path to the gmap75.map mapfile is right in the $aszMapFiles
      array.
    - Make sure $szBaseCacheDir points to a valid directory on your system
      to hold the tile cache. 

4- ka-Map should be ready to use at  http://your.server.name/ka-map/



--------------
$Id: README.TXT,v 1.4 2005/05/18 21:39:18 daniel Exp $
--------------
