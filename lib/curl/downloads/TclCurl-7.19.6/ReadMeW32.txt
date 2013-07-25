To install TclCurl in Windows you simply have to double-click on the 'SetUp.tcl'
file, provided you already have Tcl/Tk installed, the script will take care of
everything.

By the way, Tcl's console doesn't seem to like the output sent by TclCurl,
for example, if you type:

curl::transfer -url www.scriptics.com

you will only get an error, you will have to dump it to a file with the
'file' option, read it in to a variable with 'bodyvar', use Cygwin's console
or use tkCon from msys-mingw.


Compiling TclCurl in Windows


First of all a little disclaimer:

I know nothing about Windows programming, no kidding, not a thing,
zip, zilch, nada. I can barely manage using tools, like Tcl/Tk and
gcc, whose origin is in the Unix world, but that is just about it, so
if you think that the following is just plain stupid, that is because
it probably is, but in that case, don't forget to tell me all about it.

To compile TclCurl in Windows you are going to need several things:

    - A msys-mingw enviroment, you can get it at SourceForge:

          http://sourceforge.net/projects/tcl/

      or you can get MinGW and Msys from their project page:

          http://sourceforge.net/projects/mingw/

    - Since you are already at Tcl's page at SF, you can download the
      lastest Tcl version, 8.4.13 at this writing. (These instructions won't
      work with 8.3.x versions)

    - Download zlib from http://www.gzip.org/zlib/

    - Download bc from http://gnuwin32.sourceforge.net/packages/bc.htm and
      install it.

    - Extract Tcl, cURL, zlib and TclCurl in the same directory.

    - Copy the 'tclcurl.mk' file in TclCurl/packages/windows to this directory.

    - Start msys, go to the directory and type:

            $ make -f tclcurl.mk tclcurl-plain

      This command will compile and install Tcl, zlib, cURL and TclCurl, if
      you want to have Tk though, you will have to install it yourself.

      After compiling and installing all the elements, the make file will
      try to create the self-extracting archive using 'rar', if you don't
      have it installed it will fail, but don't worry, everything is already
      installed. If you have rar and you want to create the archives, don't
      forget to change the path at the end of the make file.

    - If you want to use TclCurl with the Tcl/Tk you have installed in 
      c:\Program Files or anywhere else, copy the directory
      '/usr/local/lib/tclcurl0.110' to 'c:\Program Files\Tcl\lib'

    - And now you should have a working TclCurl, run Tcl/Tk and type:

            $ package require TclCurl.

      Tcl should return TclCurl's version, if it doesn't something went wrong,
      could you please tell me?

    - Wish console doesn't really like TclCurl, so if you do:

            $ curl::transfer -url slashdot.org

      It will return a '0' to tell you that the transfer was successful, but it will
      show you nothing, you will have to dump the page into a file to be able to read
      it or use Cygwin's console.



Compiling TclCurl with threads support

You have to do basically the same thing, except that the command to compile is:

    $ make -f tclcurl.mk tclcurl-threaded


Compiling TclCurl with SSL support

To prevent patent trouble, the SSL enabled binaries don't support the idea, rc5 and mdc2
algorithms, if you need them, and you are allowed to do so, you can compile them yourself.


      - First of all you have to compile Openssl, you can get the lastest version
        at http://www.openssl.org, these instructions should work with version 0.9.8e

      - To compile it you are going to need Perl in your system, for whatever the reason
        I couldn't get it to work with the Perl that comes with Cygwin, so I had to
        download ActivePerl: http://www.activestate.com.

      - You will also need to download the MinGW compiler, the compiling scripts don't
        like the msys enviroment though.

      - The open a MS-DOS console in the openssl directory and make sure that both
        perl and mingw are in you path:

            c:\openssl-0.9.8e\> echo %PATH%

        if they aren't add them:

            c:\openssl-0.9.8e\> PATH=%PATH%;C:\Perl\bin;c:\MinGW\bin

        change the paths if you need to.

      - Only thing left is to type in the MS-DOS console:

             c:\openssl-0.9.8e\> ms\mingw32.bat
 
        and hope for the best.

      - After it compiles you have to copy some files around:

        - libcryto.a, libeay32.a, libssl.a and libssl32.a from 
          openssl-0.9.8e\out to c:\msys\local\lib.

        - libeay32.dll and libssl32.dll from openssl-0.9.8e to
          c:\msys\local\lib and c:\msys\local\bin.

        - The contents of openssl-0.9.8e\outinc to c:\msys\local\include.

      - Now copy the 'tclcurl.mk' file from TclCurl/packages/windows to
        the directory in which you have TclCurl, Tcl, cURL, TclCurl and OpenSSL.

        - $ make -f tclcurl.mk tclcurl-ssl

      - If you want to have threads support:

        - $ make -f tclcurl.mk tclcurl-threaded-ssl        

Sounds like a lot of work to run a little extension, but then again, you could
have downloaded the self-extracting archive file.


Share the wonders,
Andres
fandom@telefonica.net



