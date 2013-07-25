#!/usr/bin/perl -w

#------------------------------------------------------------------------
#  server_wrapper.pl: so you were too lazy to write networking code, huh?
#
#  well, you're in luck.  this script provides a skeleton to turn any 
#  program into a server, provided it writes to STDOUT.
#
#  by Paul Morie
#  4/7/2004
#------------------------------------------------------------------------

use Socket;
use Carp;
use FileHandle;

# set up arguments.

my ($port, $invocation) = @ARGV;

defined($port) || die "supply a port";
defined($invocation) || die "supply an invocation";

my $proto = getprotobyname('tcp');

socket(Server, AF_INET, SOCK_STREAM, $proto) or die "socket: $!";
setsockopt(Server, SOL_SOCKET, SO_REUSEADDR, 1) or die "setsockopt: $!";
bind(Server, sockaddr_in($port, INADDR_ANY)) or die "bind: $!";
listen(Server, SOMAXCONN) or die "listen: $!";

my $waitedpid = 0;
my $paddr;

sub REAPER {
  $waitedpid = wait;
  $SIG{CHLD} = \&REAPER;
}

$SIG{CHLD} = \&REAPER;

$int_msg = "Interrupted system call";

INFINITE: while (1) {
  while (!($paddr = accept(Client, Server))) {
    last INFINITE unless $! eq $int_msg;
  }

  my ($port, $iaddr) = sockaddr_in($paddr);
  my $name = gethostbyaddr($iaddr, AF_INET);

  spawn(Client, $invocation);

  close Client;
}

sub spawn {
  my ($clientSocket, $invoke) = @_;

  die "spawn: no client socket!" unless $clientSocket;
  die "spawn: no invocatione!" unless $invoke;

  my $pid;

  if (!defined($pid = fork)) {
    die "can't fork!";
  } elsif ($pid) {
    return $pid;  # this is the parent
  }

  # now we're guaranteed to be in the child.

  $param="";
  $param = ReceiveFrom($clientSocket);  
  $inputfile = "Serverinput.tmp$$";
  open (INPUT, ">$inputfile")||die "couldn't creat input file";
  print INPUT $param;
  close(INPUT);
  my $message = `$invoke $inputfile`;
  unlink $inputfile;

  $message =~ s/\[ENTA/\[PER/g;
  $message =~ s/\[ENTB/\[LOC/g;
  $message =~ s/\[ENTC/\[ORG/g;
  $message =~ s/\[ENTD/\[MISC/g;
 # print $message;
  #$message = "Proc\n.Stuff\n";
  # the data is in $message.
  # don't touch this part.
  send($clientSocket, $message, 0) ||die "ServerSend: $!";
  #send $clientSocket, pack("N", length $message), 0;
  #send($clientSocket, $message, 0) if length($message) > 0;

  exit;
}

sub ReceiveFrom {
  my $sock = $_[0];
  my ($length, $msg, $message, $received);

  $done=0;
  while($done==0)
	{
	  $line =<$sock>;
	  if(!defined($line)) {$done=1;}
	  if($line eq "-END-\n") {$done=1;}
	  else {$message .= $line;}
	}
  #print $message;
  return $message;
}

