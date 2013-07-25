#!/usr/bin/python
import re
import socket
import stat
import os
import time
import DNS
import cgi

DNS.ParseResolvConf()
def bulkCheck(RemoteServerIP, RemotePort):
    parsedExitList = "/tmp/TorBulkCheck/parsed-exit-list"
    cacheFile = parsedExitList + "-" + RemoteServerIP +\
        "_" + RemotePort + ".cache"
    confirmedExits = []

    # Do we have a fresh exit cache?
    maxListAge = 1600
    try:
        cacheStat = os.stat(cacheFile)
        listAge = checkListAge(cacheFile)
    except OSError:
        cacheStat = None

    # Without a fresh exit cache for the given ServerIP
    # We'll generate one
    if cacheStat is None or listAge > maxListAge:

        # We're not reading from the cache
        # Lets build a query list and cache the results
        exits = open(parsedExitList, 'r')
        possibleExits = exits.readlines()

        # Check exiting to Tor, build a list of each positive reply and return
        # the list
        for possibleExit in possibleExits:
            try:
                if (isUsingTor(possibleExit, RemoteServerIP, RemotePort) == 0 ):
                    confirmedExits.append(possibleExit)
            except:
                return None

        confirmedExits.sort()

        # We didn't have a cache, we'll truncate any file in its place
        cachedExitList = open(cacheFile, 'w')
        for exitToCache in confirmedExits:
            cachedExitList.write(exitToCache)

        cachedExitList.close()

        return confirmedExits

    else:
        # Lets return the cache
        cachedExits = open(cacheFile, 'r')
        cachedExitList = cachedExits.readlines()
        return cachedExitList

def getRawList():
    """
    Eventually, this will use urllib to fetch a real url.
    In theory, this function fetches a raw exit list from a given url if the
    current unparsed exit list is older than a given threshold. Currently
    this simply uses a static file from the file system. It returns a path to
    an unparsed exit list as produced by the DNS Exit List software.
    """

    # Someday, do a real http get request here
    # read into buffer, return buffer RawExitList with contents.
    # follow instructions from http://docs.python.org/lib/module-urllib.html
    # RawExitListURL = "http://exitlist.torproject.org/exitAddresses"

    # Currently fake this and return a static file:
    RawExitList = '/srv/tordnsel.torproject.org/srv/tordnsel.torproject.org/state/exit-addresses'

    return RawExitList

def updateCache():
    """
    When this function returns, if there is no error, a parsed exit node cache
    file exists. These are all of the nodes that may allow exiting. This is
    useful for building tests for given exits.
    """

    maxListAge = 1600
    parsedListDirPath = "/tmp/TorBulkCheck/"
    parsedExitList = "/tmp/TorBulkCheck/parsed-exit-list"

    try: 
        parsedListDir = os.stat(parsedListDirPath)

    except (OSError, IOError):
        os.mkdir(parsedListDirPath)
        parsedListDir = os.stat(parsedListDirPath)

    try:
        # They may be a directory and so this would all fail.
        # It may be better to check to see if this is a file.
        parsedListStat = os.stat(parsedExitList)
    except OSError:
        parsedListStat = None

    listAge = checkListAge(parsedExitList)

    # If we lack a parsed list, perhaps we have a raw list?
    if parsedListStat is None or listAge > maxListAge:
        RawExitList = getRawList()
        RawList = os.stat(RawExitList)
        possibleExits = parseRawExitList(RawExitList)

        parsedList = open(parsedExitList, 'w')
        parsedList.write("\n".join(possibleExits))
        parsedList.close()

def checkListAge(list):
    """
    Check the age of the list in seconds.
    """

    try:
        listStatus = os.stat(list)
        now = time.time()
        listCreationTime = os.stat(list).st_ctime
        listAge = now - listCreationTime
    except OSError:
        listAge = None

    return listAge

def parseRawExitList(RawExitList):
    exitAddresses = open(RawExitList)
    possibleExits = []

    # We'll only match IP addresses of Exit Nodes
    search = re.compile('(^ExitAddress\ )([0-9.]*)\ ')
    lines = exitAddresses.readlines()
    for line in lines:
         match = search.match(line)
         if match:
             possibleExits.append(match.group(2))

    possibleExits.sort()
    return possibleExits


def isUsingTor(clientIp, ELTarget = "38.229.70.31", ELPort = "80"):

    ELExitNode = ".".join(reversed(clientIp.strip().split('.')))
    ELTarget = ".".join(reversed(ELTarget.strip().split('.')))

    # This is the ExitList DNS server we want to query
    ELHost = "ip-port.exitlist.torproject.org"

    # Prepare the question as an A record request
    ELQuestion = ELExitNode + "." + ELPort + "." + ELTarget + "." + ELHost
    request = DNS.DnsRequest(name=ELQuestion,qtype='A')

    # Increase time out length
    #answer=request.timeout = 30
    # Ask the question and load the data into our answer
    answer=request.req()

    # Parse the answer and decide if it's allowing exits
    # 127.0.0.2 is an exit and NXDOMAIN is not
    if answer.header['status'] == "NXDOMAIN":
        # We're not exiting from a Tor exit
        return 1
    else:
        if not answer.answers:
            # We're getting unexpected data - fail closed
            return 2
        for a in answer.answers:
            # if 127.0.0.2 is in the answer section,
            # then exits are allowed from "clientIp" to "ELTarget:ELPort"
            if a['data'] == "127.0.0.2":
                return 0
        # If we're here, the DNS exit list gave us a non-exit answer
        # that we don't understand. Return a failure code.
        return 2

def parseAddress(formSubmission):
    # Get the ip from apache
    user_supplied_ip = None
    user_supplied_ip = formSubmission.getfirst("ip", None)

    # Check the IP, fail with a None
    # We may want to clean this up with a regex only allowing [0-9.]
    if user_supplied_ip is not None:
        try:
            parsed_ip = socket.inet_ntoa(socket.inet_aton(user_supplied_ip))
        except socket.error:
            return None
    else:
        return None

    return parsed_ip 

def parsePort(formSubmission):
    # Get the port from apache
    user_supplied_port = None
    user_supplied_port = formSubmission.getfirst("port", "80")

    # Verify that the port is a number between 1 and 65535
    # Otherwise return a sane default of 80
    search = re.compile("^(?:[1-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|"+\
                            "65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$")

    if search.match(user_supplied_port):
        parsed_port = user_supplied_port
    else:
        parsed_port = "80"

    return parsed_port
    
def handler(req, environ, start_response):
    formSubmission = cgi.FieldStorage(fp=environ['wsgi.input'], environ=environ)

    RemoteServerIP = parseAddress(formSubmission)
    RemotePort = parsePort(formSubmission)
    
    if RemoteServerIP is not None:
        response_headers = [('Content-type', 'text/plain; charset=utf-8')]
        start_response('200 OK', response_headers)

        updateCache()
        TestedExits = bulkCheck(RemoteServerIP, RemotePort)
        req.write("# This is a list of all Tor exit nodes that can contact " + RemoteServerIP + 
        " on Port " + RemotePort + " #\n")

        querystring = "ip=%s" % RemoteServerIP
        if RemotePort != "80":
            querystring += "&port=%s" % RemotePort

        req.write("# You can update this list by visiting " + \
        "https://check.torproject.org/cgi-bin/TorBulkExitList.py?%s #\n" % querystring)

        dateOfAccess = time.asctime(time.gmtime())
        req.write("# This file was generated on %s UTC #\n" % dateOfAccess)

        for exit in TestedExits:
            req.write(str(exit))

        return
    else:
        response_headers = [('Content-type', 'text/html; charset=utf-8')]
        start_response('200 OK', response_headers)

        req.write('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" '\
        '"http://www.w3.org/TR/REC-html40/loose.dtd">\n')
        req.write('<html>\n')
        req.write('<head>\n')
        req.write('<meta http-equiv="content-type" content="text/html; '\
        'charset=utf-8">\n')
        req.write('<title>Bulk Tor Exit Exporter</title>\n')
        req.write('<link rel="shortcut icon" type="image/x-icon" '\
        'href="./favicon.ico">\n')
        req.write('<style type="text/css">\n')
        req.write('img,acronym {\n')
        req.write('  border: 0;')
        req.write('  text-decoration: none;')
        req.write('}')
        req.write('</style>')
        req.write('</head>\n')
        req.write('<body>\n')
        req.write('<center>\n')
        req.write('\n')
        req.write('<br>\n');

        req.write('\n')

        req.write('<img alt="' + ("Tor icon") + \
        '" src="/images/tor-on.png">\n<br>')
        req.write('<br>\n<br>\n')
       
        req.write('Welcome to the Tor Bulk Exit List exporting tool.<br><br>\n')
        req.write("""
        If you are a service provider and you wish to build a list of possible
        Tor nodes that might contact one of your servers, enter that single server
        address below. Giving you the whole list means you can query the list
        privately, rather than telling us your users' IP addresses.
        This list allows you to have a nearly real time authoritative source for Tor
        exits that allow contacting your server on port 80. While we don't log
        the IP address that queries for a given list, we do keep a cache of answers for
        all queries made. This is purely for performance reasons and they are
        automatically deleted after a given threshold. If you'd like, you're
        free to run your own copy of this program. It's Free Software and can
        be downloaded from the <a
        href="https://svn.torproject.org/svn/check/trunk/cgi-bin/TorBulkExitList.py">Tor
        subversion repository</a>.<br><br>\n""")

        req.write('Please enter an IP address:<br>\n')
        req.write('<form action="/cgi-bin/TorBulkExitList.py" name="ip">\n')
        req.write('<input type="text" name="ip"><br>\n')
        req.write('<input type="submit" value="Submit">')
        req.write('</form>')

        req.write('</center>\n')
        req.write('</body>')
        req.write('</html>')

class FakeReq(list):
    def write(self, str):
        self.append(str)

def application(environ, start_response):
    req = FakeReq()
    handler(req, environ, start_response)
    return req

# vim:set ts=4:
# vim:set et:
# vim:set shiftwidth=4:
