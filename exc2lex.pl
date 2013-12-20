#!/usr/bin/perl -w

# Copyright © 2010 by Jaak Pruulmann-Vengerefeldt. All rights reserved.

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

	my @kind = ();

	my $suff = '';

	push @kind, '+A' if $kind =~ /A/;
	push @kind, '+S' if $kind =~ /S/;
	push @kind, '+H' if $kind =~ /H/;
	push @kind, '+Adv' if $kind =~ /D/;
	push @kind, '' if $kind =~ /V/;
	push @kind, '+I' if $kind =~ /I/;
	push @kind, '+J' if $kind =~ /J/;
	push @kind, '+Pron' if $kind =~ /P/;
	push @kind, '+G' if $kind =~ /G/;
	push @kind, '+K' if $kind =~ /K/;
	push @kind, '+Num' if $kind =~ /N/;
	push @kind, '+Ord' if $kind =~ /O/;
	push @kind, '+X' if $kind =~ /X/;

	my $list = (($opt eq '*') ? \@override : \@extra);

	for (@kind) {
		push @{$list}, " $stem$_$form{$code}:$form GI; ! $line\n";
	}
}

write_lex("generated_overrides.lexc", "Asendavad_erandid_gen", @override);
write_lex("generated_extra.lexc", "Lisanduvad_erandid", @extra);

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
	binmode FC, ':utf8';
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
