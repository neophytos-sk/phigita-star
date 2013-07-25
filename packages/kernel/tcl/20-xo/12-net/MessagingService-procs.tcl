namespace eval ::xo::net {;}

Class ::xo::net::MessagingService

# Send a message to a given endpoint.
# @param message message to be sent.
# @param to endpoint to which the message needs to be sent
# @return an reference to an IAsyncResult which can be queried for the
# response
::xo::net::MessagingService instproc sendRR {message to cb} {}
