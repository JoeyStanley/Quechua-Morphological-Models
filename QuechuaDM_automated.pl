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
		
			my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc) = parameters($subject, $object);
			
			my $past = my $fut = -1;
			if    ($tense eq 'past') { $past = 1 }
			elsif ($tense eq 'fut')  { $fut  = 1 }
			
			my $guess = "";
			
			my @p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			
			
			# Impoverishment rules
			if (minus_MeNom(@p) && minus_MeAcc(@p) && minus_YouAcc(@p) && plus_PlAcc(@p)) {
				#$guess .= "@@";
				$PlAcc = undef;
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			if (minus_MeAcc(@p) && minus_YouAcc(@p) && plus_PlNom(@p) && plus_PlAcc(@p)) {
				#$guess .= "@@";
				$PlAcc = undef;
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			if (minus_MeAcc(@p) && minus_YouAcc(@p) && plus_PlAcc(@p) && minus_fut(@p)) {
				#guess .= "@@";
				$PlAcc = undef;
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			if (minus_MeNom(@p) && plus_YouNom(@p) && plus_fut(@p)) {
				#$guess .= "@@";
				$fut = undef;
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			if (minus_MeNom(@p) && plus_YouNom(@p) && plus_PlNom(@p) && plus_PlAcc(@p) && minus_past(@p)) {
				#$guess .= "@@";
				$PlAcc = undef;
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}	
			if (minus_MeNom(@p) && minus_YouNom(@p) && plus_YouAcc(@p) && plus_PlNom(@p) && plus_past(@p)) {
				#$guess .= "@@";
				$PlNom = undef;
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			if (minus_MeNom(@p) && plus_YouNom(@p) && plus_PlNom(@p) && plus_PlAcc(@p) && plus_past(@p)) {
				#$guess .= "@@";
				$PlAcc = undef;
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			if (minus_MeNom(@p) && plus_MeAcc(@p) && minus_YouNom(@p) && plus_PlNom(@p) && plus_PlAcc(@p)) {
				#$guess .= "@@";
				$PlNom = undef;
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			if (minus_MeNom(@p) && minus_YouNom(@p) && minus_MeAcc(@p) && plus_YouAcc(@p) && plus_fut(@p)) {
				#$guess .= "@@";
				$fut = undef;
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			if (plus_MeNom(@p) && plus_PlNom(@p) && plus_PlAcc(@p) && plus_past(@p)) {
				#$guess .= "@@";
				$PlAcc = undef;
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			if (plus_MeNom(@p) && plus_PlNom(@p) && plus_PlAcc(@p) && minus_past(@p) && minus_fut(@p)) {
				#$guess .= "@@";
				$PlNom = undef;
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
						
		
			# Rules
			# Handle one very annoying cell
			if (plus_MeAcc(@p) && plus_YouNom(@p) && minus_PlNom(@p) && plus_PlAcc(@p) && plus_past(@p)) { # A''
				$guess .= "warqankichis";
				$MeAcc = $PlNom = $PlAcc = undef;
				$YouNom = $past = 's+1'; # becMeAccs secondary
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			if (plus_MeNom(@p) && minus_YouNom(@p) && plus_YouAcc(@p) && minus_PlNom(@p) && plus_PlAcc(@p) && plus_fut(@p)) { # A
				$guess .= "sqaykiku";
				$PlAcc = undef;
				$MeNom = $YouAcc = $fut = 's+1'; # becMeAccs secondary
				$YouNom = 's-1'; # becMeAccs secondary
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			} 
			# Subset of A
			if (plus_MeNom(@p) && minus_YouNom(@p) && plus_YouAcc(@p) && plus_PlAcc(@p) && plus_fut(@p)) { # A'
				$guess .= "sqaykichis";
				$PlAcc = undef;
				$MeNom = $YouAcc = $fut = 's+1'; # becMeAccs secondary
				$YouNom = 's-1'; # becMeAccs secondary
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			} 
			# Subset of A->A'
			if (plus_MeNom(@p) && minus_YouNom(@p) && plus_YouAcc(@p) && plus_PlNom(@p) && plus_fut(@p)) { # B
				$guess .= "sqaykiku"; # this q is optional
				$MeNom = $YouAcc = $fut = 's+1'; # becMeAccs secondary
				$YouNom = 's-1'; # becMeAccs secondary
				$PlNom = undef;
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			# Subset of A->A'->B
			if (plus_MeNom(@p) && minus_YouNom(@p) && plus_YouAcc(@p) && plus_fut(@p)) { # B'
				$guess .= "sqayki"; # this q is optional
				$MeNom = $YouAcc = $fut = 's+1'; # becMeAccs secondary
				$YouNom = 's-1'; # becMeAccs secondary
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			
			if (plus_MeNom(@p) && minus_YouNom(@p) && plus_PlNom(@p) && plus_fut(@p)) { # C'
				$guess .= "sayku"; 
				$MeNom = $fut = 's+1'; # becMeAccs secondary
				$YouNom = 's-1'; # becMeAccs secondary
				$PlNom = undef;
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			# Subset of A->A'->B and C'
			if (plus_MeNom(@p) && minus_YouNom(@p) && plus_fut(@p)) { # C
				$guess .= "sa"; 
				$MeNom = $fut = 's+1'; # becMeAccs secondary
				$YouNom = 's-1'; # becMeAccs secondary
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			# Subset of A->A'->B->C and C'->C
			if (plus_MeNom(@p) && plus_fut(@p)) { # D
				$guess .= "sun"; # two morphemes
				$MeNom = $fut = 's+1'; # becMeAccs secondary
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			if (sp_MeNom(@p) && sm_YouNom(@p) && minus_YouAcc(@p) && minus_PlNom(@p)) { # E
				$guess .= "q";
				$YouAcc = $PlNom = undef;
				$MeNom = 's+1'; # continues secondary
				$YouNom = 's-1'; # continues secondary
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			} 
			# technically not a subset of E
			if (sp_MeNom(@p) && sm_YouNom(@p) && plus_PlNom(@p)) { # G
				$guess .= "";
				$PlNom = undef;
				$MeNom = 's+1'; # continues secondary
				$YouNom = 's-1'; # continues secondary
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			if (plus_MeAcc(@p)) { # H 
				$guess .= "wa";
				$MeAcc = undef;
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			if (plus_past(@p)) { # I 
				$guess .= "rqa";
				$past = 's+1'; # becMeAccs secondary
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			if (plus_MeNom(@p) && minus_YouNom(@p) && minus_YouAcc(@p) && minus_PlNom(@p)) { # J
				$guess .= "ni";
				$YouAcc = $PlNom = undef;
				$MeNom = 's+1'; # continues secondary
				$YouNom = 's-1'; # continues secondary
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
 			} 
 			# Subset of J
			if (plus_MeNom(@p) && minus_YouNom(@p)) { # K 
				$guess .= "y";
				$MeNom = 's+1'; # continues secondary
				$YouNom = 's-1'; # continues secondary
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
 			}
			# Subset of J and K
			if (plus_MeNom(@p)) { # M
				$guess .= "n";
				$MeNom = 's+1'; # becMeAcc secondary
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
			# Handles the cells that don't have n
			if (minus_MeNom(@p) && minus_YouNom(@p) && minus_YouAcc(@p) && minus_PlNom(@p) && sp_past(@p)) { # N
				# do nothing
				$YouAcc = $PlNom = undef;
				$MeNom = 's+1'; # becMeAccs secondary
				$YouNom = 's-1'; # becMeAccs secondary
				$past = 's+1'; # continues secondary
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
 			if (minus_MeNom(@p) && minus_MeAcc(@p) && plus_YouAcc(@p)) { # O
 				$guess .= "sunki"; # three morphemes
 				$MeNom = $MeAcc = undef;
 				$YouAcc = 's+1'; # becMeAccs secondary
 				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
 			}
 			if (minus_MeNom(@p) && plus_YouAcc(@p) && plus_fut(@p)) { # R
 				$guess .= "sun";
 				$MeNom = undef;
 				$YouAcc = $fut = 's+1';
 				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
 			}
 			# Subset of O and R
 			if (minus_MeNom(@p) && plus_YouAcc(@p)) { # S
 				$guess .= "n";
 				$MeNom = undef;
 				$YouAcc = 's+1'; # becMeAccs secondary
 				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
 			}
 			if (minus_MeNom(@p) && plus_YouNom(@p)) { # P
 				$guess .= "nki";
 				$MeNom = undef;
 				$YouNom = 's+1'; # becMeAccs secondary
 				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
 			} 
 			if (sp_MeNom(@p) && plus_YouAcc(@p)) { # Q
 				$guess .= "ki";
 				$MeNom = $YouAcc = 's+1'; # continues secondary
 				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
 			}
 			if (minus_MeNom(@p) && minus_YouNom(@p) && minus_past(@p) && plus_fut(@p)) { # R'
 				$guess .= "nqa";
 				$MeNom = $past = undef;
 				$YouNom = 's-1';
 				$fut = 's+1';
 				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
 			} 
 			# Subset of R'
 			if (minus_MeNom(@p) && minus_YouNom(@p) && minus_past(@p)) { # T
 				$guess .= "n";
 				$MeNom = $past = undef;
 				$YouNom = 's-1';
 				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
 			} 
 			if (sp_YouAcc(@p) && plus_PlNom(@p) && plus_PlAcc(@p)) { # U 
 				$guess .= "chis";
 				$YouAcc = 's+1'; # continues secondary
 				$PlNom = $PlAcc = undef;
 				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
 			}
 			# Subset of U
 			if (sp_YouAcc(@p) && plus_PlAcc(@p)) { # U'
 				$guess .= "chis";
 				$YouAcc = 's+1'; # continues secondary
 				$PlAcc = undef;
 				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
 			}
 			# Subset of U->U' and probably others
 			if (plus_PlAcc(@p)) { # X
				$guess .= "ku";
				$PlAcc = undef;
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}
 			if (sp_YouNom(@p) && plus_PlNom(@p)) { # V
 				$guess .= "chis";
 				$YouNom = 's+1'; # continues secondary
 				$PlNom = undef;
 				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
 			}
 			if (plus_YouNom(@p) && plus_PlNom(@p)) { # W
 				$guess .= "chis";
 				$YouNom = 's+1'; # becMeAccs secondary
 				$PlNom = undef;
 				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
 			}	
			if (plus_PlNom(@p)) { # Y
				$guess .= "ku";
				$PlNom = undef;
				@p = ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past);
			}

			#printFeatures(@p);
		
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

sub plus_MeNom {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $MeNom) {
		return undef;
	} elsif ($MeNom eq '1') {
		return 1;
	} else {
		return undef;
	}
}
sub minus_MeNom {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $MeNom) {
		return undef;
	} elsif ($MeNom eq '-1') {
		return 1;
	} else {
		return undef;
	}
}
sub sp_MeNom {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $MeNom) {
		return undef;
	} elsif ($MeNom eq 's+1') {
		return 1;
	} else {
		return undef;
	}
}

sub plus_MeAcc {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $MeAcc) {
		return undef;
	} elsif ($MeAcc eq '1') {
		return 1;
	} else {
		return undef;
	}
}
sub minus_MeAcc {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $MeAcc) {
		return undef;
	} elsif ($MeAcc eq '-1') {
		return 1;
	} else {
		return undef;
	}
}

sub plus_YouNom {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $YouNom) {
		return undef;
	} elsif ($YouNom eq '1') {
		return 1;
	} else {
		return undef;
	}
}
sub minus_YouNom {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $YouNom) {
		return undef;
	} elsif ($YouNom eq '-1') {
		return 1;
	} else {
		return undef;
	}
}
sub sp_YouNom {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $YouNom) {
		return undef;
	} elsif ($YouNom eq 's+1') {
		return 1;
	} else {
		return undef;
	}
}
sub sm_YouNom {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $YouNom) {
		return undef;
	} elsif ($YouNom eq 's-1') {
		return 1;
	} else {
		return undef;
	}
}

sub plus_YouAcc {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $YouAcc) {
		return undef;
	} elsif ($YouAcc eq '1') {
		return 1;
	} else {
		return undef;
	}
}
sub minus_YouAcc {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $YouAcc) {
		return undef;
	} elsif ($YouAcc eq '-1') {
		return 1;
	} else {
		return undef;
	}
}
sub sp_YouAcc {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $YouAcc) {
		return undef;
	} elsif ($YouAcc eq 's+1') {
		return 1;
	} else {
		return undef;
	}
}

sub plus_PlNom {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $PlNom) {
		return undef;
	} elsif ($PlNom eq '1') {
		return 1;
	} else {
		return undef;
	}
}
sub minus_PlNom {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $PlNom) {
		return undef;
	} elsif ($PlNom eq '-1') {
		return 1;
	} else {
		return undef;
	}
}

sub plus_PlAcc {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $PlAcc) {
		return undef;
	} elsif ($PlAcc eq '1') {
		return 1;
	} else {
		return undef;
	}
}
sub minus_PlAcc {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $PlAcc) {
		return undef;
	} elsif ($PlAcc eq '-1') {
		return 1;
	} else {
		return undef;
	}
}

sub plus_past {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $past) {
		return undef;
	} elsif ($past eq '1') {
		return 1;
	} else {
		return undef;
	}
}
sub minus_past {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $past) {
		return undef;
	} elsif ($past eq '-1') {
		return 1;
	} else {
		return undef;
	}
}
sub sp_past {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $past) {
		return undef;
	} elsif ($past eq 's+1') {
		return 1;
	} else {
		return undef;
	}
}

sub plus_fut {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $fut) {
		return undef;
	} elsif ($fut eq '1') {
		return 1;
	} else {
		return undef;
	}
}
sub minus_fut {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $fut) {
		return undef;
	} elsif ($fut eq '-1') {
		return 1;
	} else {
		return undef;
	}
}
sub sp_fut {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	if (!defined $fut) {
		return undef;
	} elsif ($fut eq 's+1') {
		return 1;
	} else {
		return undef;
	}
}



sub printFeatures {
	my ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc, $fut, $past) = @_;
	
	my $format = "%s%-3s ";
	printf ($format, "MeNom=", p($MeNom), " ");
	printf ($format, "MeAcc=", p($MeAcc), " ");
	printf ($format, "YouNom=", p($YouNom), " ");
	printf ($format, "YouAcc=", p($YouAcc), " ");
	printf ($format, "PlNom=", p($PlNom), " ");
	printf ($format, "PlAcc=", p($PlAcc), " ");
	printf ($format, "fut=", p($fut), " ");
	printf ($format, "past=", p($past), "\t");

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
	
	my $MeNom = my $YouNom = my $PlNom = my $MeAcc = my $YouAcc = my $PlAcc = -1;
	
	if    ($subject eq "1S" ) { $MeNom           =1 }
	elsif ($subject eq "1PE") { $MeNom      =$PlNom=1 }
	elsif ($subject eq "1PI") { $MeNom=$YouNom=$PlNom=1 }
	elsif ($subject eq "2S" ) { 	 $YouNom     =1 }
	elsif ($subject eq "2P" ) {      $YouNom=$PlNom=1 }
	elsif ($subject eq "3S" ) {                   }
	elsif ($subject eq "3P" ) {            $PlNom=1 }
	
	if    ($object eq "1S" ) { $MeAcc           =1 }
	elsif ($object eq "1PE") { $MeAcc      =$PlAcc=1 }
	elsif ($object eq "1PI") { $MeAcc=$YouAcc=$PlAcc=1 }
	elsif ($object eq "2S" ) { 	    $YouAcc     =1 }
	elsif ($object eq "2P" ) {      $YouAcc=$PlAcc=1 }
	elsif ($object eq "3S" ) {                   }
	elsif ($object eq "3P" ) {            $PlAcc=1 }
		
	return ($MeNom, $YouNom, $PlNom, $MeAcc, $YouAcc, $PlAcc);
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