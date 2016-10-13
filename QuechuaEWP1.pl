#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

my @persons = qw(1S 1PE 1PI 2S 2P 3S 3P);
my @tenses  = qw(past pres fut);

for my $tense (@tenses) {
	for my $subject (@persons) {
		for my $object (@persons) {
		
			next unless &illogical($subject, $object);
		
			my ($sMe, $oMe, $sYou, $oYou, $sPl, $oPl, $refl) = parameters($subject, $object);
			my $guess = "";
			next if $refl;
			
		 	# Block 1
			if ($oMe) {
				$guess .= "wa";
			}
			
			# Block 2
			if ($tense eq 'past') {
				$guess .= "rqa";
			}
			
			# Block 3
			if ($tense eq 'fut' && (($sYou && $sMe) || ($oMe && $oYou))) {
				$guess .= "su";
			} elsif ($tense eq 'fut' && $sMe && $oYou && $oPl) {
				$guess .= "sqa";
			} elsif (!defined $sMe && !defined $oMe && $oYou) {
				$guess .= "su";
			} elsif ($tense eq 'fut' && $sMe && $oYou ) {
				$guess .= "sqa"; # This q is optional
			} elsif ($tense eq 'fut' && $sMe) {
				$guess .= "sa";

			}
			
			
			# Block 4
			if ($tense eq 'past' && !defined $sMe && !defined $sYou && !defined $oYou) {
				# do nothing
			} elsif ($tense eq 'fut' && $sMe && !defined $sPl && !defined $oYou) {
				$guess .= "q";
			} elsif ($sMe && !defined $sPl && !defined $oYou) {
				$guess .= "ni";
			} elsif ($sMe && !defined $sYou) {
				$guess .= "y";
			} else {
				$guess .= "n";
			}
			
			# Block 5
			if ($tense eq 'fut' && !defined $sYou && !defined $sMe && !defined $oYou) {
			 	$guess .= "qa";
			} elsif ((!defined $sMe && $sYou) || (!defined $oMe && $oYou)) {
				$guess .= "ki";
			}
		
			# Block 6
			if ($tense eq 'past' && !defined $sMe && $sPl && $oYou && !defined $oPl) {
				#do nothing (this can be removed if 3P>2S (past) is "rqasunkiku" instead of "rqasunki".
			} elsif ($tense eq 'past' && $sYou && !defined $sPl && $oMe && $oPl) {
				$guess .= "chis"; # 2S>1PE (past). If it turns out it's "warqankiku" instead of "warqankichis", you can change not the next but the rule after that.
			} elsif ($tense eq 'fut' && $sMe && !defined $sPl && $oPl) {
				$guess .= "ku";
			} elsif ($tense eq 'past' && $sMe && !defined $sYou && $sPl) {
				$guess .= "ku";
			} elsif (($sYou && $sPl) || ($oYou && $oPl)) {
				$guess .= "chis";
			} elsif (($sMe && $sPl) || ($oMe && $oPl)) {
				$guess .= "ku";
			} elsif ($sPl) {
				$guess .= "ku";
			}
		
			# Print the correct ones.
			my $correct = &correct($tense, $subject, $object);		
			my $score = &score($correct, $guess);
		
		
			my $format = "%-5s%-10s%-13s%-13s%-1s\n";
			printf ($format, $tense, "$subject->$object", $guess, $correct, $score);
		
		}
		print "\n";
	}
}

sub illogical {
	my ($subject, $object) = @_;
	
	# Get rid of illogical combinations
	return if $subject eq "1S"  && $object eq "1PE";
	return if $subject eq "1S"  && $object eq "1PI";
	return if $subject eq "1PE" && $object eq "1S";
	return if $subject eq "1PE" && $object eq "1PI";
	return if $subject eq "1PI" && $object eq "1S";
	return if $subject eq "1PI" && $object eq "1PE";
	return if $subject eq "1PI" && $object eq "2S";
	return if $subject eq "1PI" && $object eq "2P";
	return if $subject eq "2S"  && $object eq "1PI";
	return if $subject eq "2S"  && $object eq "2P";
	return if $subject eq "2P"  && $object eq "1PI";
	return if $subject eq "2P"  && $object eq "2S";
	
	# If we're still here, return a good value;
	return 1;
}
sub parameters {
	my ($subject, $object) = @_;
	
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $refl);
	
	if    ($subject eq "1S" ) { $sMe           =1 }
	elsif ($subject eq "1PE") { $sMe      =$sPl=1 }
	elsif ($subject eq "1PI") { $sMe=$sYou=$sPl=1 }
	elsif ($subject eq "2S" ) { 	 $sYou     =1 }
	elsif ($subject eq "2P" ) {      $sYou=$sPl=1 }
	elsif ($subject eq "3S" ) {                   }
	elsif ($subject eq "3P" ) {            $sPl=1 }
	
	if    ($object eq "1S" ) { $oMe           =1 }
	elsif ($object eq "1PE") { $oMe      =$oPl=1 }
	elsif ($object eq "1PI") { $oMe=$oYou=$oPl=1 }
	elsif ($object eq "2S" ) { 	    $oYou     =1 }
	elsif ($object eq "2P" ) {      $oYou=$oPl=1 }
	elsif ($object eq "3S" ) {                   }
	elsif ($object eq "3P" ) {            $oPl=1 }

 	if ($subject eq $object && $subject !~ /3/) { $refl = 1 }
	
	return ($sMe, $oMe, $sYou, $oYou, $sPl, $oPl, $refl);
}
sub correct {
	my ($tense, $subject, $object) = @_;

	my $correct = "";
	
	if ($tense eq 'past') {
		if      ($subject eq '1S' && $object eq '1S')  { $correct = "kurqani";
		} elsif ($subject eq '1S' && $object eq '1PE') { $correct = "NA";
		} elsif ($subject eq '1S' && $object eq '1PI') { $correct = "NA";
		} elsif ($subject eq '1S' && $object eq '2S')  { $correct = "rqayki";
		} elsif ($subject eq '1S' && $object eq '2P')  { $correct = "rqaykichis";
		} elsif ($subject eq '1S' && $object eq '3S')  { $correct = "rqani";
		} elsif ($subject eq '1S' && $object eq '3P')  { $correct = "rqani";
	
		} elsif ($subject eq '1PE' && $object eq '1S')  { $correct = "NA";
		} elsif ($subject eq '1PE' && $object eq '1PE') { $correct = "kurqayku";
		} elsif ($subject eq '1PE' && $object eq '1PI') { $correct = "NA";
		} elsif ($subject eq '1PE' && $object eq '2S')  { $correct = "rqaykiku";
		} elsif ($subject eq '1PE' && $object eq '2P')  { $correct = "rqaykiku"; # not sure
		} elsif ($subject eq '1PE' && $object eq '3S')  { $correct = "rqayku";
		} elsif ($subject eq '1PE' && $object eq '3P')  { $correct = "rqayku";
		
		} elsif ($subject eq '1PI' && $object eq '1S')  { $correct = "NA";
		} elsif ($subject eq '1PI' && $object eq '1PE') { $correct = "NA";
		} elsif ($subject eq '1PI' && $object eq '1PI') { $correct = "kurqanchis";
		} elsif ($subject eq '1PI' && $object eq '2S')  { $correct = "NA";
		} elsif ($subject eq '1PI' && $object eq '2P')  { $correct = "NA";
		} elsif ($subject eq '1PI' && $object eq '3S')  { $correct = "rqanchis";
		} elsif ($subject eq '1PI' && $object eq '3P')  { $correct = "rqanchis";
			
		} elsif ($subject eq '2S' && $object eq '1S')  { $correct = "warqanki";
		} elsif ($subject eq '2S' && $object eq '1PE') { $correct = "warqankichis"; #warqankiku maybe. I don't have my notes
		} elsif ($subject eq '2S' && $object eq '1PI') { $correct = "NA";
		} elsif ($subject eq '2S' && $object eq '2S')  { $correct = "kurqanki";
		} elsif ($subject eq '2S' && $object eq '2P')  { $correct = "NA";
		} elsif ($subject eq '2S' && $object eq '3S')  { $correct = "rqanki";
		} elsif ($subject eq '2S' && $object eq '3P')  { $correct = "rqanki";
		
		} elsif ($subject eq '2P' && $object eq '1S')  { $correct = "warqankichis";
		} elsif ($subject eq '2P' && $object eq '1PE') { $correct = "warqankichis";
		} elsif ($subject eq '2P' && $object eq '1PI') { $correct = "NA";
		} elsif ($subject eq '2P' && $object eq '2S')  { $correct = "NA";
		} elsif ($subject eq '2P' && $object eq '2P')  { $correct = "kurqankichis";
		} elsif ($subject eq '2P' && $object eq '3S')  { $correct = "rqankichis";
		} elsif ($subject eq '2P' && $object eq '3P')  { $correct = "rqankichis";
		
		} elsif ($subject eq '3S' && $object eq '1S')  { $correct = "warqa"; # dropped n
		} elsif ($subject eq '3S' && $object eq '1PE') { $correct = "warqaku"; # dropped n
		} elsif ($subject eq '3S' && $object eq '1PI') { $correct = "warqanchis";
		} elsif ($subject eq '3S' && $object eq '2S')  { $correct = "rqasunki";
		} elsif ($subject eq '3S' && $object eq '2P')  { $correct = "rqasunkichis";
		#} elsif ($subject eq '3S' && $object eq '3S')  { $correct = "kurqa"; # dropped n
		} elsif ($subject eq '3S' && $object eq '3S')  { $correct = "rqa"; # dropped n
		} elsif ($subject eq '3S' && $object eq '3P')  { $correct = "rqa"; # dropped n
	
		} elsif ($subject eq '3P' && $object eq '1S')  { $correct = "warqaku"; # dropped n
		} elsif ($subject eq '3P' && $object eq '1PE') { $correct = "warqaku"; # dropped n
		} elsif ($subject eq '3P' && $object eq '1PI') { $correct = "warqanchis";
		} elsif ($subject eq '3P' && $object eq '2S')  { $correct = "rqasunki";
		} elsif ($subject eq '3P' && $object eq '2P')  { $correct = "rqasunkichis";
		} elsif ($subject eq '3P' && $object eq '3S')  { $correct = "rqaku"; # dropped n
		#} elsif ($subject eq '3P' && $object eq '3P')  { $correct = "kurqaku"; # dropped n
		} elsif ($subject eq '3P' && $object eq '3P')  { $correct = "rqaku"; # dropped n
	
		} else { $correct = "Error" }
	} elsif ($tense eq 'pres') {
		if      ($subject eq '1S' && $object eq '1S')  { $correct = "kuni";
		} elsif ($subject eq '1S' && $object eq '1PE') { $correct = "NA";
		} elsif ($subject eq '1S' && $object eq '1PI') { $correct = "NA";
		} elsif ($subject eq '1S' && $object eq '2S')  { $correct = "yki";
		} elsif ($subject eq '1S' && $object eq '2P')  { $correct = "ykichis";
		} elsif ($subject eq '1S' && $object eq '3S')  { $correct = "ni";
		} elsif ($subject eq '1S' && $object eq '3P')  { $correct = "ni";
	
		} elsif ($subject eq '1PE' && $object eq '1S')  { $correct = "NA";
		} elsif ($subject eq '1PE' && $object eq '1PE') { $correct = "kuyku";
		} elsif ($subject eq '1PE' && $object eq '1PI') { $correct = "NA";
		} elsif ($subject eq '1PE' && $object eq '2S')  { $correct = "ykiku";
		} elsif ($subject eq '1PE' && $object eq '2P')  { $correct = "ykichis";
		} elsif ($subject eq '1PE' && $object eq '3S')  { $correct = "yku";
		} elsif ($subject eq '1PE' && $object eq '3P')  { $correct = "yku";
		
		} elsif ($subject eq '1PI' && $object eq '1S')  { $correct = "NA";
		} elsif ($subject eq '1PI' && $object eq '1PE') { $correct = "NA";
		} elsif ($subject eq '1PI' && $object eq '1PI') { $correct = "kunchis";
		} elsif ($subject eq '1PI' && $object eq '2S')  { $correct = "NA";
		} elsif ($subject eq '1PI' && $object eq '2P')  { $correct = "NA";
		} elsif ($subject eq '1PI' && $object eq '3S')  { $correct = "nchis";
		} elsif ($subject eq '1PI' && $object eq '3P')  { $correct = "nchis";
			
		} elsif ($subject eq '2S' && $object eq '1S')  { $correct = "wanki";
		} elsif ($subject eq '2S' && $object eq '1PE') { $correct = "wankiku";
		} elsif ($subject eq '2S' && $object eq '1PI') { $correct = "NA";
		} elsif ($subject eq '2S' && $object eq '2S')  { $correct = "kunki";
		} elsif ($subject eq '2S' && $object eq '2P')  { $correct = "NA";
		} elsif ($subject eq '2S' && $object eq '3S')  { $correct = "nki";
		} elsif ($subject eq '2S' && $object eq '3P')  { $correct = "nki";
		
		} elsif ($subject eq '2P' && $object eq '1S')  { $correct = "wankichis";
		} elsif ($subject eq '2P' && $object eq '1PE') { $correct = "wankichis";
		} elsif ($subject eq '2P' && $object eq '1PI') { $correct = "NA";
		} elsif ($subject eq '2P' && $object eq '2S')  { $correct = "NA";
		} elsif ($subject eq '2P' && $object eq '2P')  { $correct = "kunkichis";
		} elsif ($subject eq '2P' && $object eq '3S')  { $correct = "nkichis";
		} elsif ($subject eq '2P' && $object eq '3P')  { $correct = "nkichis";
		
		} elsif ($subject eq '3S' && $object eq '1S')  { $correct = "wan";
		} elsif ($subject eq '3S' && $object eq '1PE') { $correct = "wanku";
		} elsif ($subject eq '3S' && $object eq '1PI') { $correct = "wanchis";
		} elsif ($subject eq '3S' && $object eq '2S')  { $correct = "sunki";
		} elsif ($subject eq '3S' && $object eq '2P')  { $correct = "sunkichis";
		#} elsif ($subject eq '3S' && $object eq '3S')  { $correct = "kun";
		} elsif ($subject eq '3S' && $object eq '3S')  { $correct = "n";
		} elsif ($subject eq '3S' && $object eq '3P')  { $correct = "n"; # not sure
	
		} elsif ($subject eq '3P' && $object eq '1S')  { $correct = "wanku";
		} elsif ($subject eq '3P' && $object eq '1PE') { $correct = "wanku";
		} elsif ($subject eq '3P' && $object eq '1PI') { $correct = "wanchis";
		} elsif ($subject eq '3P' && $object eq '2S')  { $correct = "sunkiku";
		} elsif ($subject eq '3P' && $object eq '2P')  { $correct = "sunkichis";
		} elsif ($subject eq '3P' && $object eq '3S')  { $correct = "nku"; # not sure
		#} elsif ($subject eq '3P' && $object eq '3P')  { $correct = "kunku";
		} elsif ($subject eq '3P' && $object eq '3P')  { $correct = "nku";
	
		} else { $correct = "Error" }
	} elsif ($tense eq 'fut') {
		if      ($subject eq '1S' && $object eq '1S')  { $correct = "kusaq";
		} elsif ($subject eq '1S' && $object eq '1PE') { $correct = "NA";
		} elsif ($subject eq '1S' && $object eq '1PI') { $correct = "NA";
		} elsif ($subject eq '1S' && $object eq '2S')  { $correct = "sqayki"; # q is optional
		} elsif ($subject eq '1S' && $object eq '2P')  { $correct = "sqaykiku";
		} elsif ($subject eq '1S' && $object eq '3S')  { $correct = "saq";
		} elsif ($subject eq '1S' && $object eq '3P')  { $correct = "saqku"; # questionable
	
		} elsif ($subject eq '1PE' && $object eq '1S')  { $correct = "NA";
		} elsif ($subject eq '1PE' && $object eq '1PE') { $correct = "kuyku";
		} elsif ($subject eq '1PE' && $object eq '1PI') { $correct = "NA";
		} elsif ($subject eq '1PE' && $object eq '2S')  { $correct = "sqaykiku"; # q is optional
		} elsif ($subject eq '1PE' && $object eq '2P')  { $correct = "sqaykichis";
		} elsif ($subject eq '1PE' && $object eq '3S')  { $correct = "sayku"; # sqayku?
		} elsif ($subject eq '1PE' && $object eq '3P')  { $correct = "sayku"; # sqayku?
		
		} elsif ($subject eq '1PI' && $object eq '1S')  { $correct = "NA";
		} elsif ($subject eq '1PI' && $object eq '1PE') { $correct = "NA";
		} elsif ($subject eq '1PI' && $object eq '1PI') { $correct = "kunchis";
		} elsif ($subject eq '1PI' && $object eq '2S')  { $correct = "NA";
		} elsif ($subject eq '1PI' && $object eq '2P')  { $correct = "NA";
		} elsif ($subject eq '1PI' && $object eq '3S')  { $correct = "sunchis";
		} elsif ($subject eq '1PI' && $object eq '3P')  { $correct = "sunchis";
			
		} elsif ($subject eq '2S' && $object eq '1S')  { $correct = "wanki";
		} elsif ($subject eq '2S' && $object eq '1PE') { $correct = "wankiku";
		} elsif ($subject eq '2S' && $object eq '1PI') { $correct = "NA";
		} elsif ($subject eq '2S' && $object eq '2S')  { $correct = "kunki";
		} elsif ($subject eq '2S' && $object eq '2P')  { $correct = "NA";
		} elsif ($subject eq '2S' && $object eq '3S')  { $correct = "nki";
		} elsif ($subject eq '2S' && $object eq '3P')  { $correct = "nki";
		
		} elsif ($subject eq '2P' && $object eq '1S')  { $correct = "wankichis";
		} elsif ($subject eq '2P' && $object eq '1PE') { $correct = "wankichis";
		} elsif ($subject eq '2P' && $object eq '1PI') { $correct = "NA";
		} elsif ($subject eq '2P' && $object eq '2S')  { $correct = "NA";
		} elsif ($subject eq '2P' && $object eq '2P')  { $correct = "kunkichis";
		} elsif ($subject eq '2P' && $object eq '3S')  { $correct = "nkichis";
		} elsif ($subject eq '2P' && $object eq '3P')  { $correct = "nkichis";
		
		} elsif ($subject eq '3S' && $object eq '1S')  { $correct = "wanqa";
		} elsif ($subject eq '3S' && $object eq '1PE') { $correct = "wanqaku"; # I have written down wasunchis, but I think that's wrong and it messes EVERYTHING up!
		} elsif ($subject eq '3S' && $object eq '1PI') { $correct = "wasunchis";
		} elsif ($subject eq '3S' && $object eq '2S')  { $correct = "sunki";
		} elsif ($subject eq '3S' && $object eq '2P')  { $correct = "sunkichis";
		#} elsif ($subject eq '3S' && $object eq '3S')  { $correct = "kunqa";
		} elsif ($subject eq '3S' && $object eq '3S')  { $correct = "nqa";
		} elsif ($subject eq '3S' && $object eq '3P')  { $correct = "nqa"; 
	
		} elsif ($subject eq '3P' && $object eq '1S')  { $correct = "wanqaku";
		} elsif ($subject eq '3P' && $object eq '1PE') { $correct = "wanqaku";
		} elsif ($subject eq '3P' && $object eq '1PI') { $correct = "wasunchis";
		} elsif ($subject eq '3P' && $object eq '2S')  { $correct = "sunkiku";
		} elsif ($subject eq '3P' && $object eq '2P')  { $correct = "sunkichis";
		} elsif ($subject eq '3P' && $object eq '3S')  { $correct = "nqaku";
		#} elsif ($subject eq '3P' && $object eq '3P')  { $correct = "kunqaku";
		} elsif ($subject eq '3P' && $object eq '3P')  { $correct = "nqaku";
	
		} else { $correct = "Error" }
	} else {
		$correct = "Error"	
	}	
	
	return $correct;
}
sub score {
	my ($correct, $guess) = @_;
	
	return "" if $guess eq "";
	
	return "ok" if $correct eq $guess;
	
	return "..." if $correct =~ $guess;
	
	return "X" if $correct !~ $guess;
	
}
sub presentTenseOnlyDumper {
# 			Block 1 (if I can put reflexive first, do that)
# 			if (!defined $sMe && !defined $sYou && !defined $oMe && $oYou) {
# 				$guess .= "su"; # 3>2
# 			} elsif ($refl) {
# 				$guess .= "ku"; # reflexive
# 			} elsif ($oMe) {
# 				$guess .= "wa"; # 1 obj
# 			}
# 
# 		
# 		
# 			Block 2
# 			if ($sMe && !defined $sYou && !defined $sPl && !defined $oYou) {
# 				$guess .= "ni"; # 1s > not 2
# 			} elsif ($sMe && !defined $sYou) {
# 				$guess .= "y"; # 1 subj
# 			} else {
# 				$guess .= "n"; # 2,3 subj
# 			}
# 		
# 		
# 			Block 3
# 			if (!defined $sMe && $sYou) { # Combine
# 				$guess .= "ki"; # 2nd person is involved
# 			} elsif (!defined $oMe && $oYou) { # Combine
# 				$guess .= "ki";
# 			}
# 		
# 		
# 			Block 4
# 			if ($sYou && $sPl) { # Combine
# 				$guess .= "chis"; # includes you & plural
# 			} elsif ($oYou && $oPl) { # Combine
# 				$guess .= "chis";
# 			} elsif ($oMe && $oPl) {
# 				$guess .= "ku"; # 1PE object (ish)
# 			} elsif ($sPl) {
# 				$guess .= "ku"; # plural subject, except 2nd person (ish)
# 			}
}
sub includingReflexivesDumper {
# 			Block 1: ku, wa, and future su
# 			if ($refl) {
# 				$guess .= "ku";
# 			} elsif ($tense eq 'fut' && $sMe && $sYou) {
# 				$guess .= "su";
# 			} elsif ($oMe) {
# 				$guess .= "wa";
# 			}
# 
# 
# 			Block 2: past tense
# 			if ($tense eq 'past') {
# 				$guess .= "rqa";
# 			} 
# 			
# 			Block 3: su, s(q)a
# 			if ($tense eq 'fut' && !defined $sMe && !defined $sYou && $oYou) {
# 				$guess .= "su";
# 			} elsif (!defined $sMe && !defined $sYou && $oYou && !defined $oMe) {
# 				$guess .= "su";
# 				
# 			} elsif ($tense eq 'fut' && $sMe && !defined $sYou && $sPl && !defined $oMe && !defined $oYou) {
# 				$guess .= "sa";
# 			} elsif ($tense eq 'fut' && $sMe && $oYou && !defined $oPl) {
# 				$guess .= "sqa"; # This q is optional
# 			} elsif ($tense eq 'fut' && $sMe && $oYou && !defined $oMe) {
# 				$guess .= "sqa";
# 			}
# 
# 		
# 			Block 4: n, ni, y
# 			if ($tense ne 'fut' && $sMe && !defined $sPl && !defined $oYou) {
# 				$guess .= "ni";
# 				
# 			} elsif ($sMe && !defined $sYou && $sPl) {
# 				$guess .= "y";
# 			} elsif ($sMe && !defined $sPl && $oYou) {
# 				$guess .= "y";
# 				
# 			} elsif ($sYou || $oYou) {
# 				$guess .= "n";
# 			} elsif ($tense ne 'past' && !defined $sMe && !defined $sYou) {
# 				$guess .= "n";
# 			}
# 			
# 			
# 			Block 5: ki, qa, saq
# 			if ($tense eq 'fut' && $sMe && !defined $sPl && !defined $oYou) {
# 				$guess .= "saq";
# 			} elsif ($tense eq 'fut' && !defined $sMe && !defined $sYou && !defined $oYou) {
# 				$guess .= "qa";
# 				
# 			} elsif (!defined $sMe && $sYou) {
# 				$guess .= "ki"
# 			} elsif (!defined $oMe && $oYou) {
# 				$guess .= "ki";
# 			}
# 			
# 			
# 			Block 6: ku, chis
# 			if ($tense eq 'past' && !defined $sMe && !defined $sYou && $oYou && !defined $oPl) {
# 				do nothing
# 				
# 			} elsif ($tense eq 'past' && $sYou && !defined $sPl && $oMe && $oPl) {
# 				$guess .= "chis";
# 				
# 			} elsif ($tense eq 'fut' && $sMe && !defined $sPl && $oPl) {
# 				$guess .= "ku";
# 				
# 			} elsif ($tense eq 'past' && $sMe && !defined $sYou && $sPl) {
# 				$guess .= "ku";
# 				
# 			} elsif (($oYou && $oPl) || ($sYou && $sPl)) {
# 				$guess .= "chis";
# 
# 			} elsif (!defined $sYou && $sPl) {
# 				$guess .= "ku";
# 				
# 			} elsif ($oMe && $oPl) {
# 				$guess .= "ku";
# 			}
}

