#!/usr/bin/perl

use IO::Socket;


open(file, "$ARGV[0]") || die "coulndt open file";

$data="";
while($line = <file>)
{
	$data .= $line;
}
my $port = 4200;
my $proto = getprotobyname("tcp");
my $iaddr = inet_aton("localhost");
my $paddr = sockaddr_in($port, $iaddr);
socket(SOCKET, PF_INET, SOCK_STREAM, $proto) || die "socket: $!";
connect(SOCKET, $paddr) || die "connect: $!";

send(SOCKET, $data, 0);
my $end = "-END-\n";
send(SOCKET, $end, 0);
my $tagged = "";



$tagged = ReceiveFrom(SOCKET);
$line = "";$ok=1;
print $tagged;
close SOCKET or die;              

sub ReceiveFrom#($socket)
{
  my($socket) = $_[0];
  my($length, $char, $msg, $message, $received);

  $received = 0;
  $message = "";
  while ($received < 4)
  {
    recv $socket, $msg, 4 - $received, 0;
    $received += length $msg;
    $message .= $msg;
  }
  $length = unpack("N", $message);

  $received = 0;
  $message = "";
  while ($received < $length)
  {
    recv $socket, $msg, $length - $received, 0;
    $received += length $msg;
    $message .= $msg;
  }

  return $message;
}

