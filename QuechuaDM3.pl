#!/usr/bin/perl

# This is an attempt at a Distributed Morphology approach to Quechua.
# Instead of having the computer sort through the rules, I'll hard code them in.

use strict;
use warnings;
use feature 'say';
use Data::Dumper;

my @subjects = qw(1S 1PI 2S 2P 3S 3P); # 1S 1PE 1PI 2S 2P 3S 3P
my @objects  = qw(1S 1PE 2S 2P 3S 3P);  # 1S 1PE 1PI 2S 2P 3S 3P
my @tenses   = qw(past pres); # past fut

# Block 1
my %rqa = ( 	'conditions' => { 
					'tense'  => {  past => 1, }, },
		  		'environment' => undef,
		  		'stem' => 'rqa' );
my @pastTense = (\%rqa);

# Block 1
my %wa = ( 		'conditions' => { 
					'obj'  => {  1 => 1, }, },
		  		'environment' => undef,
		  		'stem' => 'wa' );
my %su = (  	'conditions' => { 
					'subj' => { 1  =>  -1, 
								2  =>  -1, },
			 		'obj'  => { 2  =>   1, }, },
		    	'environment' => undef,
		   		'stem' => 'su' );
my @singularObjects = (\%wa, \%su);

# Block 2
my %nki = ( 	'conditions' => { 
					'subj'  => { 1 => -1,
								 2 =>  1, }, },
		  		'environment' => undef,
		  		'stem' => 'nki' );
# this becomes "ni" word-finally in the phonological rules
my %y = (   	'conditions' => { 
					'subj'  => { 1 =>  1,
							     2 => -1, }, },
		     	'environment' => undef,
		     	'stem' => 'y' );
		    
my %n = (  		'conditions' => { },
				'environment' => undef,
		    	'stem' => 'n' );
my @personSubj = (\%nki, \%y, \%n);

# Block 3
my %ki = (  	'conditions' => { 
			 		'obj'  => { 2  => 1, }, },
		    	'environment' => undef,
		   		'stem' => 'ki' );
my @otherObjects = ( \%ki);
		    
# Block 4
my %ku1 = (  	'conditions' => { 
			 		'obj'  => { 1  =>  1,
			 					pl => 1, }, },
		    	'environment' => undef,
		   		'stem' => 'ku' );
my %chis1 = (  	'conditions' => { 
			 		'subj'  => { 2  => 1, 
			 					 pl => 1, }, },
		    	'environment' => undef,
		   		'stem' => 'chis' );
my %chis2 = (  	'conditions' => { 
			 		'obj'  => { 2  => 1, , 
			 				    pl => 1, }, },
		    	'environment' => undef,
		   		'stem' => 'chis' );
my %ku2 = (  	'conditions' => { 
			 		'subj'  => { pl => 1, }, },
		    	'environment' => undef,
		   		'stem' => 'ku' );
		    
my @numberSubj = (\%ku1, \%chis1, \%chis2, \%ku2);

my @blocks = (\@pastTense, \@singularObjects, \@personSubj, \@otherObjects, \@numberSubj); 
 
#say Dumper \@blocks;
 
for my $tense (@tenses) {
	#say $tense;
	for my $subject (@subjects) {
		#say "\t$subject";
		for my $object (@objects) {
			next unless logical($subject, $object);
			my %cell = (
				'tense' => &tenseParameters($tense),
				'subj'  => &personParameters($subject),
				'obj'   => &personParameters($object),
				
				'suffixes' => [],
			);
			
			my $guess = "";
			
BLOCK:		for my $block (@blocks) {
				
RULE: 			for my $rule (@$block) {
 					my %rule = %$rule;
 					#say "\t\t".$rule{stem};

 					for my $cond (keys $rule{conditions}) {
 						#say "\t\t\t$cond";
 				
						# I don't remember what this is for.
 						next unless $cell{$cond};
 				
 						for my $person (keys $rule{conditions}{$cond}) {
 							#say "\t\t$person = ".$rule{conditions}{$cond}{$person};
					
							#say $cell{$cond}{$person};
							
							if ($person =~ /past|fut/ && $cell{$cond}{$person} eq $rule{conditions}{$cond}{$person}) {
								# This is a tense condition. Good. 
								# The only difference between this and the condition below 
								#   is 'eq' instead of '=='.
							
 							} elsif ($cell{$cond}{$person} == $rule{conditions}{$cond}{$person}) {
 								# So far, the rule has matched this condition.
 								# See if it matches all of them.
 							} else {
 								#say "\t\t\tNo match. Moving on to next rule";
 								next RULE;
 							}
 						} #end PERS loop
				
						# If it's made it this far, then this cell matches this condition.
 						# Now see if it matches the entire rule.
 						# No conditional statement here because it'll automatically jump to the next rule if
 						#   this cell doesn't meet the next condition.
 				
 						# say "\t\t\tThis cell matches this condition!";
 				
 					} # end COND loop.
 			
 					# If it's made it this far, then this cell has matched all the conditions for this rule.
 					#say "\t\t\tThis cell matches this rule!";
 			
 					$guess .= $rule{stem};
 					push $cell{suffixes}, $rule;
 					next BLOCK;
 			
					# print Dumper \%cell;
 			
				} # and RULE loop.
			
			
			} # end BLOCK loop.
			
 			
			# Phonological Rules
			
			# Change word final "y" to "ni".
			my $numberOfSuffixes = $#{$cell{suffixes}};
			if ($numberOfSuffixes >= 0) {
				# This is the wordiest way of doing this ever, but this accesses the last element in the list of suffixes's stem 
				my $lastStem = ${$cell{suffixes}}[$numberOfSuffixes]{stem};
				
				if ($lastStem eq 'y') {
					#say "\$guess:  $guess";
					$guess =~ s/y\b/ni/;
				}
			}
			
			# Switch rqa and wa (= 'wa' must follow the root)
			$guess =~ s/rqawa/warqa/;
			
			
			
			
			
			
			# Print the correct ones.
			my $correct = &correct($tense, $subject, $object);		
			my $score = &score($correct, $guess);
			my $remaining = &remaining($correct, $guess, $score);
		
		
			my $format = "%-6s%-10s%-13s%-13s%-13s%-1s\n";
			printf ($format, $tense, "$subject->$object", $guess, $remaining, $correct, $score);
 		
		} # end OBJ loop	
		print "\n";
	} # end SUBJ loop
	print "\n";
} # end TENSE loop;


sub logical {
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


sub tenseParameters {
	my $tense = shift;
	
	my %hash;
	
	if ($tense eq 'past') {
		$hash{past} =  1;
		$hash{fut}  = -1;
	} elsif ($tense eq 'fut') {
		$hash{past} = -1;
		$hash{fut}  =  1;
	} else {
		$hash{past} = -1;
		$hash{fut}  =  1;
	}
	
	return \%hash;
}
sub personParameters {
	my $person = shift;
	
	my %hash;
	if ($person eq '1S') {
		%hash = (1  =>  1, 
				 2  => -1,
				 pl => -1);
	} elsif ($person eq '1PE') {
		%hash = (1  =>  1, 
				 2  => -1,
				 pl =>  1);	
	} elsif ($person eq '1PI') {
		%hash = (1  =>  1, 
				 2  =>  1,
				 pl =>  1);	
	} elsif ($person eq '2S') {
		%hash = (1  => -1, 
				 2  =>  1,
				 pl => -1);	
	} elsif ($person eq '2P') {
		%hash = (1  => -1, 
				 2  =>  1,
				 pl =>  1);	
	} elsif ($person eq '3S') {
		%hash = (1  => -1, 
				 2  => -1,
				 pl => -1);	
	} elsif ($person eq '3P') {
		%hash = (1  => -1, 
				 2  => -1,
				 pl =>  1);	
	}
	
	$hash{name} = $person;
	
	return \%hash;
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