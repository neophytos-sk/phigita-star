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

if (@ARGV < 1)
{
  print "usage: nameEntity-tagger.pl <input filename> <output filename>\n";
  print "If output is left BLANK it will print to STDOUT \n";
  exit;
}
if (@ARGV == 1)
  {
	$writefile = STDOUT;
  }
else
  {
	$writefile = writefile;
	open ($writefile, ">>$ARGV[1]") || die "Can't create file. ";
  }
$list_path="/home/roth/metzler1/ne/listne/lists";
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
open (datafile, "$ARGV[0]") || die "Can't open Data file. ";

#uppercased version

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
$number =1;
$count =1;
while(!eof datafile)
  {
	$newline = <datafile>;
	#$newline = uc($newline);
	$newline =~ s/^\s+//;
	$newline = $newline." .";

	@orgWordlist = split(/\s+/, $newline);
	#creating the marked array
	for ( $i = 0; $i<= $#orgWordlist; $i++)
	  {
		$taglist[$i] = 0;
	  }
	#print "outside of window.\n";
#######################################################################
#case where the leng/window is 8
	if($#orgWordlist >= 8)
	  {
		
		for($i = 0; $i <= ($#orgWordlist-7); $i++)
		  {

			$head = $orgWordlist[$i];
			$tailString =$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3]." ".$orgWordlist[$i+4]." ".$orgWordlist[$i+5]." ".$orgWordlist[$i+6]." ".$orgWordlist[$i+7];
			$compareString =$orgWordlist[$i]." ".$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3]." ".$orgWordlist[$i+4]." ".$orgWordlist[$i+5]." ".$orgWordlist[$i+6]." ".$orgWordlist[$i+7];
			$checksum = $taglist[$i]+$taglist[$i+1]+$taglist[$i+2]+$taglist[$i+3]+$taglist[$i+4]+$taglist[$i+5]+$taglist[$i+6]+$taglist[$i+7];
			$lCaseString = lc($compareString);
			$uCaseString = uc($compareString);
			
			if($checksum == 0)
			  {
				$tagclass = 0;
			
				#check to see if it is in the list
				if( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $countryHash{$tailString}))
				  {
					$tagclass = 830; 
				  }
				elsif( exists $universityHash{$compareString})
				  {
 					$tagclass = 400;
				  }
				elsif(exists $festdayHash{$compareString})
				  {
					$tagclass = 220;
				  }
				elsif( exists $artworkHash{$compareString})
				  {
					$tagclass = 690;
				  }
				elsif( exists $bookHash{$compareString})
				  {
					$tagclass = 610;
				  }
				elsif( exists $corporationHash{$compareString})
				  {
					$tagclass = 370;
				  }
				elsif( exists $foodHash{$lCaseString})
				  {
					$tagclass = 660;
				  }
				elsif( exists $buildingHash{$compareString})
				  {
					$tagclass = 840;
				  }
				elsif( exists $journalHash{$lCaseString})
				  {
					$tagclass = 620;
				  }
				elsif( exists $medicalHash{$compareString})
				  {
					$tagclass = 640;
				  }
				elsif( exists $peopleHash{$compareString})
				  {
					$tagclass = 320;
				  }

				#update the taglist array
				if($tagclass != 0){
				  $taglist[$i] = $tagclass;
				  for($j= ($i+1) ; $j<= ($i+7); $j++)
					{
					  #for now assume 1 is the mark
					  $taglist[$j] = $tagclass+1;
					  
				  }
				  $i = $j -1;
				  $tagclass =0;
				}
			  }
			else
			  {
				#look of the next index
				for($j= $i; $j <= ($i+7); $j++)
				  {
					if($taglist[$j] != 0){
					  $i = $j;
					}
				  }
			  }	
		  }
		#inside window 8
	  }
#######################################################################
#case where the leng/window is 7
	if($#orgWordlist >= 7)
	  {
		
		for($i = 0; $i <= ($#orgWordlist-6); $i++)
		  {
			$head = $orgWordlist[$i];
			$tailString =$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3]." ".$orgWordlist[$i+4]." ".$orgWordlist[$i+5]." ".$orgWordlist[$i+6];
			$compareString =$orgWordlist[$i]." ".$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3]." ".$orgWordlist[$i+4]." ".$orgWordlist[$i+5]." ".$orgWordlist[$i+6];
			$checksum = $taglist[$i]+$taglist[$i+1]+$taglist[$i+2]+$taglist[$i+3]+$taglist[$i+4]+$taglist[$i+5]+$taglist[$i+6];
			$lCaseString = lc($compareString);
			$uCaseString = uc($compareString);

			if($checksum == 0)
			  {		
				$tagclass = 0;
				#check to see if it is in the list
					if( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $countryHash{$tailString}))
				  {
					$tagclass = 830; 
				  }
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $riverHash{$tailString}))
				  {
					$tagclass = 870; 
				  }
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $mountHash{$tailString}))
				  {
					$tagclass = 850; 
				  }
				elsif( exists $universityHash{$compareString})
				  {
					$tagclass = 400;
				  }
				elsif(exists $festdayHash{$compareString})
				  {
					$tagclass = 220;
				  }
				elsif( exists $artworkHash{$compareString})
				  {
					$tagclass = 690;
				  }
				elsif( exists $bookHash{$compareString})
				  {
					$tagclass = 610;
				  }
				elsif( exists $corporationHash{$compareString})
				  {
					$tagclass = 370;
				  }
				elsif( exists $foodHash{$lCaseString})
				  {
					$tagclass = 660;
				  }
				elsif( exists $buildingHash{$compareString})
				  {
					$tagclass = 840;
				  }
				elsif( exists $journalHash{$lCaseString})
				  {
					$tagclass = 620;
				  }
				elsif( exists $creatgroupHash{$compareString})
				  {
					$tagclass = 380;
				  }
				elsif( exists $performHash{$compareString})
				  {
					$tagclass = 240;
				  }
				elsif( exists $medicalHash{$compareString})
				  {
					$tagclass = 640;
				  }
				elsif( exists $peopleHash{$compareString})
				  {
					$tagclass = 320;
				  }
				elsif( exists $countryHash{$compareString})
				  {
					$tagclass = 830;
				  }
				
				if($tagclass != 0){
				  $taglist[$i] = $tagclass;
				  for($j= ($i+1) ; $j<= ($i+6); $j++)
					{
					  #for now assume 1 is the mark
					  $taglist[$j] = ($tagclass+1);
					  
					}
				  $i = $j -1;
				}
			  }
			else
			  {
				#look of the next index
				for($j= $i; $j <= ($i+6); $j++)
				  {
					if($taglist[$j] != 0){
					  $i = $j;
					}
				  }
			  }	
		  }
		#inside window 7
	  }
#######################################################################
#case where the leng/window is 6
	if($#orgWordlist >= 6)
	  {
		for($i = 0; $i <= ($#orgWordlist-5); $i++)
		  {
			$head = $orgWordlist[$i];
			$tailString =$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3]." ".$orgWordlist[$i+4]." ".$orgWordlist[$i+5];
			$compareString =$orgWordlist[$i]." ".$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3]." ".$orgWordlist[$i+4]." ".$orgWordlist[$i+5];
			$checksum = $taglist[$i]+$taglist[$i+1]+$taglist[$i+2]+$taglist[$i+3]+$taglist[$i+4]+$taglist[$i+5];
			
			$lCaseString = lc($compareString);
			$uCaseString = uc($compareString);
			
			if($checksum == 0)
			  {
				$tagclass = 0;
				#check to see if it is in the list
				if( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $countryHash{$tailString}))
				  {
					$tagclass = 830; 
				  }
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $riverHash{$tailString}))
				  {
					$tagclass = 870; 
				  }
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $mountHash{$tailString}))
				  {
					$tagclass = 850; 
				  }
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $cityHash{$tailString}))
				  {
					$tagclass = 820; 
				  }
				elsif( exists $universityHash{$compareString})
				  {
					$tagclass = 400;
				  }
				elsif(exists $festdayHash{$compareString})
				  {
					$tagclass = 220;
				  }
				elsif( exists $artworkHash{$compareString})
				  {
					$tagclass = 690;
				  }
				elsif( exists $bookHash{$compareString})
				  {
					$tagclass = 610;
				  }
				elsif( exists $corporationHash{$compareString})
				  {
					$tagclass = 370;
				  }
				elsif( exists $foodHash{$lCaseString})
				  {
					$tagclass = 660;
				  }
				elsif( exists $journalHash{$lCaseString})
				  {
					$tagclass = 620;
				  }
				elsif( exists $buildingHash{$compareString})
				  {
					$tagclass = 840;
				  }
				elsif( exists $creatgroupHash{$compareString})
				  {
					$tagclass = 380;
				  }
				elsif( exists $performHash{$compareString})
				  {
					$tagclass = 240;
				  }
				elsif( exists $riverHash{ $compareString})
				  {
					$tagclass = 870;
				  }
				elsif( exists $mountHash{ $compareString})
				  {
					$tagclass = 850;
				  }
				elsif( exists $medicalHash{$compareString})
				  {
					$tagclass = 640;
				  }
				elsif( exists $peopleHash{$compareString})
				  {
					$tagclass = 320;
				  }
				elsif( exists $countryHash{$compareString})
				  {
					$tagclass = 830;
				  }
				elsif( exists $locHash{$compareString})
				  {
					$tagclass = 8000;
				  }
				
				if($tagclass !=0){
				  $taglist[$i] = $tagclass;
				  for($j= $i+1 ; $j<= ($i+5); $j++)
					{
					  #for now assume 1 is the mark
					  $taglist[$j] = $tagclass+1;
					  
					}
				  $i = $j -1;			
				}
			  }
			else
			  {
				#look of the next index
				for($j= $i; $j <= ($i+5); $j++)
				  {
					if($taglist[$j] != 0){
					  $i = $j;
					}
				  }
			  }	
		  }
		#inside window 6
	  }
##################################################################################
#case where the window is 5
	if($#orgWordlist >= 5)
	  {
	
		for($i = 0; $i <= ($#orgWordlist-4); $i++)
		  {
			 $head = $orgWordlist[$i];
			$tailString =$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3]." ".$orgWordlist[$i+4];
			$compareString =$orgWordlist[$i]." ".$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3]." ".$orgWordlist[$i+4];
			$checksum = $taglist[$i]+$taglist[$i+1]+$taglist[$i+2]+$taglist[$i+3]+$taglist[$i+4];
			$lCaseString = lc($compareString);
			$uCaseString = uc($compareString);
			
			if($checksum == 0)
			  {
				$tagclass = 0;
				#check to see if it is in the list
				if( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $countryHash{$tailString}))
				  {
					$tagclass = 830; 
				  }
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $riverHash{$tailString}))
				  {
					$tagclass = 870; 
				  }
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $mountHash{$tailString}))
				 {
					$tagclass = 850; 
				  }
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $cityHash{$tailString}))
				  {
					$tagclass = 820; 
				  }
				elsif( exists $plantHash{$lCaseString})
				  {
					$tagclass = 360;
				  }
				elsif( exists $universityHash{$compareString})
				  {
					$tagclass = 400;
				  }
				elsif(exists $festdayHash{$compareString})
				  {
					$tagclass = 220;
				  }
				elsif( exists $artworkHash{$compareString})
				  {
					$tagclass = 690;
				  }
				elsif( exists $bookHash{$compareString})
				  {
					$tagclass = 610;
				  }
				elsif( exists $cityHash{$compareString})
				  {
					$tagclass = 820;
				  }
				elsif( exists $foodHash{$lCaseString})
				  {
					$tagclass = 660;
				  }
				elsif( exists $buildingHash{$compareString})
				  {
					$tagclass = 840;
				  }
				elsif( exists $journalHash{$lCaseString})
				  {
					$tagclass = 620;
				  }
				elsif( exists $creatgroupHash{$compareString})
				  {
					$tagclass = 380;
				  }
				elsif(exists $eventHash{$compareString})
				  {
					$tagclass = 230;
				  }
				elsif( exists $performHash{$compareString})
				  {
					$tagclass = 240;
				  }
				elsif( exists $riverHash{ $compareString})
				  {
					$tagclass = 870;
				  }
				elsif( exists $mountHash{ $compareString})
				  {
					$tagclass = 850;
				  }
				elsif( exists $medicalHash{$compareString})
				  {
					$tagclass = 640;
				  }
				elsif( exists $peopleHash{$compareString})
				  {
					$tagclass = 320;
				  }
				elsif( exists $countryHash{$compareString})
				  {
					$tagclass = 830;
				  }
				elsif( exists $corporationHash{$compareString})
				  {
					$tagclass = 370;
				  }
				elsif( exists $locHash{$compareString})
				  {
					$tagclass = 8000;
				  }
				if($tagclass != 0){
				  $taglist[$i] = $tagclass;
				  for($j= $i+1 ; $j<= ($i+4); $j++)
					{
					  #for now assume 1 is the mark
					  $taglist[$j] = $tagclass+1;
					  
					}
				  $i = $j -1;
				}
			  }
			else
			  {
				#look of the next index
				for($j= $i; $j <= ($i+4); $j++)
				  {
					if($taglist[$j] != 0){
					  $i = $j;
					}
				  }
			  }	
		  }
		#inside window 5
	  }
#################################################################################
#window is 4
	if($#orgWordlist >= 4)
	  {
		for($i = 0; $i <= ($#orgWordlist-3); $i++)
		  {
			$head =$orgWordlist[$i];
			$tailString = $orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3];
			$compareString =$orgWordlist[$i]." ".$orgWordlist[$i+1]." ".$orgWordlist[$i+2]." ".$orgWordlist[$i+3];
			$checksum = $taglist[$i]+$taglist[$i+1]+$taglist[$i+2]+$taglist[$i+3];
			
			$lCaseString = lc($compareString);
			$uCaseString = uc($compareString);
			if($checksum == 0)
			  {
				$tagclass = 0;

				$compareString =~ m/^(\w+)\s\d{1,2}\s,\s\d{4,4}/;
				$month = $1;
				if( exists $dateHash{$month})
				  {
				#	print "DATE -1- !!!!!!!!!!!\n";
				#	print "$compareString\n";
					$tagclass = 960;
				  }
				elsif(($compareString =~ m/^(\d{1,2})\s:\s(\d{2,2})\s[pa]\.m\.?/))
				  {
					$tagclass = 950;
				  }
				elsif(($compareString =~ m/^(\d{1,2})\s:\s(\d{2,2})\sminutes?/))
				  {
					$tagclass = 900;
				  }
				elsif(($compareString =~ m/^(\d{1,2})\s:\s(\d{2,2})\ssec/))
				  {
					$tagclass = 900;
				  }
				elsif(($compareString =~ m/^(\d{1,2})\s:\s(\d{2,2})\shours?/))
				  {
					$tagclass = 900;
				  }
				
				elsif( $compareString =~ m/^\d+\.?\d*\s(.*)/)
				  {
					if(exists $unitHash{$1}){
					  $tagclass = 910;
					}
				  }
				elsif( $compareString =~ m/^\d+\.?\d*(.*)/)
				  {
					if (exists $unitHash{$1}){
					  $tagclass = 910;
					}
				  }
				#check to see if it is in the list
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $countryHash{$tailString}))
				  {
					$tagclass = 830; 
				  }
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $riverHash{$tailString}))
				  {
					$tagclass = 870; 
				  }
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $mountHash{$tailString}))
				  {
					$tagclass = 850; 
				  }
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $cityHash{$tailString}))
				  {
					$tagclass = 820; 
				  }
				elsif( exists $plantHash{$lCaseString})
				  {
					$tagclass = 360;
				  }
				elsif(exists $profHash{$lCaseString})
				  {
					$tagclass =460;
				  }
				elsif( exists $universityHash{$compareString})
				  {
					$tagclass = 400;
				  }
				elsif(exists $festdayHash{$compareString})
				  {
					$tagclass = 220;
				  }
				elsif( exists $artworkHash{$compareString})
				  {
					$tagclass = 690;
				  }
				elsif( exists $bookHash{$compareString})
				  {
					$tagclass = 610;
				  }
				elsif( exists $cityHash{$compareString})
				  {
					$tagclass = 820;
				  }
				elsif( exists $foodHash{$lCaseString})
				  {
					$tagclass = 660;
				  }
				elsif( exists $buildingHash{$compareString})
				  {
					$tagclass = 840;
				  }
				elsif( exists $journalHash{$lCaseString})
				  {
					$tagclass = 620;
				  }
				elsif( exists $creatgroupHash{$compareString})
				  {
					$tagclass = 380;
				  }
				elsif(exists $eventHash{$compareString})
				  {
					$tagclass = 230;
				  }
				elsif(exists $teamHash{$compareString})
				  {
					$tagclass = 410;
				  }
				elsif(exists $stateHash{$compareString})
				  {
					$tagclass = 880;
				  }
				elsif( exists $performHash{$compareString})
				  {
					$tagclass = 240;
				  }
				elsif( exists $riverHash{ $compareString})
				  {
					$tagclass = 870;
				  }
				elsif( exists $mountHash{ $compareString})
				  {
					$tagclass = 850;
				  }
				elsif( exists $medicalHash{$compareString})
				  {
					$tagclass = 640;
				  }
				elsif( exists $peopleHash{$compareString})
				  {
					$tagclass = 320;
				  }
				elsif( exists $animalHash{$lCaseString})
				  {
					$tagclass = 310;
				  }
				elsif( exists $currencyHash{$compareString})
				  {
					$tagclass = 1000;
				  }
				elsif( exists $countryHash{$compareString})
				  {
					$tagclass = 830;
				  }
				elsif( exists $corporationHash{$compareString})
				  {
					$tagclass = 370;
				  }
				elsif( exists $locHash{$compareString})
				  {
					$tagclass = 8000;
				  }
				if($tagclass != 0){
				  $taglist[$i] = $tagclass;
				  for($j= ($i+1) ; $j<= ($i+3); $j++)
					{
					  #for now assume 1 is the mark
					  $taglist[$j] = $tagclass+1;			
					}
					$i = $j -1;
				}
			  }
			else
			  {
				#look of the next index
				for($j= $i; $j <= ($i+3); $j++)
				  {
					if($taglist[$j] != 0){
					  $i = $j;
					}
				  }
			  }	
		  }
		#inside window 4
	  }
#######################################################################
#Case where window is 3
	if($#orgWordlist >= 3)
	  {
		for($i = 0; $i <= ($#orgWordlist-2); $i++)
		  {
			$head = $orgWordlist[$i];
			$tailString =$orgWordlist[$i+1]." ".$orgWordlist[$i+2];
			$compareString =$orgWordlist[$i]." ".$orgWordlist[$i+1]." ".$orgWordlist[$i+2];
			$checksum = $taglist[$i]+$taglist[$i+1]+$taglist[$i+2];
		
			$lCaseString = lc($compareString);
			$uCaseString = uc($compareString);
			if($checksum == 0)
			  {
				$tagclass =0;
				if( $compareString =~ m:^(\d+\.*/*\d*)\sper\scent:)
				  {
					$tagclass = 1020;
				  }
				elsif(($compareString =~ m/^(\d{1,2})\s:\s(\d{2,2})/))
				  {
					$tagclass = 900;
				  }
				elsif( $compareString =~ m/^\d+\.?\d*\s(.*)/)
				  {
					if(exists $unitHash{$1}){
					  $tagclass = 910;
					}
				  }
				elsif( $compareString =~ m/^\d+\.?\d*(.*)/)
				  {
					if (exists $unitHash{$1}){
					  $tagclass = 910;
					}
				  }
				elsif(exists $profHash{$lCaseString})
				  {
					$tagclass =460;
				  }
				elsif(exists $sportHash{$compareString})
				  {
					$tagclass =630;
				  }
				#check to see if it is in the list
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $countryHash{$tailString}))
				  {
					$tagclass = 830; 
				  }
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $riverHash{$tailString}))
				  {
					$tagclass = 870; 
				  }
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $mountHash{$tailString}))
				  {
					$tagclass = 850; 
				  }
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $cityHash{$tailString}))
				  {
					$tagclass = 820; 
				  }
				elsif( exists $plantHash{$lCaseString})
				  {
					$tagclass = 360;
				  }
				elsif( exists $universityHash{$compareString})
				  {
					$tagclass = 400;
				  }
				elsif(exists $unitHash{$compareString})
				  {
					$tagclass = 910;
				  }
				elsif(exists $festdayHash{$compareString})
				  {
					$tagclass = 220;
				  }
				elsif( exists $artworkHash{$compareString})
				  {
					$tagclass = 690;
				  }
				elsif( exists $bookHash{$compareString})
				  {
					$tagclass = 610;
				  }
				elsif( exists $cityHash{$compareString})
				  {
					$tagclass = 820;
				  }
				elsif( exists $foodHash{$lCaseString})
				  {
					$tagclass = 660;
				  }
				elsif( exists $buildingHash{$compareString})
				  {
					$tagclass = 840;
				  }
				elsif( exists $journalHash{$lCaseString})
				  {
					$tagclass = 620;
				  }
				elsif( exists $creatgroupHash{$compareString})
				  {
					$tagclass = 380;
				  }
				elsif(exists $eventHash{$compareString})
				  {
					$tagclass = 230;
				  }
				elsif(exists $teamHash{$compareString})
				  {
					$tagclass = 410;
				  }
				elsif(exists $stateHash{$compareString})
				  {
					$tagclass = 880;
				  }
				elsif (exists $religionHash{$compareString})
				  {
					$tagclass = 10;
				  }
				elsif(exists $langHash{$compareString})
				  {
					$tagclass = 270;
				  }
				elsif( exists $performHash{$compareString})
				  {
					$tagclass = 240;
				  }
				elsif( exists $riverHash{ $compareString})
				  {
					$tagclass = 870;
				  }
				elsif( exists $mountHash{ $compareString})
				  {
					$tagclass = 850;
				  }
				elsif( exists $polBodyHash{$compareString})
				  {
					$tagclass = 420;
				  }
				elsif( exists $medicalHash{$compareString})
				  {
					$tagclass = 640;
				  }
				elsif( exists $peopleHash{$compareString})
				  {
					$tagclass = 320;
				  }
				elsif( exists $animalHash{$lCaseString})
				  {
					$tagclass = 310;
				  }
				elsif( exists $currencyHash{$compareString})
				  {
					$tagclass = 1000;
				  }
				elsif( exists $countryHash{$compareString})
				  {
					$tagclass = 830;
				  }
				elsif( exists $corporationHash{$compareString})
				  {
					$tagclass = 370;
				  }
				elsif( exists $locHash{$compareString})
				  {
					$tagclass = 8000;
				  }

				if($tagclass != 0){
				  $taglist[$i]= $tagclass;
				  for($j= ($i+1) ; $j<= ($i+2); $j++)
					{
					  #for now assume 1 is the mark
					  $taglist[$j] = ($tagclass+1);
					  
					}
				  $i = $j -1;
				}
			  }
			else
			  {
				#look of the next index
				for($j= $i; $j <= ($i+2); $j++)
				  {
					if($taglist[$j] != 0){
					  $i = $j;
					}
				  }
			  }	
		  }
		#inside window 3
	  }
####################################################################
#Case where window is 2
	if($#orgWordlist > 2)
	  {
		for($i = 0; $i <= ($#orgWordlist-1); $i++)
		  {
			$head = $orgWordlist[$i];
			$tailString = $orgWordlist[$i+1];
			$compareString =$orgWordlist[$i]." ".$orgWordlist[$i+1];
			$checksum = $taglist[$i]+$taglist[$i+1];
			$lCaseString = lc($compareString);
			$uCaseString = uc($compareString);
			if($checksum == 0)
			  {
				$tagclass =0;
				$compareString =~ m/^(\w+\.*)\s\d{1,4}/;
				$month = $1;
				
				if( exists $dateHash{$month})
				  {
					#print "DATE -2- !!!!!!!!!!!!!!\n";
					#print "$compareString\n";
					$tagclass = 960;
				  }
				elsif( $compareString =~ m:^\d+\S*\syears?:)
				  {
					$tagclass = 900;
				  }
				elsif( $compareString =~ m:^(\d+\.?/*\d*)\sweeks?:)
				  {
					$tagclass = 900;
				  }
				elsif( $compareString =~ m:^(\d+\.?/*\d*)\smonths?:)
				  {
					$tagclass = 900;
				  }
				elsif( $compareString =~ m:^(\d+\.?/*\d*)\sdays?:)
				  {
					$tagclass = 900;
				  }
				elsif( $compareString =~ m:^(\d+\.?/*\d*)\shours?:)
				  {
					$tagclass = 900;
				  }
				elsif( $compareString =~ m:^(\d+\.?/*\d*)\sminutes?:)
				  {
					$tagclass = 900;
				  }
				elsif( $compareString =~ m:^(\d+\.?/*\d*)\sseconds?:)
				  {
					$tagclass = 900;
				  }
				elsif( $compareString =~ m:^(\d+\.?/*\d*)\smin\.?:)
				  {
					$tagclass = 900;
				  }
				elsif( $compareString =~ m:^(\d+\.?/*\d*)\ssec\.?:)
				  {
					$tagclass = 900;
				  }
				elsif( $compareString =~ m:^(\d+\.?/*\d*)\shr:)
				  {
					$tagclass = 900;
				  }
				elsif( $compareString =~ m:^(\d+\.?/*\d*)\sunit:)
				  {
					$tagclass = 900;
				  }
				elsif( $compareString =~ m:^(\d+\.?/*\d*)\spercent:)
				  {
					$tagclass = 1020;
				  }
				elsif( $compareString =~ m:^(\d+\.?/*\d*)\sdollars?:i)
				  {
					$tagclass = 1000;
				  }
				elsif( $compareString =~ m:^(\d+\.?/*\d*)\spounds?:i)
				  {
					$tagclass = 1000;
				  }
				elsif( $compareString =~ m:^(\d+\.?/*\d*)\syens?:i)
				  {
					$tagclass = 1000;
				  }
				elsif( $compareString =~ m:^(\d+\.?/*\d*)\spercentages?:)
				  {
					$tagclass = 1020;
				  }
				elsif( $compareString =~ m/^(\(\d{3,3}\)\s\d{3,3}-\d{4,4})$/)
				  {
					$tagclass = 930;
				  }
				elsif( $compareString =~ m/^Dollars\s(\d+.*)/i)
				  {
					$tagclass = 1000
				  } 
				elsif( $compareString =~ m/^([A-Za-z]+Dollars)\s(\d+.*)/i)
				  {
					$tagclass = 1000;
				  }
				elsif( $compareString =~ m/^Pounds\s(\d+.*)/i)
				  {
					$tagclass = 1000;
				  }
				elsif( $compareString =~ m/^NZDollars\s(\d+.*)/i)
				  {
					$tagclass = 1000;
				  }
				elsif( $compareString =~ m/^Yen\s(\d+.*)/i)
				  {
					$tagclass = 1000;
				  } 
				elsif( $compareString =~ m/^(\d{1,2})\s([pa]\.m\.?)/i)
				  {
					$tagclass = 950;
				  }
				elsif( $compareString =~ m/^\d+\.?\d*\s(.*)/)
				  {
					if(exists $unitHash{$1}){
					  $tagclass = 910;
					}
				  }
				elsif( $compareString =~ m/^\d+\.?\d*(.*)/)
				  {
					if (exists $unitHash{$1}){
					  $tagclass = 910;
					}
				  }
				#check to see if it is in the list
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $countryHash{$tailString}))
				  {
					$tagclass = 830; 
				  }
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $riverHash{$tailString}))
				  {
					$tagclass = 870; 
				  }
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $mountHash{$tailString}))
				  {
					$tagclass = 850; 
				  }
				elsif( ($head =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/) && (exists $cityHash{$tailString}))
				  {
					$tagclass = 820; 
				  }
				elsif( exists $plantHash{$lCaseString})
				  {
					$tagclass = 360;
				  }
				elsif(exists $sportHash{$compareString})
				  {
					$tagclass =630;
				  }
				elsif( exists $universityHash{$compareString})
				  {
					$tagclass = 400;
				  }
				elsif(exists $profHash{$lCaseString})
				  {
					$tagclass =460;
				  }
				elsif(exists $unitHash{$compareString})
				  {
					$tagclass = 910;
				  }
				elsif(exists $festdayHash{$compareString})
				  {
					$tagclass = 220;
				  }
				elsif( exists $artworkHash{$compareString})
				  {
					$tagclass = 690;
				  }
				elsif( exists $bookHash{$compareString})
				  {
					$tagclass = 610;
				  }
				elsif( exists $cityHash{$compareString})
				  {
					$tagclass = 820;
				  }
				elsif( exists $foodHash{$lCaseString})
				  {
					$tagclass = 660;
				  }
				elsif( exists $buildingHash{$compareString})
				  {
					$tagclass = 840;
				  }
				elsif( exists $journalHash{$lCaseString})
				  {
					$tagclass = 620;
				  }
				elsif( exists $creatgroupHash{$compareString})
				  {
					$tagclass = 380;
				  }
				elsif(exists $eventHash{$compareString})
				  {
					$tagclass = 230;
				  }
				elsif(exists $teamHash{$compareString})
				  {
					$tagclass = 410;
				  }
				elsif(exists $stateHash{$compareString})
				  {
					$tagclass = 880;
				  }
				elsif (exists $religionHash{$compareString})
				  {
					$tagclass = 10;
				  }
				elsif(exists $langHash{$compareString})
				  {
					$tagclass = 270;
				  }
				elsif( exists $performHash{$compareString})
				  {
					$tagclass = 240;
				  }
				elsif( exists $riverHash{ $compareString})
				  {
					$tagclass = 870;
				  }
				elsif( exists $mountHash{ $compareString})
				  {
					$tagclass = 850;
				  }
				elsif( exists $polBodyHash{$compareString})
				  {
					$tagclass = 420;
				  }
				elsif( exists $medicalHash{$compareString})
				  {
					$tagclass = 640;
				  }
				elsif( exists $peopleHash{$compareString})
				  {
					$tagclass = 320;
				  }
				elsif( exists $animalHash{$lCaseString})
				  {
					$tagclass = 310;
				  }
				elsif( exists $currencyHash{$compareString})
				  {
					$tagclass = 1000;
				  }
				elsif( exists $countryHash{$compareString})
				  {
					$tagclass = 830;
				  }
				elsif( exists $corporationHash{$compareString})
				  {
					$tagclass = 370;
				  }
				elsif( exists $locHash{$compareString})
				  {
					$tagclass = 8000;
				  }
				if($tagclass != 0){
				  $taglist[$i] = $tagclass;
				  $taglist[$i+1] = $tagclass+1;					  
				  $i = $i+1;
				}
			  }
			else
			  {
				#look of the next index
				for($j= $i; $j <= ($i+1); $j++)
				  {
					if($taglist[$j] != 0){
					  $i = $j;
					}
				  }
			  }	
		  }
		#inside window 2
	  }
#######################################################################
#Case where window is 1
	if($#orgWordlist >= 1)
	  {
		for($i = 0; $i <= $#orgWordlist; $i++)
		  {
			$compareString =$orgWordlist[$i];
			$checksum = $taglist[$i];
			$lCaseString = lc($compareString);
			$uCaseString = uc($compareString);
			if($checksum == 0)
			  {
				$tagclass =0;
				$yearString = $compareString." ";
				if( exists $dateHash{$compareString})
				  {
					#print"Date -3- !!!!!!!!!!!!\n";
					#print"$compareString\n";
					$tagclass = 960;
				  }
				elsif( $compareString =~ m/([Ss]outh)|([Nn]orth)|([Ww]est)|([Ee]ast)/ )
				  {
					$tagclass =8000; 
				  }
				elsif($compareString =~ m/^(\d{5,5})$/)
				  {
					$tagclass = 920;
				  }
				elsif(($compareString =~ m/(^[A-Z]\w*)-(.*)/) && (exists $corporationHash{$1} || exists $corporationHash{$2}))
				  {
					$tagclass =370;
				  } 
				elsif($compareString =~ m/^(\d{5,5}-\d{4,4})$/)
				  {
					$tagclass = 920;
				  }
				elsif( $compareString =~ m/(\$)/)
				  {
					$tagclass =1000;
				  }  
				elsif( $compareString =~ m/^([A-Z]+[a-z]*\d+)/)
				  {
					$tagclass = 1000;
				  }  
				elsif( $compareString =~ m/^\d+.*%$/)
				  {
					$tagclass = 1020;
				  }  
				elsif( $yearString =~ m/(^\d{4,4}\s)/ || $yearString =~ m/(^\d{4,4}s)\s/ || $yearString =~ m/(^\d{4,4}-\d+)\s/ )
				  {
					#print"Date -4- !!!!!!!!!!!!!!\n";
					#print"$compareString\n";
					$tagclass = 960;
				  }
				elsif( ($compareString =~ m/^\d+\.?\d*(.*)/) && (exists $unitHash{$1}))
				  {
					  $tagclass = 910;
				  }
 
				#check to see if it is in the list
				elsif( exists $dayHash{$compareString})
				  {
					$tagclass = 960;
				  }
				elsif( exists $plantHash{$lCaseString})
				  {
					$tagclass = 360;
				  }
				elsif(exists $sportHash{$compareString})
				  {
					$tagclass =630;
				  }
				elsif(exists $colorHash{$compareString})
				  {
					$tagclass =600;
				  }
				elsif(exists $profHash{$lCaseString})
				  {
					$tagclass =460;
				  }
				elsif(exists $numberHash{$lCaseString})
				  {
					$tagclass =900;
				  }
				elsif( exists $universityHash{$compareString})
				  {
					$tagclass = 400;
				  }
				elsif(exists $unitHash{$compareString})
				  {
					$tagclass = 910;
				  }
				elsif(exists $festdayHash{$compareString})
				  {
					$tagclass = 220;
				  }
				elsif( exists $artworkHash{$compareString})
				  {
					$tagclass = 690;
				  }
				elsif( exists $bookHash{$compareString})
				  {
					$tagclass = 610;
				  }
				elsif( exists $cityHash{$compareString})
				  {
					$tagclass = 820;
				  }
				elsif( exists $foodHash{$lCaseString})
				  {
					$tagclass = 660;
				  }
				elsif( exists $buildingHash{$compareString})
				  {
					$tagclass = 840;
				  }
				elsif( exists $journalHash{$lCaseString})
				  {
					$tagclass = 620;
				  }
				elsif( exists $creatgroupHash{$compareString})
				  {
					$tagclass = 380;
				  }
				elsif(exists $eventHash{$compareString})
				  {
					$tagclass = 230;
				  }
				elsif(exists $teamHash{$compareString})
				  {
					$tagclass = 410;
				  }
				elsif(exists $stateHash{$compareString})
				  {
					$tagclass = 880;
				  }
				elsif (exists $religionHash{$compareString})
				  {
					$tagclass = 10;
				  }
				elsif(exists $langHash{$compareString})
				  {
					$tagclass = 270;
				  }
				elsif( exists $performHash{$compareString})
				  {
					$tagclass = 240;
				  }
				elsif(exists $dateHash{$compareString})
				  {
					#print"DATE -5- -------------\n";
					#print"$compareString\n";
					$tagclass = 960;
				  }
				elsif( exists $riverHash{ $compareString})
				  {
					$tagclass = 870;
				  }
				elsif( exists $mountHash{ $compareString})
				  {
					$tagclass = 850;
				  }
				elsif( exists $polBodyHash{$compareString})
				  {
					$tagclass = 420;
				  }
				elsif( exists $medicalHash{$compareString})
				  {
					$tagclass = 640;
				  }
				elsif( exists $peopleHash{$compareString})
				  {
					$tagclass = 320;
				  }
				elsif( exists $animalHash{$lCaseString})
				  {
					$tagclass = 310;
				  }
				elsif( exists $currencyHash{$compareString})
				  {
					$tagclass = 1000;
				  }
				elsif( exists $countryHash{$compareString})
				  {
					$tagclass = 830;
				  }
				elsif( exists $corporationHash{$compareString})
				  {
					$tagclass = 370;
				  }
				elsif( exists $locHash{$compareString})
				  {
					$tagclass = 8000;
				  }
				elsif( $compareString =~ m/^\d/ )
				  { # all the left over case
					$tagclass = 900;
				  }
					
					$taglist[$i] = $tagclass;
			  }
		  }
		#inside window 1
	  }
	###############################################################
	#converting taglist into printable line
	#except for the last index becasue we concat a extra . 
	$printline="";
	for($i = 0; $i< $#taglist; $i++)
	  {
		if($taglist[$i] == 0){
		  $printline =$printline." $orgWordlist[$i]";
		}
		elsif($taglist[$i] == 220){
		  $printline =$printline." [ B-DayFest $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 221){
		  $printline =$printline." [ I-DayFest $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 230){
		  $printline =$printline." [ B-Event $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 231){
		  $printline =$printline." [ I-Event $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 240){
		  $printline =$printline." [ B-Perform $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 241){
		  $printline =$printline." [ I-Perform $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 270){
		  $printline =$printline." [ B-LangRace $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 271){
		  $printline =$printline." [ I-LangRace $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 310){
		  $printline =$printline." [ B-Animal $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 311){
		  $printline =$printline." [ I-Animal $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 320){
		  $printline =$printline." [ B-Peop $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 321){
		  $printline =$printline." [ I-Peop $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 360){
		  $printline =$printline." [ B-Plant $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 361){
		  $printline =$printline." [ I-Plant $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 370){
		  $printline =$printline." [ B-OrgCorp $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 371){
		  $printline =$printline." [ I-OrgCorp $orgWordlist[$i] ]";
		}
	  	elsif($taglist[$i] == 380){
		  $printline =$printline." [ B-OrgCGroup $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 381){
		  $printline =$printline." [ I-OrgCGroup $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 400){
		  $printline =$printline." [ B-OrgUniv $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 401){
		  $printline =$printline." [ I-OrgUniv $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 410){
		  $printline =$printline." [ B-OrgTeam $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 411){
		  $printline =$printline." [ I-OrgTeam $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 420){
		  $printline =$printline." [ B-OrgPolBody $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 421){
		  $printline =$printline." [ I-OrgPolBody $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 460){
		  $printline =$printline." [ B-ProfTitle $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 461){
		  $printline =$printline." [ I-ProfTitle $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 600){
		  $printline =$printline." [ B-Color $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 601){
		  $printline =$printline." [ I-Color $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 610){
		  $printline =$printline." [ B-Book $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 611){
		  $printline =$printline." [ I-Book $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 620){
		  $printline =$printline." [ B-Jour $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 621){
		  $printline =$printline." [ I-Jour $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 630){
		  $printline =$printline." [ B-Sport $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 631){
		  $printline =$printline." [ I-Sport $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 640){
		  $printline =$printline." [ B-Medical $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 641){
		  $printline =$printline." [ I-Medical $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 660){
		  $printline =$printline." [ B-Food $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 661){
		  $printline =$printline." [ I-Food $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 820){
		  $printline =$printline." [ B-LocCit $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 821){
		  $printline =$printline." [ I-LocCit $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 830){
		  $printline =$printline." [ B-LocCoun $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 831){
		  $printline =$printline." [ I-LocCoun $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 840){
		  $printline =$printline." [ B-LocStruct $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 841){
		  $printline =$printline." [ I-LocStruct $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 850){
		  $printline =$printline." [ B-LocMount $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 851){
		  $printline =$printline." [ I-LocMount $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 870){
		  $printline =$printline." [ B-LocRiver $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 871){
		  $printline =$printline." [ I-LocRiver $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 880){
		  $printline =$printline." [ B-LocStat $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 881){
		  $printline =$printline." [ I-LocStat $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 900){
		  $printline =$printline." [ B-Num $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 901){
		  $printline =$printline." [ I-Num $orgWordlist[$i] ]";
		}	
		elsif($taglist[$i] == 910){
		  $printline =$printline." [ B-NumUnit $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 911){
		  $printline =$printline." [ I-NumUnit $orgWordlist[$i] ]";
		}	
		elsif($taglist[$i] == 920){
		  $printline =$printline." [ B-NumZip $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 921){
		  $printline =$printline." [ I-NumZip $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 930){
		  $printline =$printline." [ B-NumPhone $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 931){
		  $printline =$printline." [ I-NumPhone $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 950){
		  $printline =$printline." [ B-NumTime $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 951){
		  $printline =$printline." [ I-NumTime $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 960){

		  #print "####PRINTING  B-DATE ##########\n";
		  $printline =$printline." [ B-Date $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 961){
		  #print "#######PRINTING I-DATE #########\n";
		  $printline =$printline." [ I-Date $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 1000){
		  $printline =$printline." [ B-Money $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 1001){
		  $printline =$printline." [ I-Money $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 1020){
		  $printline =$printline." [ B-NumPercent $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 1021){
		  $printline =$printline." [ I-NumPercent $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] ==8000 ){
		  $printline =$printline." [ B-Loc $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] ==8001 ){
		  $printline =$printline." [ I-Loc $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 3000){
		  $printline =$printline." [ B-Org $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 3000){
		  $printline =$printline." [ I-Org $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 690){
		  $printline =$printline." [ B-Art $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 691){
		  $printline =$printline." [ I-Art $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 10){
		  $printline =$printline." [ B-Religion $orgWordlist[$i] ]";
		}
		elsif($taglist[$i] == 11){
	  $printline =$printline." [ I-Religion $orgWordlist[$i] ]";
		}
	  }
	###############################################################
	$printline =~ s/^\s+//;
	print $writefile "$printline\n";
  
	$count++;
	if(($count == 1000) && (@ARGV >2))
	  {
		print "writen ".$number."000 of lines.\n";
		$count = 1;
		$number++;
		close($writefile);
		open ($writefile, ">>$ARGV[1]") || die "Can't create file. ";
  }
	@orgWordlist= ();
	@taglist =();
	#inside while loop	
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
close (datafile);
close (medical);
close ($writefile);

