#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';
use Data::Dumper;

my @persons = qw(1S 1PE 1PI 2S 2P 3S 3P);
my @tenses  = qw(past pres fut);

for my $tense (@tenses) {
	for my $subject (@persons) {
		for my $object (@persons) {
		
			next unless &illogical($subject, $object);
		
			my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl) = parameters($subject, $object);
			
			my $past = my $fut = -1;
			if    ($tense eq 'past') { $past = 1 }
			elsif ($tense eq 'fut')  { $fut  = 1 }
			
			my $guess = "";
			
			my @p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
			
			
			# Impoverishment rules
			if (plus_sMe(@p) && plus_oYou(@p) && plus_sPl(@p) && plus_oPl(@p) && plus_past(@p)) {
				$oPl = undef;
				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
			}
			if (minus_sMe(@p) && plus_oYou(@p) && plus_sPl(@p) && minus_oPl(@p) && plus_past(@p)) {
				$sPl = undef;
				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
			}
			
						
			# Just take care of the exceptions first
			if (plus_oMe(@p) && plus_sYou(@p) && minus_sPl(@p) && plus_oPl(@p) && plus_past(@p)) {
				$guess .= "warqankichis";
				$oMe = $sYou = $sPl = $oPl = $past = undef;
				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
			}			
			if (plus_sMe(@p) && minus_oYou(@p) && minus_sPl(@p) && plus_oPl(@p) && plus_fut(@p)) {
				$guess .= "saqku";
				$sMe = $oYou = $sPl = $oPl = $fut = undef;
				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
			}
			
			if (plus_sMe(@p) && plus_oYou(@p) && minus_sPl(@p) && plus_oPl(@p) && plus_fut(@p)) {
				$guess .= "sqaykiku";
				$sMe = $oYou = $sPl = $oPl = $fut = undef;
				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
			}
			
			
			
			# Regular rules
			
						
			if (plus_oMe(@p)) {	# A
				$guess .= "wa";
				$oMe = undef;
				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
			}
			
 			if (plus_past(@p)) { # B
 				$guess .= "rqa";
 				$past = undef;
 				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
 			}
 			
  			if (minus_sMe(@p) && minus_oMe(@p) && plus_oYou(@p)) { # C
  				$guess .= "sunki";
  				$sMe = $oMe = undef;
  				$oYou = "s1"; # secondary
  				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
  			}
  			
   			if (plus_sMe(@p) && plus_sYou(@p) && plus_fut(@p)) { # D
   				$guess .= "sun";
   				$sMe = $fut = undef;
   				$sYou = 's1'; # secondary
  				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
   			}
   			# subset of D
   			if (plus_sMe(@p) && plus_sYou(@p)) { # R
   				$guess .= "n";
   				$sMe = undef;
   				$sYou = 's1'; # secondary
  				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
   			}
   			if (plus_sMe(@p) && minus_sYou(@p) && plus_oYou(@p) && plus_sPl(@p) && minus_fut(@p)) { # P
 				$guess .= "yki";
 				$sMe = $sYou = $sPl = $fut = undef;
 				$oYou = "s1"; # secondary
 				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past); 
 			}
 			# subset of # P
   			if (plus_sMe(@p) && minus_sYou(@p) && plus_sPl(@p) && minus_fut(@p)) { # Q
 				$guess .= "y";
 				$sMe = $sYou = $sPl = $fut = undef;
 				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past); 
 			}
  			
   			if (plus_sMe(@p) && minus_oYou(@p) && minus_sPl(@p) && minus_fut(@p)) { # J
   				$guess .= "ni";
   				$sMe = $oYou = $sPl = $fut = undef;
  				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
   			}
   			
			if (plus_sMe(@p) && plus_oYou(@p) && plus_fut(@p)) { # E
				$guess .= "sqayki";
				$sMe = $fut = undef;
				$oYou = "s1"; # secondary
				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
			}
			# subset of E->F
			if (plus_sMe(@p) && plus_oYou(@p)) { # N
				$guess .= "yki";
				$sMe = undef;
				$oYou = "s1"; # secondary
				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
			}
				
			if (minus_sMe(@p) && plus_sYou(@p)) { # L
				$guess .= "nki";
				$sMe = undef;
				$sYou = 's1'; # secondary
				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
			}
			
			if (plus_sMe(@p) && plus_sPl(@p) && plus_fut(@p)) {	# G
				$guess .= "sayku";
				$sMe = $sPl = $fut = undef; # sMe = secondary (needed in rule K)
				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
			}
			
			# Subset of E->F, G
			if (plus_sMe(@p) && plus_fut(@p)) { # I 
				$guess .= "saq";
				$sMe = $sPl = $fut = undef;
				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
			}
					
			if (minus_sMe(@p) && minus_sYou(@p) && minus_oYou(@p) && plus_fut(@p)) { # M
				$guess .= "nqa";
				$sMe = $sYou = $oYou = $sPl = undef;
				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
			}
			
			if (minus_sMe(@p) && minus_oYou(@p) && minus_past(@p)) { # S
				$guess .= "n";
				$sMe = $oYou = $past = undef;
				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
			}
			if (plus_oYou(@p) && plus_oPl(@p) && plus_fut(@p)) { # H
				$guess .= "sunchis";
				$oPl = $fut = undef;
				$oYou = "s1"; # secondary
				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
			}
			# subset of H
			if (plus_oYou(@p) && plus_oPl(@p)) { # T
				$guess .= "nchis";
				$oPl = undef;
				$oYou = "s1"; # secondary
				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
			}
			if (sec_sYou(@p) && plus_sPl(@p)) { # @
				$guess .= "chis";
				$sYou = $sPl = undef;
				@p = ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past);
			}
			
			# Impoverish [+you] → Ø / [+me.nom +pl.nom +you.acc +pl.acc +past]
			# Impoverish [+you] → Ø / [+me.nom +sg.nom +you.acc +pl.acc +fut]
			if (sec_oYou(@p) && plus_sMe(@p)) {
				#$guess .= "@@";
			}
			
			if (sec_oYou(@p) && plus_oPl(@p)) {
				#$guess .= "chis";
				
			}

		
			


			printFeatures(@p);
		
			# Print the correct ones.
			my $correct = &correct($tense, $subject, $object);		
			my $score = &score($correct, $guess);
			my $remaining = &remaining($correct, $guess, $score);
		
		
			my $format = "%-6s%-10s%-13s%-13s%-13s%-1s\n";
			printf ($format, $tense, "$subject->$object", $guess, $remaining, $correct, $score);
		
		}
		print "\n";
	}
}

sub plus_sMe {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $sMe) {
		return undef;
	} elsif ($sMe eq '1') {
		return 1;
	} else {
		return undef;
	}
}
sub minus_sMe {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $sMe) {
		return undef;
	} elsif ($sMe eq '-1') {
		return 1;
	} else {
		return undef;
	}
}

sub plus_oMe {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $oMe) {
		return undef;
	} elsif ($oMe eq '1') {
		return 1;
	} else {
		return undef;
	}
}
sub minus_oMe {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $oMe) {
		return undef;
	} elsif ($oMe eq '-1') {
		return 1;
	} else {
		return undef;
	}
}

sub plus_sYou {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $sYou) {
		return undef;
	} elsif ($sYou eq '1') {
		return 1;
	} else {
		return undef;
	}
}
sub minus_sYou {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $sYou) {
		return undef;
	} elsif ($sYou eq '-1') {
		return 1;
	} else {
		return undef;
	}
}
sub sec_sYou {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $sYou) {
		return undef;
	} elsif ($sYou eq 's1') {
		return 1;
	} else {
		return undef;
	}
}

sub plus_oYou {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $oYou) {
		return undef;
	} elsif ($oYou eq '1') {
		return 1;
	} else {
		return undef;
	}
}
sub minus_oYou {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $oYou) {
		return undef;
	} elsif ($oYou eq '-1') {
		return 1;
	} else {
		return undef;
	}
}
sub sec_oYou {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $oYou) {
		return undef;
	} elsif ($oYou eq 's1') {
		return 1;
	} else {
		return undef;
	}
}

sub plus_sPl {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $sPl) {
		return undef;
	} elsif ($sPl eq '1') {
		return 1;
	} else {
		return undef;
	}
}
sub minus_sPl {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $sPl) {
		return undef;
	} elsif ($sPl eq '-1') {
		return 1;
	} else {
		return undef;
	}
}

sub plus_oPl {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $oPl) {
		return undef;
	} elsif ($oPl eq '1') {
		return 1;
	} else {
		return undef;
	}
}
sub minus_oPl {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $oPl) {
		return undef;
	} elsif ($oPl eq '-1') {
		return 1;
	} else {
		return undef;
	}
}

sub plus_past {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $past) {
		return undef;
	} elsif ($past eq '1') {
		return 1;
	} else {
		return undef;
	}
}
sub minus_past {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $past) {
		return undef;
	} elsif ($past eq '-1') {
		return 1;
	} else {
		return undef;
	}
}

sub plus_fut {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $fut) {
		return undef;
	} elsif ($fut eq '1') {
		return 1;
	} else {
		return undef;
	}
}
sub minus_fut {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	if (!defined $fut) {
		return undef;
	} elsif ($fut eq '-1') {
		return 1;
	} else {
		return undef;
	}
}

sub printFeatures {
	my ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl, $fut, $past) = @_;
	
	print "sMe=", p($sMe), " ";
	print "oMe=", p($oMe), " ";
	print "sYou=", p($sYou), " ";
	print "oYou=", p($oYou), " ";
	print "sPl=", p($sPl), " ";
	print "oPl=", p($oPl), " ";
	print "fut=", p($fut), " ";
	print "past=", p($past), "\t";

	sub p {
		my $f = shift;
		if ($f) { $f eq '1' ? "+1" : $f } 
		else { " X" }
	}
}

sub illogical {
	my ($subject, $object) = @_;
	
	# No reflexives
	return if $subject eq "1S"  && $object eq "1S";
	return if $subject eq "1PE" && $object eq "1PE";
	return if $subject eq "1PI" && $object eq "1PI";
	return if $subject eq "2S"  && $object eq "2S";
	return if $subject eq "2P"  && $object eq "2P";
	
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
	
	my $sMe = my $sYou = my $sPl = my $oMe = my $oYou = my $oPl = -1;
	
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
		
	return ($sMe, $sYou, $sPl, $oMe, $oYou, $oPl);
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
sub remaining {
	my ($correct, $guess, $score) = @_;
	
	if ($score eq "") {
		return $correct;
	} elsif ($score eq "ok") {
		return "";
	} elsif ($score eq "...") {
		$correct =~ $guess;
		return $';
	} elsif ($score eq "X") {
		return "@@@@@";
	}
}