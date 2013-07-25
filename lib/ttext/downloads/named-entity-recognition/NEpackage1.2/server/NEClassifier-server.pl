#!/usr/bin/perl


# this version accepts bracket-tagged input
# and an option whether to output the associated features "-sendfeatures"
use IO::Socket;

my $DEBUG_NE = 1;

if($#ARGV != 3)
  {
    die "Usage: ./NEClassifier-server.pl <list_port> <fex_port> <snow_port> <inputfile>";
  }

$list_port = $ARGV[0];
$fex_port = $ARGV[1];
$snow_port = $ARGV[2];
$input = $ARGV[3];
$dir="/home/nkd/my/experiments/NEpackage1.2";
$sentbound="$dir/tmp/sentbound.tmp$$";
$wordsplit = "$dir/tmp/wordsplit.tmp$$";
$columninput = "$dir/tmp/columninput.tmp$$";
$classout = "$dir/tmp/classout.tmp$$";
$finalcolumn = "$dir/tmp/finalcolumn.tmp$$";
$INFERENCEDIR = "$dir/cscl";
$TARGETLEXICON = "$dir/labelsFromLexicon.txt";
#$ACTIVEENTITIES = "$dir/activeEntitie";

$LISTCOLIFY = "$dir/newlistne/makelistscolumn.pl";
#listne related files
$listoutput = "$dir/tmp/listoutput.tmp$$";
$listcolumn = "$dir/tmp/listcolumn.tmp$$";
$colone = "$dir/tmp/colone.tmp$$";
$colrest = "$dir/tmp/colrest.tmp$$";

#print "Processed stuff: **$ARGV[0]***\n";
#$input = $ARGV[0];
#preprocess and put into table format
`$dir/sentence-boundary/sentence-boundary.pl -d $dir/sentence-boundary/HONORIFICS -i $input -o - > $sentbound`;
`$dir/wordsplitter/word-splitter.pl $sentbound > $wordsplit`;

#create vanilla column format with tags (no pos, no chunking, etc.. since NE doesnt use it)
open(SOURCE2, "$wordsplit") || die "couldn't load wordsplit data";
open(COLUMN, ">$columninput") || die "couldn't create column file";


if(1 == $DEBUG_NE) {

  print "##word splitting/pos tagging...\n";
}

$col="";
$numwords=0;
while($line = <SOURCE2>)
  {
    #escape preceding newlines
    if($numwords==0 && $line =~ /^\s*\n$/)
    {next;}

    #escape the slash
    $line =~ s/^\//\\\//g;
    $line =~ s/[^\\]\// \\\//g;

    #convert word splitter's LBR/RBR back to (/)
    $line =~ s/\-LBR\-/\(/g;
    $line =~ s/\-RBR\-/\)/g;

    @wordarr = split(/\s+/, $line);
    $wordcounter=0;
    $inNE=0;
    $prefix="";

    for($i=0;$i<=$#wordarr;$i++) #inNE: 0=outside 1=begin 2=end 3=inside
      {
	if($inNE==0) {$label="O";}
	if($wordarr[$i] =~ /^xNESTARTx/)
	  {
	    $wordarr[$i] =~ s/^xNESTARTx//g;
	    $label = $wordarr[$i];
	    $inNE=1;
	  }
	elsif($wordarr[$i] eq "xNEENDx")
	  {
	    $inNE=2;
	    $label="O";
	  }
	else
	  {
	    $prefix="";
	    if($inNE==0) {$prefix="";}
	    if($inNE==1 && ($wordarr[$i+1] ne "xNEENDx")) {$prefix="B-";}
	    elsif($inNE==1 && ($wordarr[$i+1] eq "xNEENDx")) {$prefix="U-";}
	    if($inNE==2) {$prefix="";}
	    if($inNE==3) {$prefix="I-";}
	    if($inNE==3 && ($wordarr[$i+1] eq "xNEENDx")) {$prefix="L-";}
	
	    $word = $wordarr[$i];
	    $col .= "$prefix$label\t0\t$wordcounter\tO\tO\t$word\tx\tx\t0\n";
	    #print "$prefix$label\t0\t$wordcounter\tO\t$tags[$i]\t$word\tx\tx\t0\n";
	    $wordcounter++;
	    $numwords++;
	    if($inNE==1) {$inNE=3;}
	  }
      }
    $col .= "\n";
  }
$col =~ s/\n*$//g;
$col =~ s/\n\n\n+/\n\n/g;

if(1 == $DEBUG_NE) {

  print "##done with word splitting/pos tagging... printing column format to $columninput...\n";
}

#print $col;
print COLUMN $col;
close(COLUMN);

#print "done with column/pos tagging\n";


if(1 == $DEBUG_NE) {

  print "##calling list ne tagger... writing output to $listoutput...\n";
}

#call list ne tagger
open(WORDSPLIT, "$wordsplit")||die "couldnt open word split file";
open(LISTOUTPUT, ">$listoutput")||die "couldnt open list file for write";
$line="";
while($line = <WORDSPLIT>)
{
  $wsplit .= $line;
}
my $port = $list_port;


if(1 == $DEBUG_NE) {

  print "##my port is $port.\n";
}

my $proto = getprotobyname("tcp");
my $iaddr = inet_aton("localhost");

if(1 == $DEBUG_NE) {

  print "##my iaddr is $iaddr.\n";
}

my $paddr = sockaddr_in($port, $iaddr);
socket(SOCKET, PF_INET, SOCK_STREAM, $proto) || die "socket: $!";
connect(SOCKET, $paddr) || die "connect: $!";

binmode SOCKET;

if(1 == $DEBUG_NE) {

  print "##connected to socket...\n";
}


$listout="";
send(SOCKET, $wsplit, 0);

if(1 == $DEBUG_NE) {

  print "##sent wsplit to socket...\n";
}

my $end = "-END-\n";
send(SOCKET, $end, 0);

if(1 == $DEBUG_NE) {

  print "##sent -END- to socket.... receiving from socket...\n";
}

my $tagged = "";
#while (<SOCKET>) { $listout .= $_;}
$listout = ReceiveFrom(SOCKET);

print LISTOUTPUT $listout;
close(LISTOUTPUT);

if(1 == $DEBUG_NE) {

  print "##done with list ne tagger... writing column output to $listcolumn...\n";
}


`$LISTCOLIFY $listoutput > $listcolumn`;
`cut -f1 $columninput > $colone`;
`cut -f3- $columninput > $colrest`;
`rm $columninput`;
`paste $colone $listcolumn $colrest > $columninput`; 

# classify and infer...
#`$FEX -p fex_noLabels.scr BILOU.lex $columninput $columninput.ex`;
#connect to fex server

if(1 == $DEBUG_NE) {

  print "##connecting to fex on $fex_port...\n";
}


$sock = Connect($fex_port, "localhost");

# send each sentence to fex separately
open(COLUMN, "$columninput") || die "couldnt open column file";
$col="";
while ($line = <COLUMN>) {$col .= $line;}
@fexinputs = split(/\n\s*\n/, $col);
foreach $fexinput(@fexinputs)
{
	$fexinput =~ s/^\n//g;

if(1 == $DEBUG_NE) {

  print "\n\n##calling fex with: \n$fexinput...\n";
  my $len = length $fexinput;
  print "## length of fex input is $len...\n";

}



	send $sock, pack("N", length $fexinput), 0;
	#print $sock length $fexinput;
	print $sock $fexinput;
	push @examples, split (/\n/, ReceiveFrom($sock));
	#print $fexinput;
#	print @examples;
}

send $sock, pack("N", 0), 0;
close $sock;

if(1 == $DEBUG_NE) {
  print "##called fex successfully.  Doing more stuff./n";
}

map { $_ .= "\n"} @examples;

if($numwords != ($#examples+1)) # fex screwed up...
  {
    print "ERROR:Feature Extraction error! Request terminated.\n";
    print "$numwords $#examples";
    exit 0;
  }

# give the examples to the snow server
$params= "-i - -o allactivations";
$snow_socket = Connect($snow_port, "localhost");
send $snow_socket, pack("N", length $params), 0;
print $snow_socket $params;
$message = ReceiveFrom($snow_socket);

#open IN, "$columninput.ex" or die "Can't open $columninput.ex for input: $!\n";
$input="";
foreach $ex(@examples)
{
  $input .= $ex;
}

# Send examples:
send $snow_socket, pack("N", length $input), 0;
print $snow_socket $input;
# Receive the server's classification information:
$message = ReceiveFrom($snow_socket);

#print "down with snow\n";
open OUT, ">$classout" ||die "cant open OUT for write";
print OUT $message;
close OUT;
# Last, tell the server that this client is done.
send $snow_socket, pack("N", 0), 0;

#$active_labels="";
#map { $active_labels .= $_ . " ";} @activearr;
`$INFERENCEDIR/DoInfrBILOUGeneral2.pl $columninput $classout $TARGETLEXICON $finalcolumn PER LOC ORG MISC`;
open(FINALCOL, "$finalcolumn") ||die "could not open $finalcolumn";

#print "output...\n";
seek(SOURCE2,0,0);
while($line = <SOURCE2>)
  {
    #print "in output..\n";
    @wordarr = split(/\s+/, $line);
    $inNE=0;
    foreach $word(@wordarr)
      {
	if(($word !~ /xNESTARTx/) && ($word !~ /xNEENDx/) )
	  {
	    #add brackets
	    if($word eq "-LBR-") { $word = "(";}
	    if($word eq "-RBR-") { $word = ")";}
	    $label = <FINALCOL>;
	    if($label !~ /[A-Z]/) {$label = <FINALCOL>;}
	    if($word =~ /^\-[LR]BR\-$/) {$label="O";}
	    if($label =~ /^[BU]/)
	      {
		if($label =~ /^B/) 
		  {
		    $inNE=1;
		    $label =~ /[A-Z][A-Z]+/;
		    print "[$& $word ";
		  }
		else
		  {
		    $inNE=0;
		    $label =~ /[A-Z][A-Z]+/;
		    print "[$& $word ] ";
		  }
	      }
	    elsif($label =~ /^L/)
	      {
		print "$word ] ";
		$inNE=0;
	      }
	    elsif( ($label =~ /^O/) && ($inNE==1))
	      {
		print "] $word ";$inNE=0;
	      }
	    else { print "$word ";}
	    
	    #	print "$word\t$label";
	  }
	# print "\n";
      }
  }
print "\n";

unlink($sentbound, $wordsplit, $classout, $finalcolumn, $columninput, $listoutput, $listcolumn, $colone, $colrest);


sub Connect#($port, $server_name)
{
  my($port) = $_[0];
  my($server_name) = $_[1];
  my($socket); 
  $socket = new IO::Socket::INET(
     PeerAddr => $server_name,
     PeerPort => $port,
     Proto    => 'tcp',); 
  die "Can't connect to $port: $!\n" unless $socket;
  return $socket;
} 



sub ReceiveFrom#($socket)
{
  my($socket) = $_[0];
  my($length, $char, $msg, $message, $received);

  $received = 0;
  $message = "";

  binmode $socket;

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
