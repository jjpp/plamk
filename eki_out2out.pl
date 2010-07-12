#!/usr/bin/perl

use strict;

my $ok = 0;

while (<>) {
	if (/^\S+/) {
		print $_;
		$ok = 0;
	} elsif (/^    \S+ \/\/_._ [^\/]+\/\/ . \?/) { # oletus
		# ignoreerime
	} elsif (/^(    \S+ \/\/[^\/]+\/\/).*$/) {
		print "$1\n";
		$ok ++;
	} elsif (/^[\s\r\n]+$/) {
		if (!$ok) {
			print "    ####\n";
		}
		$ok = 1;
	}
}

exit 0;


