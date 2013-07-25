#!/usr/bin/perl -w

# Perl Script for using Fex Server

use IO::Socket;

sub Connect
{
  my($port) = @_;
  my($sock);
  $sock = new IO::Socket::INET(
     PeerAddr =>'localhost',
     #PeerAddr =>'snow-white.cs.uiuc.edu',
     PeerPort =>$port,
     Proto    =>'tcp',);
  die "Can't connect to $port: Reason: $!\n" unless $sock;
  return $sock;
}


$sock = Connect(7676);

$count=20;

while(<>) {
  # print one line of the corpus
  print $sock $_;
  # read ack
  recv $sock, $example, $count, 0;
  #print $example . "\n";
}

# send signal to generate examples
print $sock "###\@\@\@--Generate Example!";

recv $sock, $example, $count, 0;
print $example;
while ($example !~ /:$/) {
  recv $sock, $example, $count, 0;
  print $example;
}

# Tell the pos server we're done.
#send $sock, pack("N", 0), 0;
close $sock;

