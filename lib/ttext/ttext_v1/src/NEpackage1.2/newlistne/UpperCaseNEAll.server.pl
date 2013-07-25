#!/usr/bin/perl

#
#   @(#)ne-tagger2.pl	1.16       03/11/02
#

#########################################################
# Mapping ----Number should be same as NE_Mapping class No.
# Name--------Begining ----- Inside ---
# DayFest ----220 ---------- 221
# Event ------230 ---------- 231
# Perform ----240 ---------- 241
# LangRace ---270 ---------- 271
# Animal -----310 ---------- 311
# Peop -------320 ---------- 321
# Plant ------360 ---------- 361
# OrgCorp ----370 ---------- 371
# OrgCGroup --380 ---------- 381
# OrgUniv ----400 ---------- 401
# OrgTeam ----410 ---------- 411
# OrgPolBody -420 ---------- 421
# ProfTitle --460 ---------- 461
# Color ------600 ---------- 601
# Book -------610 ---------- 611
# Jour -------620 ---------- 621
# Sport ------630 ---------- 631
# Medical ----640 ---------- 641
# Food -------660 ---------- 661
# LocCit -----820 ---------- 821
# LocCoun ----830 ---------- 831
# LocStruct --840 ---------- 841
# LocMount ---850 ---------- 851
# LocRiver ---870 ---------- 871
# LocStat ----880 ---------- 881
# Num --------900 ---------- 901
# NumUnit ----910 ---------- 911
# NumZip -----920 ---------- 921
# NumPhone ---930 ---------- 931
# NumTime ----950 ---------- 951
# Date -------960 ---------- 961
# Money ------1000 --------- 1001
# NumPercent -1020 --------- 1021
# Org --------3000 --------- 3001
# Loc --------8000 --------- 8001
#---------------------------------------
# unmapped
# Art --------690 ---------- 691
# Religion ---10  ---------- 11
##########################################################

use utf8;
use IO::Socket;
use Socket;
use Carp;
use FileHandle;
use threads;
use threads::shared;

if (@ARGV < 1)
{
  print "usage: nameEntity-tagger.pl <port> \n";
  exit;
}

my $port = $ARGV[0];

defined($port) || die "supply a port";

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


$dir="/home/nkd/my/experiments/NEpackage1.2";
$list_path="$dir/newlistne/lists";
open (Currency, "$list_path/currencyFinal.txt")|| die "Can't open currency file.";
open (Plant,"$list_path/flower.txt") || die "Can't open flower file";
open (Loc, "$list_path/Loc.txt") || die "Can't open Loc file";
open (Colors, "$list_path/colors.txt") || die "Can't open color file";
open (Medical, "$list_path/medical.txt") || die "Can't open medical file";
open (Number, "$list_path/number.txt") || die "Can't open number file";
open (Event, "$list_path/event.txt") || die "Can't open event file";
open (Performance, "$list_path/performance.txt") || die "Can't open performance file";
open (CreatGroup, "$list_path/creativegroup") || die "Can't open creative group file";
open (Rivers, "$list_path/rivers.txt") || die "Can't open river file";
open (Mountains, "$list_path/mountains.txt") || die "Can't open mountain file";
open (ProfTitles, "$list_path/prof-title.txt") || die "Can't open prof/title file";
open (Units, "$list_path/measurments.txt") || die "Can't open measurments file";
open (PolBodies, "$list_path/polparties.txt") || die "Can't open POL Parties file";
open (Buildings, "$list_path/BuildingFinal.txt") || die "Can't open Bulding file";
open (FestDays, "$list_path/FestDays.txt") || die "Can't open FestDay file";
open (Artworks, "$list_path/artworkFinal.txt") || die "Can't open Art file";
open (Books , "$list_path/bookFinal.txt") || die "Can't open book file";
open (Cities, "$list_path/cityFinal.txt") || die "Can't open city file";
open (Animals, "$list_path/combinAnimalFinal.txt")|| die "Can't open animal file";
open (Countries, "$list_path/countriesFinal.txt") || die "Can't open country file";
open (Days, "$list_path/days.txt")|| die "Can't open days file";
open (Foods, "$list_path/foodFinal.txt")|| die "Can't open food file";
open (Journals , "$list_path/journalFinal.txt")|| die "Can't open journal file";
open (Lang, "$list_path/langFinal.txt")|| die "Can't open lang file";
open (Months, "$list_path/months.txt")|| die "Can't open months file";
open (People, "$list_path/peopleAll.txt")|| die "Can't open people file";
open (Religions, "$list_path/religions.txt")|| die "Can't open religion file";
open (States, "$list_path/states.txt")|| die "Can't open states file";
open (Teams, "$list_path/teams.txt")|| die "Can't open teams file";
open (Universities, "$list_path/uFinal.txt")|| die "Can't open uFinal file";
open (Corporations , "$list_path/corpFinal.txt") || die "Can't open Corp  file";
open (Sports, "$list_path/sports.txt") || die"Can't open sport file";

#uppercased version

my %sportHash : shared = {};
my %currencyHash : shared = {};
my %plantHash : shared = {};
my %locHash : shared = {};
my %colorHash : shared = {};
my %medicalHash : shared = {};
my %numberHash : shared = {};
my %eventHash : shared = {};
my %performHash : shared = {};
my %creatgroupHash : shared = {};
my %riverHash : shared = {};
my %mountHash : shared = {};
my %profHash : shared = {};
my %unitHash : shared = {};
my %polBodyHash : shared = {};
my %peopleHash : shared = {};
my %religionHash : shared = {};
my %stateHash : shared = {};
my %corporationHash : shared = {};
my %countryHash : shared = {};
my %dayHash : shared = {};
my %foodHash : shared = {};
my %journalHash : shared = {};
my %dateHash : shared = {};
my %buildingHash : shared = {};
my %festdayHash : shared = {};
my %artworkHash : shared = {};
my %bookHash : shared = {};
my %cityHash : shared = {};
my %animalHash : shared = {};
my %universityHash : shared = {};


#---------------------------------------------------------------
while(<Sports>){
  chomp($_);
  s/\s*$//;
  $sportHash{uc($_)}=1;
}

while(<Currency>){
  chomp($_);
  s/\s*$//;
  $currencyHash{uc($_)}=1;
}

while(<Plant>){
  chomp($_);
  s/\s*$//;
  $plantHash{uc($_)}=1;
}

while(<Loc>){
  chomp($_);
  s/\s*$//;
  $locHash{uc($_)}=1;
}

while(<Colors>){
  chomp($_);
  s/\s*$//;
  $colorHash{uc($_)}=1;
}

while(<Medical>){
  chomp($_);
  s/\s*$//;
  $medicalHash{uc($_)}=1;
}

while(<Number>){
  chomp($_);
  s/\s*$//;
  $numberHash{uc($_)}=1;
}

while(<Event>){
  chomp($_);
  s/\s*$//;
  $eventHash{uc($_)}=1;
}

while(<Performance>){
  chomp($_);
  s/\s*$//;
  $performHash{uc($_)}=1;
}

while(<CreatGroup>){
  chomp($_);
  s/\s*$//;
  $creatgroupHash{uc($_)}=1;
}

while(<Rivers>){
  chomp($_);
  s/\s*$//;
  $riverHash{uc($_)}=1;
}

while(<Mountains>){
  chomp($_);
  s/\s*$//;
  $mountHash{uc($_)}=1;
}

while(<ProfTitles>){
  chomp($_);
  s/\s*$//;
  $profHash{uc($_)}=1;
}

while(<Units>){
  chomp($_);
  s/\s*$//;
  $unitHash{uc($_)}=1;
}

while(<PolBodies>){
  chomp($_);
  s/\s*$//;
  $polBodyHash{uc($_)}=1;
}

while(<People>){
  chomp($_);
  s/\s*$//;
  $peopleHash{uc($_)}=1;
}

while(<Religions>){
  chomp($_);
  s/\s*$//;
  $religionHash{uc($_)}=1;
}

while(<States>){
  chomp($_);
  s/\s*$//;
  $stateHash{uc($_)}=1;
}
while(<Teams>){
  chomp($_);
  s/\s*$//;
  $teamHash{uc($_)}=1;
}

while(<Corporations>){
  chomp($_);
  s/\s*$//;
  $corporationHash{uc($_)}=1;
}

while(<Countries>){
  chomp($_);
  s/\s*$//;
  $countryHash{uc($_)}=1;
}

while(<Days>){
  chomp($_);
  s/\s*$//;
  $dayHash{uc($_)}=1;
}

while(<Foods>){
  chomp($_);
  s/\s*$//;
  $foodHash{uc($_)}=1;
}

while(<Journals>){
  chomp($_);
  s/\s*$//;
  $journalHash{uc($_)}=1;
}
while(<Lang>){
  chomp($_);
  s/\s*$//;
  $langHash{uc($_)}=1;
}

while(<Months>){
  chomp($_);
  s/\s*$//;
  $dateHash{uc($_)}=1;
}

while(<Buildings>){
  chomp($_);
  s/\s*$//;
  $buildingHash{uc($_)}=1; # place in hash.
}

while(<FestDays>){
  chomp($_);
  s/\s*$//;
  $festdayHash{uc($_)}=1;
}


while(<Artworks>){
  chomp($_);
  s/\s*$//;
  $artworkHash{uc($_)}=1;
}

while(<Books>){
  chomp($_);
  s/\s*$//;
  $bookHash{uc($_)}=1;
}

while(<Cities>){
  chomp($_);
  s/\s*$//;
  $cityHash{uc($_)}=1;
}

while(<Animals>){
  chomp($_);
  s/\s*$//;
  $animalHash{uc($_)}=1;
}

while(<Universities>){
  chomp($_);
  s/\s*$//;
  $universityHash{uc($_)}=1;
}


$int_msg = "Interrupted system call";

INFINITE: while (1) {
  while (!($paddr = accept(Client, Server))) {
    last INFINITE unless $! eq $int_msg;
  }

  my ($port, $iaddr) = sockaddr_in($paddr);
  my $name = gethostbyaddr($iaddr, AF_INET);

    $thr = threads->new(\&spawn,Client);
    $result = $thr->join;

  close Client;
}


sub spawn {
  my ($clientSocket) = $_[0];

  die "spawn: no client socket!" unless $clientSocket;

 print "received connection...\n";
  $param = ReceiveFrom($clientSocket);
  $param =~ s/^\s+//g;
  $param =~ s/\s$//g;
print "content:$param\n";
  open(datafile, ">$list_path/input$$") ||die "couldnt open file for write";
  print datafile $param;
  close(datafile);
  open(datafile, "$list_path/input$$") ||die "couldnt open file for read";

  $number =1;
  $count =1;
  $finaloutput="";
  while (!eof datafile) {
    $newline = <datafile>;
    #$newline = uc($newline);
    $newline =~ s/^\s+//;
    $newline = $newline." .";

    @orgWordlist = split(/\s+/, $newline);
    #creating the marked array
    for ( $i = 0; $i<= $#orgWordlist; $i++) {
      $taglist[$i] = "";
    }
    #print "outside of window.\n";
    #######################################################################
    #case where the leng/window is 8
    if ($#orgWordlist >= 8) {
		
      for ($i = 0; $i <= ($#orgWordlist-7); $i++) {

	$head = $orgWordlist[$i];
	$tailString =$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3]." ".$orgWordlist[$i+4]." ".$orgWordlist[$i+5]." ".$orgWordlist[$i+6]." ".$orgWordlist[$i+7];
	$compareString =$orgWordlist[$i]." ".$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3]." ".$orgWordlist[$i+4]." ".$orgWordlist[$i+5]." ".$orgWordlist[$i+6]." ".$orgWordlist[$i+7];
	$checksum = $taglist[$i]+$taglist[$i+1]+$taglist[$i+2]+$taglist[$i+3]+$taglist[$i+4]+$taglist[$i+5]+$taglist[$i+6]+$taglist[$i+7];
	$lCaseString = lc($compareString);
	$uCaseString = uc($compareString);
			
	if ($checksum == 0) {
	  $tagclass = 0;
	  $alltags = "";
			
				#check to see if it is in the list
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $countryHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 830; 
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $universityHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 400;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $festdayHash{$uCaseString}) {
	    $tagclass = 220;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $artworkHash{$uCaseString}) {
	    $tagclass = 690;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $bookHash{$uCaseString}) {
	    $tagclass = 610;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $corporationHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 370;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $foodHash{$uCaseString}) {
	    $tagclass = 660;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $buildingHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 840;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $journalHash{$uCaseString}) {
	    $tagclass = 620;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $medicalHash{$uCaseString}) {
	    $tagclass = 640;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $peopleHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 320;
	    $alltags .= " $tagclass ";
	  }

				#update the taglist array
	  if ($alltags ne "") {
	    $taglist[$i] = $alltags;
	    for ($j= ($i+1) ; $j<= ($i+7); $j++) {
	      #for now assume 1 is the mark
	      $alltags =~ s/0 /1 /g;
	      $taglist[$j] = $alltags;
					  
	    }
	    $i = $j -1;
	    $tagclass =0;
	    $alltags="";
	  }
	} else {
				#look of the next index
	  for ($j= $i; $j <= ($i+7); $j++) {
	    if ($taglist[$j] ne "") {
	      $i = $j;
	    }
	  }
	}	
      }
      #inside window 8
    }
    #######################################################################
    #case where the leng/window is 7
    if ($#orgWordlist >= 7) {
		
      for ($i = 0; $i <= ($#orgWordlist-6); $i++) {
	$head = $orgWordlist[$i];
	$tailString =$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3]." ".$orgWordlist[$i+4]." ".$orgWordlist[$i+5]." ".$orgWordlist[$i+6];
	$compareString =$orgWordlist[$i]." ".$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3]." ".$orgWordlist[$i+4]." ".$orgWordlist[$i+5]." ".$orgWordlist[$i+6];
	$checksum = $taglist[$i]+$taglist[$i+1]+$taglist[$i+2]+$taglist[$i+3]+$taglist[$i+4]+$taglist[$i+5]+$taglist[$i+6];
	$lCaseString = lc($compareString);
	$uCaseString = uc($compareString);

	if ($checksum == 0) {		
	  $tagclass = 0;
	  $alltags="";
				#check to see if it is in the list
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $countryHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 830; 
	    $alltags .= " $tagclass ";
	  }
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $riverHash{uc($tailString)})&& ($tailString =~/^[A-Z]/)) {
	    $tagclass = 870; 
	    $alltags .= " $tagclass ";
	  }
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $mountHash{uc($tailString)})&& ($tailString =~/^[A-Z]/)) {
	    $tagclass = 850; 
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $universityHash{$uCaseString}) {
	    $tagclass = 400;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $festdayHash{$uCaseString}) {
	    $tagclass = 220;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $artworkHash{$uCaseString}) {
	    $tagclass = 690;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $bookHash{$uCaseString}) {
	    $tagclass = 610;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $corporationHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 370;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $foodHash{$uCaseString}) {
	    $tagclass = 660;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $buildingHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 840;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $journalHash{$uCaseString}) {
	    $tagclass = 620;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $creatgroupHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 380;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $performHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 240;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $medicalHash{$uCaseString}) {
	    $tagclass = 640;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $peopleHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 320;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $countryHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 830;
	    $alltags .= " $tagclass ";
	  }
				
	  if ($alltags ne "") {
	    $taglist[$i] = $alltags;
	    for ($j= ($i+1) ; $j<= ($i+6); $j++) {
	      #for now assume 1 is the mark
	      $alltags =~ s/0 /1 /g;
	      $taglist[$j] = $alltags;
					  
	    }
	    $i = $j -1;
	  }
	} else {
				#look of the next index
	  for ($j= $i; $j <= ($i+6); $j++) {
	    if ($taglist[$j] ne "") {
	      $i = $j;
	    }
	  }
	}	
      }
      #inside window 7
    }
    #######################################################################
    #case where the leng/window is 6
    if ($#orgWordlist >= 6) {
      for ($i = 0; $i <= ($#orgWordlist-5); $i++) {
	$head = $orgWordlist[$i];
	$tailString =$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3]." ".$orgWordlist[$i+4]." ".$orgWordlist[$i+5];
	$compareString =$orgWordlist[$i]." ".$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3]." ".$orgWordlist[$i+4]." ".$orgWordlist[$i+5];
	$checksum = $taglist[$i]+$taglist[$i+1]+$taglist[$i+2]+$taglist[$i+3]+$taglist[$i+4]+$taglist[$i+5];
			
	$lCaseString = lc($compareString);
	$uCaseString = uc($compareString);
			
	if ($checksum == 0) {
	  $tagclass = 0;
	  $alltags = "";
				#check to see if it is in the list
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $countryHash{uc($tailString)})&& ($tailString =~/^[A-Z]/)) {
	    $tagclass = 830; 
	    $alltags .= " $tagclass ";
	  }
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $riverHash{uc($tailString)})&& ($tailString =~/^[A-Z]/)) {
	    $tagclass = 870; 
	    $alltags .= " $tagclass ";
	  }
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $mountHash{uc($tailString)})&& ($tailString =~/^[A-Z]/)) {
	    $tagclass = 850; 
	    $alltags .= " $tagclass ";
	  }
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $cityHash{uc($tailString)})&& ($tailString =~/^[A-Z]/)) {
	    $tagclass = 820; 
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $universityHash{$uCaseString}) {
	    $tagclass = 400;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $festdayHash{$uCaseString}) {
	    $tagclass = 220;	
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $artworkHash{$uCaseString}) {
	    $tagclass = 690;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $bookHash{$uCaseString}) {
	    $tagclass = 610;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $corporationHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 370;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $foodHash{$uCaseString}) {
	    $tagclass = 660;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $journalHash{$uCaseString}) {
	    $tagclass = 620;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $buildingHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 840;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $creatgroupHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 380;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $performHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 240;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $riverHash{ $uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 870;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $mountHash{ $uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 850;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $medicalHash{$uCaseString}) {
	    $tagclass = 640;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $peopleHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 320;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $countryHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 830;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $locHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 8000;
	    $alltags .= " $tagclass ";
	  }
				
	  if ($alltags ne "") {
	    $taglist[$i] = $alltags;
	    for ($j= $i+1 ; $j<= ($i+5); $j++) {
	      $alltags =~ s/0 /1 /g;
	      #for now assume 1 is the mark
	      $taglist[$j] = $alltags;
					  
	    }
	    $i = $j -1;			
	  }
	} else {
				#look of the next index
	  for ($j= $i; $j <= ($i+5); $j++) {
	    if ($taglist[$j] ne "") {
	      $i = $j;
	    }
	  }
	}	
      }
      #inside window 6
    }
    ##################################################################################
    #case where the window is 5
    if ($#orgWordlist >= 5) {
	
      for ($i = 0; $i <= ($#orgWordlist-4); $i++) {
	$head = $orgWordlist[$i];
	$tailString =$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3]." ".$orgWordlist[$i+4];
	$compareString =$orgWordlist[$i]." ".$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3]." ".$orgWordlist[$i+4];
	$checksum = $taglist[$i]+$taglist[$i+1]+$taglist[$i+2]+$taglist[$i+3]+$taglist[$i+4];
	$lCaseString = lc($compareString);
	$uCaseString = uc($compareString);
			
	if ($checksum == 0) {
	  $tagclass = 0;
	  $alltags = "";
				#check to see if it is in the list
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $countryHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 830; 
	    $alltags .= " $tagclass ";
	  }
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $riverHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 870; 
	    $alltags .= " $tagclass ";
	  }
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $mountHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 850; 
	    $alltags .= " $tagclass ";
	  }
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $cityHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 820; 
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $plantHash{$uCaseString}) {
	    $tagclass = 360;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $universityHash{$uCaseString}) {
	    $tagclass = 400;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $festdayHash{$uCaseString}) {
	    $tagclass = 220;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $artworkHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 690;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $bookHash{$uCaseString}) {
	    $tagclass = 610;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $cityHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 820;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $foodHash{$uCaseString}) {
	    $tagclass = 660;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $buildingHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 840;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $journalHash{$uCaseString}) {
	    $tagclass = 620;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $creatgroupHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 380;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $eventHash{$uCaseString}) {
	    $tagclass = 230;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $performHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 240;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $riverHash{ $uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 870;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $mountHash{ $uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 850;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $medicalHash{$uCaseString}) {
	    $tagclass = 640;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $peopleHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 320;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $countryHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 830;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $corporationHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 370;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $locHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 8000;
	    $alltags .= " $tagclass ";
	  }
	  if ($alltags ne "") {
	    $taglist[$i] = $alltags;
	    for ($j= $i+1 ; $j<= ($i+4); $j++) {
	      $alltags =~ s/0 /1 /g;
	      #for now assume 1 is the mark
	      $taglist[$j] = $alltags;
					  
	    }
	    $i = $j -1;
	  }
	} else {
				#look of the next index
	  for ($j= $i; $j <= ($i+4); $j++) {
	    if ($taglist[$j] ne "") {
	      $i = $j;
	    }
	  }
	}	
      }
      #inside window 5
    }
    #################################################################################
    #window is 4
    if ($#orgWordlist >= 4) {
      for ($i = 0; $i <= ($#orgWordlist-3); $i++) {
	$head =$orgWordlist[$i];
	$tailString = $orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3];
	$compareString =$orgWordlist[$i]." ".$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3];
	$checksum = $taglist[$i]+$taglist[$i+1]+$taglist[$i+2]+$taglist[$i+3];
			
	$lCaseString = lc($compareString);
	$uCaseString = uc($compareString);
	if ($checksum == 0) {
	  $tagclass = 0;
	  $alltags = "";
	  $uCaseString =~ m/^(\w+)\s\d{1,2}\s,\s\d{4,4}/;
	  $month = $1;
	  if ( exists $dateHash{$month}) {
				#	print "DATE -1- !!!!!!!!!!!\n";
				#	print "$uCaseString\n";
	    $tagclass = 960;
	    $alltags .= " $tagclass ";
	  }
	  if (($uCaseString =~ m/^(\d{1,2})\s:\s(\d{2,2})\s[PA]\.M\.?/)) {
	    $tagclass = 950;
	    $alltags .= " $tagclass ";
	  }
	  if (($uCaseString =~ m/^(\d{1,2})\s:\s(\d{2,2})\sMINUTES?/)) {
	    $tagclass = 900;
	    $alltags .= " $tagclass ";
	  }
	  if (($uCaseString =~ m/^(\d{1,2})\s:\s(\d{2,2})\sSEC/)) {
	    $tagclass = 900;
	    $alltags .= " $tagclass ";
	  }
	  if (($uCaseString =~ m/^(\d{1,2})\s:\s(\d{2,2})\sHOURS?/)) {
	    $tagclass = 900;
	    $alltags .= " $tagclass ";
	  }
				
	  if ( $uCaseString =~ m/^\d+\.?\d*\s(.*)/) {
	    if (exists $unitHash{$1}) {
	      $tagclass = 910;
	      $alltags .= " $tagclass ";
	    }
	  }
	  if ( $uCaseString =~ m/^\d+\.?\d*(.*)/) {
	    if (exists $unitHash{$1}) {
	      $tagclass = 910;
	      $alltags .= " $tagclass ";
	    }
	  }
				#check to see if it is in the list
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $countryHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 830; 
	    $alltags .= " $tagclass ";
	  }
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $riverHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 870; 
	    $alltags .= " $tagclass ";
	  }
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $mountHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 850; 
	    $alltags .= " $tagclass ";
	  }
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $cityHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 820; 
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $plantHash{$uCaseString}) {
	    $tagclass = 360;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $profHash{$uCaseString}) {
	    $tagclass =460;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $universityHash{$uCaseString}) {
	    $tagclass = 400;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $festdayHash{$uCaseString}) {
	    $tagclass = 220;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $artworkHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 690;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $bookHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 610;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $cityHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 820;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $foodHash{$uCaseString}) {
	    $tagclass = 660;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $buildingHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 840;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $journalHash{$uCaseString}) {
	    $tagclass = 620;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $creatgroupHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 380;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $eventHash{$uCaseString}) {
	    $tagclass = 230;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $teamHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 410;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $stateHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    if ((length($compareString)>2) || ($compareString eq $uCaseString)) {
	      $tagclass = 880;$alltags .= " $tagclass ";
	    }
	  }
	  if ( exists $performHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 240;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $riverHash{ $uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 870;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $mountHash{ $uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 850;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $medicalHash{$uCaseString}) {
	    $tagclass = 640;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $peopleHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 320;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $animalHash{$uCaseString}) {
	    $tagclass = 310;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $currencyHash{$uCaseString}) {
	    $tagclass = 1000;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $countryHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 830;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $corporationHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 370;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $locHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 8000;
	    $alltags .= " $tagclass ";
	  }
	  if ($alltags != "") {
	    $taglist[$i] = $alltags;
	    for ($j= ($i+1) ; $j<= ($i+3); $j++) {
	      $alltags =~ s/0 /1 /g;
	      #for now assume 1 is the mark
	      $taglist[$j] = $alltags;			
	    }
	    $i = $j -1;
	  }
	} else {
				#look of the next index
	  for ($j= $i; $j <= ($i+3); $j++) {
	    if ($taglist[$j] ne "") {
	      $i = $j;
	    }
	  }
	}	
      }
      #inside window 4
    }
    #######################################################################
    #Case where window is 3
    if ($#orgWordlist >= 3) {
      for ($i = 0; $i <= ($#orgWordlist-2); $i++) {
	$head = $orgWordlist[$i];
	$tailString =$orgWordlist[$i+1]." ".$orgWordlist[$i+2];
	$compareString =$orgWordlist[$i]." ".$orgWordlist[$i+1]." ".$orgWordlist[$i+2];
	$checksum = $taglist[$i]+$taglist[$i+1]+$taglist[$i+2];
		
	$lCaseString = lc($compareString);
	$uCaseString = uc($compareString);
	if ($checksum == 0) {
	  $tagclass =0;
	  $alltags = "";
	  if ( $uCaseString =~ m:^(\d+\.*/*\d*)\sPER\sCENT:) {
	    $tagclass = 1020;
	    $alltags .= " $tagclass ";
	  }
	  if (($uCaseString =~ m/^(\d{1,2})\s:\s(\d{2,2})/)) {
	    $tagclass = 900;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m/^\d+\.?\d*\s(.*)/) {
	    if (exists $unitHash{$1}) {
	      $tagclass = 910;
	      $alltags .= " $tagclass ";
	    }
	  }
	  if ( $uCaseString =~ m/^\d+\.?\d*(.*)/) {
	    if (exists $unitHash{$1}) {
	      $tagclass = 910;
	      $alltags .= " $tagclass ";
	    }
	  }
	  if (exists $profHash{$uCaseString}) {
	    $tagclass =460;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $sportHash{$uCaseString}) {
	    $tagclass =630;
	    $alltags .= " $tagclass ";
	  }
				#check to see if it is in the list
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $countryHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 830; 
	    $alltags .= " $tagclass ";
	  }
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $riverHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 870; 
	    $alltags .= " $tagclass ";
	  }
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $mountHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 850; 
	    $alltags .= " $tagclass ";
	  }
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $cityHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 820; 
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $plantHash{$uCaseString}) {
	    $tagclass = 360;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $universityHash{$uCaseString}) {
	    $tagclass = 400;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $unitHash{$uCaseString}) {
	    $tagclass = 910;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $festdayHash{$uCaseString}) {
	    $tagclass = 220;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $artworkHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 690;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $bookHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 610;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $cityHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 820;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $foodHash{$uCaseString}) {
	    $tagclass = 660;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $buildingHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 840;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $journalHash{$uCaseString}) {
	    $tagclass = 620;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $creatgroupHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 380;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $eventHash{$uCaseString}) {
	    $tagclass = 230;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $teamHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 410;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $stateHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    if ((length($compareString)>2) || ($compareString eq $uCaseString)) {
	      $tagclass = 880;$alltags .= " $tagclass ";
	    }	
	  }
	  if (exists $religionHash{$uCaseString}) {
	    $tagclass = 10;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $langHash{$uCaseString}) {
	    $tagclass = 270;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $performHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 240;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $riverHash{ $uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 870;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $mountHash{ $uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 850;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $polBodyHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 420;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $medicalHash{$uCaseString}) {
	    $tagclass = 640;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $peopleHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 320;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $animalHash{$uCaseString}) {
	    $tagclass = 310;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $currencyHash{$uCaseString}) {
	    $tagclass = 1000;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $countryHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 830;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $corporationHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 370;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $locHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 8000;
	    $alltags .= " $tagclass ";
	  }

	  if ($alltags ne "") {
	    $taglist[$i]= $alltags;
	    for ($j= ($i+1) ; $j<= ($i+2); $j++) {
	      $alltags =~ s/0 /1 /g;
	      #for now assume 1 is the mark
	      $taglist[$j] = $alltags;
					  
	    }
	    $i = $j -1;
	  }
	} else {
				#look of the next index
	  for ($j= $i; $j <= ($i+2); $j++) {
	    if ($taglist[$j] ne "") {
	      $i = $j;
	    }
	  }
	}	
      }
      #inside window 3
    }
    ####################################################################
    #Case where window is 2
    if ($#orgWordlist > 2) {
      for ($i = 0; $i <= ($#orgWordlist-1); $i++) {
	$head = $orgWordlist[$i];
	$tailString = $orgWordlist[$i+1];
	$compareString =$orgWordlist[$i]." ".$orgWordlist[$i+1];
	$checksum = ($taglist[$i] eq "" ? 0:1) +($taglist[$i+1] eq "" ? 0:1);
	$lCaseString = lc($compareString);
	$uCaseString = uc($compareString);
	if ($checksum == 0) {
	  $tagclass =0;
	  $alltags = "";
	  $uCaseString =~ m/^(\w+\.*)\s\d{1,4}/;
	  $month = $1;
			    
	  if ( exists $dateHash{$month}) {
				#print "DATE -2- !!!!!!!!!!!!!!\n";
				#print "$uCaseString\n";
	    $tagclass = 960;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m:^\d+\S*\sYEARS?:) {
	    $tagclass = 900;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m:^(\d+\.?/*\d*)\sWEEKS?:) {
	    $tagclass = 900;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m:^(\d+\.?/*\d*)\sMONTHS?:) {
	    $tagclass = 900;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m:^(\d+\.?/*\d*)\sDAYS?:) {
	    $tagclass = 900;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m:^(\d+\.?/*\d*)\sHOURS?:) {
	    $tagclass = 900;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m:^(\d+\.?/*\d*)\sMINUTES?:) {
	    $tagclass = 900;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m:^(\d+\.?/*\d*)\sSECONDS?:) {
	    $tagclass = 900;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m:^(\d+\.?/*\d*)\sMIN\.?:) {
	    $tagclass = 900;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m:^(\d+\.?/*\d*)\sSEC\.?:) {
	    $tagclass = 900;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m:^(\d+\.?/*\d*)\sHR:) {
	    $tagclass = 900;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m:^(\d+\.?/*\d*)\sUNIT:) {
	    $tagclass = 900;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m:^(\d+\.?/*\d*)\sPERCENT:) {
	    $tagclass = 1020;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m:^(\d+\.?/*\d*)\sDOLLARS?:i) {
	    $tagclass = 1000;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m:^(\d+\.?/*\d*)\sPOUNDS?:i) {
	    $tagclass = 1000;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m:^(\d+\.?/*\d*)\sYENS?:i) {
	    $tagclass = 1000;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m:^(\d+\.?/*\d*)\sPERCENTAGES?:) {
	    $tagclass = 1020;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m/^(\(\d{3,3}\)\s\d{3,3}-\d{4,4})$/) {
	    $tagclass = 930;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m/^DOLLARS\s(\d+.*)/i) {
	    $tagclass = 1000;
	    $alltags .= " $tagclass ";
	  } 
	  if ( $uCaseString =~ m/^([A-Za-z]+DOLLARS)\s(\d+.*)/i) {
	    $tagclass = 1000;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m/^POUNDS\s(\d+.*)/i) {
	    $tagclass = 1000;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m/^NZDOLLARS\s(\d+.*)/i) {
	    $tagclass = 1000;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m/^YEN\s(\d+.*)/i) {
	    $tagclass = 1000;
	    $alltags .= " $tagclass ";
	  } 
	  if ( $uCaseString =~ m/^(\d{1,2})\s([PA]\.M\.?)/i) {
	    $tagclass = 950;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m/^\d+\.?\d*\s(.*)/) {
	    if (exists $unitHash{$1}) {
	      $tagclass = 910;
	      $alltags .= " $tagclass ";
	    }
	  }
	  if ( $uCaseString =~ m/^\d+\.?\d*(.*)/) {
	    if (exists $unitHash{$1}) {
	      $tagclass = 910;
	      $alltags .= " $tagclass ";
	    }
	  }
	  #check to see if it is in the list
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $countryHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 830; 
	    $alltags .= " $tagclass ";
	  }
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $riverHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 870; 
	    $alltags .= " $tagclass ";
	  }
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $mountHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 850; 
	    $alltags .= " $tagclass ";
	  }
	  if ( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $cityHash{uc($tailString)}) && ($tailString =~/^[A-Z]/)) {
	    $tagclass = 820; 
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $plantHash{$uCaseString}) {
	    $tagclass = 360;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $sportHash{$uCaseString}) {
	    $tagclass =630;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $universityHash{$uCaseString}) {
	    $tagclass = 400;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $profHash{$uCaseString}) {
	    $tagclass =460;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $unitHash{$uCaseString}) {
	    $tagclass = 910;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $festdayHash{$uCaseString}) {
	    $tagclass = 220;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $artworkHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 690;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $bookHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 610;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $cityHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 820;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $foodHash{$uCaseString}) {
	    $tagclass = 660;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $buildingHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 840;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $journalHash{$uCaseString}) {
	    $tagclass = 620;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $creatgroupHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 380;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $eventHash{$uCaseString}) {
	    $tagclass = 230;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $teamHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 410;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $stateHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    if ((length($compareString)>2) || ($compareString eq $uCaseString)) {
	      $tagclass = 880;$alltags .= " $tagclass ";
	    }
	  }
	  if (exists $religionHash{$uCaseString}) {
	    $tagclass = 10;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $langHash{$uCaseString}) {
	    $tagclass = 270;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $performHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 240;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $riverHash{ $uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 870;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $mountHash{ $uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 850;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $polBodyHash{$uCaseString}) {
	    $tagclass = 420;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $medicalHash{$uCaseString}) {
	    $tagclass = 640;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $peopleHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 320;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $animalHash{$uCaseString}) {
	    $tagclass = 310;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $currencyHash{$uCaseString}) {
	    $tagclass = 1000;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $countryHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 830;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $corporationHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 370;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $locHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 8000;
	    $alltags .= " $tagclass ";
	  }
	  if ($alltags ne "") {
	    $taglist[$i] = $alltags;
	    $alltags =~ s/0 /1 /g;
	    $taglist[$i+1] = $alltags;					  
	    $i = $i+1;
	  }
	} else {
				#look of the next index
	  for ($j= $i; $j <= ($i+1); $j++) {
	    if ($taglist[$j] ne "") {
	      $i = $j;
	    }
	  }
				
	}
			
      }
      #inside window 2
    }
    #######################################################################
    #Case where window is 1
    if ($#orgWordlist >= 1) {
      for ($i = 0; $i <= $#orgWordlist; $i++) {
	$compareString =$orgWordlist[$i];
	$checksum = $taglist[$i];
	$lCaseString = lc($compareString);
	$uCaseString = uc($compareString);
	if ($checksum == 0) {
	  $tagclass =0;
	  $yearString = $uCaseString." ";
	  $alltags = "";
	  if ( exists $dateHash{$uCaseString}) {
	    #print"Date -3- !!!!!!!!!!!!\n";
	    #print"$uCaseString\n";
	    $tagclass = 960;
	    $alltags = "";
	  }
	  if ( $uCaseString =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/ ) {
	    $tagclass =8000; 
	    $alltags .= " $tagclass ";
	  }
	  if ($uCaseString =~ m/^(\d{5,5})$/) {
	    $tagclass = 920;
	    $alltags .= " $tagclass ";
	  }
	  if (($uCaseString =~ m/(^[A-Z]\w*)-(.*)/) && (exists $corporationHash{$1} || exists $corporationHash{$2})) {
	    $tagclass =370;
	    $alltags .= " $tagclass ";
	  } 
	  if ($uCaseString =~ m/^(\d{5,5}-\d{4,4})$/) {
	    $tagclass = 920;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m/(\$)/) {
	    $tagclass =1000;
	    $alltags .= " $tagclass ";
	  }  
	  if ( $uCaseString =~ m/^([A-Z]+[a-z]*\d+)/) {
	    $tagclass = 1000;
	    $alltags .= " $tagclass ";
	  }  
	  if ( $uCaseString =~ m/^\d+.*%$/) {
	    $tagclass = 1020;
	    $alltags .= " $tagclass ";
	  }  
	  if ( $yearString =~ m/(^\d{4,4}\s)/ || $yearString =~ m/(^\d{4,4}s)\s/ || $yearString =~ m/(^\d{4,4}-\d+)\s/ ) {
	    #print"Date -4- !!!!!!!!!!!!!!\n";
	    #print"$uCaseString\n";
	    $tagclass = 960;
	    $alltags .= " $tagclass ";
	  }
	  if ( ($uCaseString =~ m/^\d+\.?\d*(.*)/) && (exists $unitHash{$1})) {
	    $tagclass = 910;
	    $alltags .= " $tagclass ";
	  }
 
				#check to see if it is in the list
	  if ( exists $dayHash{$uCaseString}) {
	    $tagclass = 960;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $plantHash{$uCaseString}) {
	    $tagclass = 360;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $sportHash{$uCaseString}) {
	    $tagclass =630;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $colorHash{$uCaseString}) {
	    $tagclass =600;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $profHash{$uCaseString}) {
	    $tagclass =460;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $numberHash{$uCaseString}) {
	    $tagclass =900;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $universityHash{$uCaseString}) {
	    $tagclass = 400;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $unitHash{$uCaseString}) {
	    $tagclass = 910;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $festdayHash{$uCaseString}) {
	    $tagclass = 220;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $artworkHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 690;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $bookHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 610;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $cityHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 820;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $foodHash{$uCaseString}) {
	    $tagclass = 660;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $buildingHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 840;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $journalHash{$uCaseString}) {
	    $tagclass = 620;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $creatgroupHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 380;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $eventHash{$uCaseString}) {
	    $tagclass = 230;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $teamHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 410;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $stateHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    if ((length($compareString)>2) || ($compareString eq $uCaseString)) {
	      $tagclass = 880;$alltags .= " $tagclass ";
	    }
	  }
	  if (exists $religionHash{$uCaseString}) {
	    $tagclass = 10;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $langHash{$uCaseString}) {
	    $tagclass = 270;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $performHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 240;
	    $alltags .= " $tagclass ";
	  }
	  if (exists $dateHash{$uCaseString}) {
	    #print"DATE -5- -------------\n";
	    #print"$uCaseString\n";
	    $tagclass = 960;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $riverHash{ $uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 870;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $mountHash{ $uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 850;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $polBodyHash{$uCaseString}) {
	    $tagclass = 420;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $medicalHash{$uCaseString}) {
	    $tagclass = 640;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $peopleHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 320;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $animalHash{$uCaseString}) {
	    $tagclass = 310;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $currencyHash{$uCaseString}) {
	    $tagclass = 1000;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $countryHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 830;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $corporationHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 370;
	    $alltags .= " $tagclass ";
	  }
	  if ( exists $locHash{$uCaseString} && ($compareString =~/^[A-Z]/)) {
	    $tagclass = 8000;
	    $alltags .= " $tagclass ";
	  }
	  if ( $uCaseString =~ m/^\d/ ) { # all the left over case
	    $tagclass = 900;
	    $alltags .= " $tagclass ";
	  }
					
	  $taglist[$i] = $alltags;
	}
      }
      #inside window 1
    }
    ###############################################################
    #converting taglist into printable line
    #except for the last index becasue we concat a extra . 
    $printline="";
    for ($i = 0; $i< $#taglist; $i++) {
      #   $printline .= "<$taglist[$i]>";
      #   $printline = "bla";
      if ($taglist[$i] eq "") {
	$printline =$printline." $orgWordlist[$i]";
      } elsif ($taglist[$i] =~ /0 /) {
	$printline .= " [ B-";
	if ($taglist[$i] =~ / 220 /) {
	  $printline =$printline."DayFest/";
	}
	if ($taglist[$i] =~ / 230 /) {
	  $printline =$printline."Event/";
	}
	if ($taglist[$i] =~ / 240 /) {
	  $printline =$printline."Perform/";
	}
	if ($taglist[$i] =~ / 270 /) {
	  $printline =$printline."LangRace/";
	}
	if ($taglist[$i] =~ / 310 /) {
	  $printline =$printline."Animal/";
	}
	if ($taglist[$i] =~ / 320 /) {
	  $printline =$printline."Peop/";
	}
	if ($taglist[$i] =~ / 360 /) {
	  $printline =$printline."Plant/";
	}
	if ($taglist[$i] =~ / 370 /) {
	  $printline =$printline."OrgCorp/";
	}
	if ($taglist[$i] =~ / 380 /) {
	  $printline =$printline."OrgCGroup/";
	}
	if ($taglist[$i] =~ / 400 /) {
	  $printline =$printline."OrgUniv/";
	}
	if ($taglist[$i] =~ / 410 /) {
	  $printline =$printline."OrgTeam/";
	}
	if ($taglist[$i] =~ / 420 /) {
	  $printline =$printline."OrgPolBody/";
	}
	if ($taglist[$i] =~ / 460 /) {
	  $printline =$printline."ProfTitle/";
	}
	if ($taglist[$i] =~ / 600 /) {
	  $printline =$printline."Color/";
	}
	if ($taglist[$i] =~ / 610 /) {
	  $printline =$printline."Book/";
	}
	if ($taglist[$i] =~ / 620 /) {
	  $printline =$printline."Jour/";
	}
	if ($taglist[$i] =~ / 630 /) {
	  $printline =$printline."Sport/";
	}
	if ($taglist[$i] =~ / 640 /) {
	  $printline =$printline."Medical/";
	}
	if ($taglist[$i] =~ / 660 /) {
	  $printline =$printline."Food/";
	}
	if ($taglist[$i] =~ / 820 /) {
	  $printline =$printline."LocCit/";
	}
	if ($taglist[$i] =~ / 830 /) {
	  $printline =$printline."LocCoun/";
	}
	if ($taglist[$i] =~ / 840 /) {
	  $printline =$printline."LocStruct/";
	}
	if ($taglist[$i] =~ / 850 /) {
	  $printline =$printline."LocMount/";
	}
	if ($taglist[$i] =~ / 870 /) {
	  $printline =$printline."LocRiver/";
	}
	if ($taglist[$i] =~ / 880 /) {
	  $printline =$printline."LocStat/";
	}
	if ($taglist[$i] =~ / 900 /) {
	  $printline =$printline."Num/";
	}
	if ($taglist[$i] =~ / 910 /) {
	  $printline =$printline."NumUnit/";
	}
	if ($taglist[$i] =~ / 920 /) {
	  $printline =$printline."NumZip/";
	}
	if ($taglist[$i] =~ / 930 /) {
	  $printline =$printline."NumPhone/";
	}
	if ($taglist[$i] =~ / 950 /) {
	  $printline =$printline."NumTime/";
	}
	if ($taglist[$i] =~ / 960 /) {
		      
	  #print/"####PRINTING  B-DATE ##########\n";
	  $printline =$printline."Date/";
	}
	if ($taglist[$i] =~ / 1000 /) {
	  $printline =$printline."Money/";
	}
	if ($taglist[$i] =~ / 1020 /) {
	  $printline =$printline."NumPercent/";
	}
	if ($taglist[$i] =~8000 ) {
	  $printline =$printline."Loc/";
	}
	if ($taglist[$i] =~ / 3000 /) {
	  $printline =$printline."Org/";
	}
	if ($taglist[$i] =~ / 690 /) {
	  $printline =$printline."Art/";
	}
	if ($taglist[$i] =~ / 10 /) {
	  $printline =$printline."Religion/";
	}
	$printline =~ s/\/$//g;
	$printline .= " $orgWordlist[$i] ]";
      } elsif ($taglist[$i] =~ /1 /) {
	$printline .= " [ I-";
	if ($taglist[$i] =~ / 221 /) {
	  $printline =$printline."DayFest/";
	}
	if ($taglist[$i] =~ / 231 /) {
	  $printline =$printline."Event/";
	}
	if ($taglist[$i] =~ / 241 /) {
	  $printline =$printline."Perform/";
	}
	if ($taglist[$i] =~ / 271 /) {
	  $printline =$printline."LangRace/";
	}
	if ($taglist[$i] =~ / 311 /) {
	  $printline =$printline."Animal/";
	}
	if ($taglist[$i] =~ / 321 /) {
	  $printline =$printline."Peop/";
	}
	if ($taglist[$i] =~ / 361 /) {
	  $printline =$printline."Plant/";
	}
	if ($taglist[$i] =~ / 371 /) {
	  $printline =$printline."OrgCorp/";
	}
	if ($taglist[$i] =~ / 381 /) {
	  $printline =$printline."OrgCGroup/";
	}
	if ($taglist[$i] =~ / 401 /) {
	  $printline =$printline."OrgUniv/";
	}
	if ($taglist[$i] =~ / 411 /) {
	  $printline =$printline."OrgTeam/";
	}
	if ($taglist[$i] =~ / 421 /) {
	  $printline =$printline."OrgPolBody/";
	}
	if ($taglist[$i] =~ / 461 /) {
	  $printline =$printline."ProfTitle/";
	}
	if ($taglist[$i] =~ / 601 /) {
	  $printline =$printline."Color/";
	}
	if ($taglist[$i] =~ / 611 /) {
	  $printline =$printline."Book/";
	}
	if ($taglist[$i] =~ / 621 /) {
	  $printline =$printline."Jour/";
	}
	if ($taglist[$i] =~ / 631 /) {
	  $printline =$printline."Sport/";
	}
	if ($taglist[$i] =~ / 641 /) {
	  $printline =$printline."Medical/";
	}
	if ($taglist[$i] =~ / 661 /) {
	  $printline =$printline."Food/";
	}
	if ($taglist[$i] =~ / 821 /) {
	  $printline =$printline."LocCit/";
	}
	if ($taglist[$i] =~ / 831 /) {
	  $printline =$printline."LocCoun/";
	}
	if ($taglist[$i] =~ / 841 /) {
	  $printline =$printline."LocStruct/";
	}
	if ($taglist[$i] =~ / 851 /) {
	  $printline =$printline."LocMount/";
	}
	if ($taglist[$i] =~ / 871 /) {
	  $printline =$printline."LocRiver/";
	}
	if ($taglist[$i] =~ / 881 /) {
	  $printline =$printline."LocStat/";
	}
	if ($taglist[$i] =~ / 901 /) {
	  $printline =$printline."Num/";
	}
	if ($taglist[$i] =~ / 911 /) {
	  $printline =$printline."NumUnit/";
	}
	if ($taglist[$i] =~ / 921 /) {
	  $printline =$printline."NumZip/";
	}
	if ($taglist[$i] =~ / 931 /) {
	  $printline =$printline."NumPhone/";
	}
	if ($taglist[$i] =~ / 951 /) {
	  $printline =$printline."NumTime/";
	}
	if ($taglist[$i] =~ / 961 /) {
		      
	  #print/"####PRINTING  B-DATE ##########\n";
	  $printline =$printline."Date/";
	}
	if ($taglist[$i] =~ / 1001 /) {
	  $printline =$printline."Money/";
	}
	if ($taglist[$i] =~ / 1021 /) {
	  $printline =$printline."NumPercent/";
	}
	if ($taglist[$i] =~8001 ) {
	  $printline =$printline."Loc/";
	}
	if ($taglist[$i] =~ / 3001 /) {
	  $printline =$printline."Org/";
	}
	if ($taglist[$i] =~ / 691 /) {
	  $printline =$printline."Art/";
	}
	if ($taglist[$i] =~ / 11 /) {
	  $printline =$printline."Religion/";
	}
	$printline =~ s/\/$//g;
	$printline .= " $orgWordlist[$i] ]";
      }
		
    }
    ###############################################################
    $printline =~ s/^\s+//;
    $finaloutput .=  "$printline\n";
  
    $count++;

    @orgWordlist= ();
    @taglist =();
    #inside while loop	
  }
  print "sending data: $finaloutput\n";
  send $clientSocket, pack("N", length $finaloutput), 0;
  send($clientSocket, $finaloutput, 0) ||die "ServerSend: $!";  
  close(datafile);
  return 0;
}


close (Sports);
close (Currency);
close (Plant);
close (Event);
close (Performance);
close (CreatGroup);
close (Rivers);
close (Mountains);
close (ProfTitle);
close (Units);
close (PolBodies);
close (Buildings);
close (FestDays);
close (Artworks);
close (Books);
close (Cities);
close (Animals);
close (Loc);
close (Countries);
close (Days);
close (Foods);
close (Journals);
close (Languagues);
close (Months);
close (People);
close (Religions);
close (States);
close (Teams);
close (Universities);
close (Corporations);
close (Number);
close (medical);


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
