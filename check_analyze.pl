#!/usr/bin/perl -w

# Copyright © 2010 by Jaak Pruulmann-Vengerefeldt. All rights reserved.

use utf8;
use strict;

binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';


use vars qw{$lemma @analyzes %ok %ignore $mapper $fsmode %count %weight %problems @wftest};

if (!@ARGV) {
	print "use: $0 blaah.check\n testitav analüüs stdsisendisse\n";
	exit 0;
}

my $checkfile = shift @ARGV;
%ignore = ();

if ($ENV{IGNOREFILE}) {
	open (I, "<$ENV{IGNOREFILE}");
	my @ignores = <I>;
	chomp @ignores;
	%ignore = map { $_ => 1 } @ignores;
	close(I);
}

$fsmode = defined($ENV{MAPPER}) && $ENV{MAPPER} eq 'FS';
$mapper = $fsmode ? \&map_to_kym_fs : \&map_to_kym;
	

%ok = ();

open C, "<$checkfile";
binmode C, ':utf8';
while (<C>) {
	chomp();
	my ($weight, $w, $stem, $anal) = split(' ', $_, 4);

	$ok{$w} = {} unless ref($ok{$w}) eq 'HASH';
	if (ref($ok{$w} -> {$anal}) eq 'ARRAY') {
		$ok{$w} -> {$anal} -> [0] .= ', ' . $stem;
		$ok{$w} -> {$anal} -> [1] += $weight;
	} else {
		$ok{$w} -> {$anal} = [ $stem, $weight ];
	}
}
close(C);


my $lemma = '';
my @analyzes = ();
@wftest = ();
%count = ();
%weight = ();
%problems = ();

init('total', 'unanalyzed', 'ok', 'overanalyze', 'comp', 'h', 'd', 'dk', 'kd');

while (<>) {
	chomp();

	next if /^Closing input file/;
	next if /^Opening input file/;
	next if /^\S+ \d+, \d\d\d\d \d\d:\d\d:\d\d \S+$/;

	if (($fsmode && !/^ /) || (!$fsmode && /^$/)) {
		check_lemma() if $lemma ne '';
		$lemma = '';
		@analyzes = ();
	}

	if ($lemma eq '') {
		$lemma = $_;
	} elsif ($_ ne "???" && $_ !~ /####/) {
		push @analyzes, $_;
	}
}

check_lemma() if ($lemma ne '');

#open (X, ">/tmp/wftest.txt");
#binmode X, ':utf8';
#for (sort { join(' ', $a -> [1, 2, 3]) cmp join(' ', $b -> [1, 2, 3]) } @wftest) {
#	printf X "%7d %s %s %s\n", @{$_};
#}
#close X;

$count{wrong} = $count{'total'} - $count{'unanalyzed'} - $count{'ok'} - $count{'overanalyze'};
$weight{wrong} = $weight{'total'} - $weight{'unanalyzed'} - $weight{'ok'} - $weight{'overanalyze'};

$count{analyzed} = $count{total} - $count{unanalyzed};
$weight{analyzed} = $weight{total} - $weight{unanalyzed};

&print_perc ("Sõnu kokku", 'total', 'total');
&print_perc ("Analüüsitud sõnu", 'analyzed', 'total');
&print_perc ("Analüüsita sõnu", 'unanalyzed', 'total');
&print_perc ("Üleanalüüsitud sõnu", 'overanalyze', 'total');
&print_perc ("Edukaid analüüse", 'ok', 'analyzed');
&print_perc ("Vigaseid analüüse", 'wrong', 'analyzed');
&print_perc ("Võrdlusastmed", 'comp', 'analyzed');
&print_perc ("Pärisnimed", 'h', 'wrong');
&print_perc ("Määrsõnad", 'd', 'wrong');
&print_perc ("Kaassõna määrsõna asemel", 'dk', 'wrong');
&print_perc ("Määrsõna kaassõna asemel", 'kd', 'wrong');

my @sorted_problems = sort { $problems{$b} <=> $problems{$a} } (keys %problems);

print "\nSuurima kaaluga üksikud probleemsed analüüsid:\n";
for (@sorted_problems[0..30]) {
	last unless defined $_;
	print " $_ ($problems{$_})\n";
}

exit 0;

sub init {
	my $k = shift;
	$count{$k} = $weight{$k} = 0;
	init(@_) if @_;
}

sub print_perc {
	my ($label, $part, $total) = @_;

	printf "%30s: %8d %10s / %8d %10s\n",
		$label, $count{$part}, perc($count{$part}, $count{$total}),
			$weight{$part}, perc($weight{$part}, $weight{$total});
}

sub perc {
	my $part = shift;
	my $total = shift;

	return '--' if $total == 0;
	sprintf("(%6.3g%%)", 100 * $part / $total);
}

sub check_lemma {
	$count{'total'}++;
	if (ref($ok{$lemma}) ne 'HASH') {
		if (scalar(@analyzes)) {
			print "üleanalüüs: $lemma -> @analyzes\n";
			upd('overanalyze', 1);
		} else {
			print "kontrollfailist puuduv analüüsita sõna: $lemma\n";
			upd('ok', 1);
		}
		return;
	} 

	if (!scalar(@analyzes)) {
#		print "analüüs puudu: $lemma\n";
		$count{'unanalyzed'} ++;
		for (keys %{$ok{$lemma}}) {
			$weight{'total'}      += $ok{$lemma} -> {$_} -> [1];
			$weight{'unanalyzed'} += $ok{$lemma} -> {$_} -> [1];
#			push @wftest, [ $ok{$lemma} -> {$_} -> [1], $lemma,
#					$ok{$lemma} -> {$_} -> [0], $_ ];
		}
		return;
	}

	my %an = map { &$mapper($_) => 1; } @analyzes;
	my $w = 0;
	my $ign = 0;
	for (keys %{$ok{$lemma}}) {
		my $wgh = $ok{$lemma} -> {$_} -> [1];
		$weight{'total'} += $wgh;
#		push @wftest, [ $ok{$lemma} -> {$_} -> [1], $lemma,
#				$ok{$lemma} -> {$_} -> [0], $_ ];
		if (!$an{$_}) {
			if (/_A_ comp / || /_A_ super/) { # osa komparatiive ja superlatiive on otse omadussõnana.
				my $x = $_;
				$x =~ s/_A_ (comp|super)/_A_/;
				if ($an{$x}) {
					upd('comp', $wgh);
					$weight{'ok'} += $wgh;
					next;
				}
			}

			upd('kd', $wgh) if ($_ eq '//_K_ //' && $an{'//_D_ //'});
			upd('dk', $wgh) if ($_ eq '//_D_ //' && $an{'//_K_ //'});
			upd('h', $wgh)  if ($_ =~ /_H_/);
			upd('d', $wgh)  if ($_ =~ /_D_/);

			#$ign = 1 if /_H_/;

			$problems{$lemma . " " . $_} = $wgh;

			# võimalik analüüs puudu
			print "puuduv analüüs: $lemma -> $_\n" unless ($ignore{$lemma} || $ign);
			$w++;
		} else {
			$weight{'ok'} += $wgh;
		}
	}

	if ($w && !($ignore{$lemma} || $ign)) {
		print "olemas olid: " . join(' ', keys %an) . "\n";
#		$wrong++;
	} else {
		# kõik olid olemas, tore. kaalud panime käigupealt kirja.
		upd('ok', 0);
	}
}

sub upd {
	my $k = shift;
	my $w = shift;

	$count{$k} ++;
	$weight{$k} += $w;
}

sub map_to_kym_fs { 
	my $a = shift;

	my ($l, $an) = split(' ', $a, 2);

	$an;
}

sub map_to_kym {
	my $a = shift;

#	print "mapping '$a' to ";

	$a =~ s{&-$}{}; # argumenteerimis .. ?
	$a .= '+';
	$a =~ s/^.*\&//g;
	$a =~ s{^([^\+]+)\+}{//_};
	my $l = $1;
	$a =~ s{\+}{_ };
	$a =~ s{\+}{ }g;

	$a =~ s/_Num_/_N_ card/;
	$a =~ s/_Ord_/_N_ ord/;
	$a =~ s/_Adv_/_D_/;
	$a =~ s/_Pron_/_P_/;

	$a =~ s/_V_ sup ill/_V_ sup ps ill/;
	$a =~ s/_V_ sup in/_V_ sup ps in/;
	$a =~ s/_V_ sup el/_V_ sup ps el/;
	$a =~ s/_V_ sup tr/_V_ sup ps tr/;
	$a =~ s/_V_ sup abes/_V_ sup ps abes/;

	$a =~ s{ gi $}{ };
	$a =~ s{ prefix $}{ ? };

	if ($a =~ /_N_/) {
		if ($l =~ /[[:alpha:]]/ || $a =~ /sg|pl/) {
			$a .= 'l ';
		} else {
			$a .= '? digit ';
		}
	}

	$a .= '//';

#	print "'$a'\n";
	
	$a;
}
