#!/usr/bin/perl -w

use utf8;
use strict;
use feature "switch"; # alates perl 5.10 

binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';


my %form = ();

my @override = ();
my @extra = ();
my $stem;

load_forms();

while (<>) {
	s/$//;
	chomp();
	chomp();

	next if /^\s*$/;

	my $line = $_;

	my ($kind, $stem, $form, $code, $stemvariant, $stemok, $opt) = split(',');

	if (!defined($form{$code})) {
		print "tundmatu vorm: $_\n";
		next;
	}

	$stem =~ tr/'//d;
	$form =~ tr/'\[\]//d;

	my $suff = '';
	given ($kind) { # {{{
		when (/A/) {
			$stem .= '+A';
			$stem .= '+S' if /S/;
		}

		when (/S/) {
			$stem .= '+S';
		}

		when (/H/) {
			$stem .= '+H';
		}

		when (/D/) {
			$stem .= '+Adv';
		}

		when (/V/) {
		}

		when (/I/) {
			$stem .= '+I';
		}

		when (/J/) {
			$stem .= '+J';
		}

		when (/P/) {
			$stem .= '+Pron';
		}

		when (/G/) {
			$stem .= '+G';
		}

		when (/K/) {
			$stem .= '+K';
		}

		when (/N/) {
			$stem .= '+Num';
		}

		when (/O/) {
			$stem .= '+O';
		}

		when (/X/) {
			$stem .= '+X';
		}

		default {
			print "Tundmatu sõnaliik '$kind' - $stem\n";
		}
		
	} # }}}

	my $list = (($opt eq '*') ? \@override : \@extra);
	push @{$list}, " $stem$form{$code}:$form GI; ! $line\n";
}

write_lex("lex_override_gen.txt", "Asendavad_erandid_gen", @override);
write_lex("lex_extra.txt", "Lisanduvad_erandid", @extra);

exit 0;

sub write_lex {
	my $file = shift;
	my $lexicon = shift;
	open F, ">$file";
	binmode F, ':utf8';
	print F "LEXICON $lexicon\n";
	print F sort @_;
	close F;
	print "Sõnastik '$lexicon': " . scalar(@_) . " rida.\n";
}

sub load_forms {
	open FC, "<fcodes.ini";
	while (<FC>) {
		s/$//;
		chomp();
		chomp();

		s/\s*;.*$//o;
		
		next if /^\s*$/;
		next if /^@/;

		my ($vorminimi, $klaarkood, $sisekood, $fskood, $lex) = split(',');

		next unless defined($lex) && length($lex) > 0;

		$form{$sisekood} = $lex;
	}

	close(FC);
}
