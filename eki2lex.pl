#!/usr/bin/perl

use feature "switch"; # alates perl 5.10 

use Data::Dumper;

open ADJ, ">lex_adj.txt";
print ADJ "LEXICON Omadussõna\n";
my $adj = 0;


while (<>) {
	chomp();
	s/'//g;
	$_ = substr($_, $[ + 1);

	($w, $k, undef, $stems) = split(' ', $_, 4);
	next unless $k;

	my %stem = split(/[:,]\s*/, $stems);
	$comm = '';

	if ($k =~ /A$/) {
		# omadussõna
		my $w2 = ':' . $w;
		my $chain = substr($k, $[, 2);

		given ($chain) {
			when ("02") { # {{{
				my $g = $stem{'b0'};

				if ($g eq $w . 'da') {
					$chain = '02_DA';
				} elsif ($w =~ /e[rl]$/ && $g eq er_ri($w)) {
					$chain = '02_I';
					$w2 =~ s/e([rl])$/E\1/; # kaduv E
				} elsif ($g eq $w . 'i') {
					$chain = '02_I';
				} elsif ($w =~ /ne$/ && $g eq ne_se($w)) {
					$chain = '02_NE-SE';
					$w2 = ':' . substr($w, $[, -2);
				} elsif ($w eq $g . 's') {
					$chain = '02_S-0';
					$w2 = ':' . $g;
				} elsif ($w . 'e' eq $g) {
					$chain = '02_S-0';
					$w2 = ':' . $g;
				} elsif ($g eq $w . 'u') {
					$chain = '02_U';
				} elsif ($g eq $w . 'a') {
					$chain = '02_A';
#				} elsif ($w =~ /s$/ && $g =~ /ja$/ && $g eq s_ja($w)) {
#					$chain = '02_A';
#					$w2 =~ 
				}
				elsif ($w =~ /(.)u([lrvs])$/ && $g =~ /[lrvs]u$/) {
					$chain = '02_U';
					$w2 =~ s/(.)u([lrvs])$/\1U\2/;
				}
				elsif ($w =~ /(.)\1e([lrv])$/ && $g =~ /[lrv]a$/) {
					$chain = '02_A';
					$w2 =~ s/(.)\1e([lrv])$/\1=E\2/;
				}
				elsif ($w =~ /(.)\1u([lrvs])$/ && $g =~ /[lrvs]a$/) {
					$chain = '02_A';
					$w2 =~ s/(.)\1u([lrvs])$/\1=U\2/;
				}
				elsif ($w =~ /(.)\1i([lrvs])$/ && $g =~ /[lrvs]a$/) {
					$chain = '02_A';
					$w2 =~ s/(.)\1i([lrvs])$/\1=I\2/;
				}
				elsif ($w =~ /(.)e([lrv])$/ && $g =~ /[lrv]a$/) {
					$chain = '02_A';
					$w2 =~ s/(.)e([lrv])$/\1=E\2/;
				}
				elsif ($w =~ /(.)u([lrvs])$/ && $g =~ /[lrvs]a$/) {
					$chain = '02_A';
					$w2 =~ s/(.)u([lrvs])$/\1U\2/;
				}
				elsif ($w =~ /(.)i([lrvs])$/ && $g =~ /[lrvs]a$/) {
					$chain = '02_A';
					$w2 =~ s/(.)i([lrvs])$/\1=I\2/;
				} elsif ($w =~ /ne$/ && $g =~ /sa$/) {
					$chain = '02_A';
					$w2 =~ s/ne$/NE/;
				} elsif ($w eq $g && $g =~ /a$/) {
					$chain = '02_A';
					$w2 = substr($w2, $[, -1);

				}
				else {
					$w = '! ??? ' . $w;
				}
			} # }}}
			when ("03") {
				my $g = $stem{'bt'};
				
				if ($g =~ /sa$/ && substr($w, $[, -2) eq substr($g, $[, -2)) {
					$chain = '03_A';
					$w2 =~ s/([aieu])s/\u\1s/;
				} elsif ($w =~ /bus$/ && $g =~ /psa$/) {
					$chain = '03_A';
					$w2 =~ s/bus$/PUS/;
					$w = '! TODO ';
				} elsif ($w =~ /ges$/ && $g =~ /ksa$/) {
					$chain = '03_A';
					$w2 =~ s/ges/KES/;
					$w = '! TODO ';
				} elsif ($w =~ /gas$/ && $g =~ /ksa$/) {
					$chain = '03_A';
					$w2 =~ s/gas/KAS/;
					$w = '! TODO ';
				} elsif ($w =~ /nnis$/ && $g =~ /ndsa$/) {
					$chain = '03_A';
					$w2 =~ s/nnis/nDis/;
					$w = '! TODO ';
				} elsif ($w =~ /her$/ && $g =~ /tra$/) {
					$chain = '03_A';
					$w2 =~ s/her$/hTEr/;
				}

				else {
					$w = '! ??? ' . $w;
				}
			}
			when ("04") {
			}
			default {
				$w = '! TODO ' . $w;
			}
		}

#		next unless $chain eq '03_A';

		print "$w+A$w2 $chain; ! $stems\n" if $chain =~ /^05/;

		print ADJ " $w+A$w2 $chain; ! $comm$stems\n";
		$adj++;
	}

	$total ++;
}

close ADJ;

print "Kokku sõnu: $total\n";
print "Omadussõnu: $adj\n";

exit 0;

sub er_ri {
	my $x = shift;
	$x =~ s/e([rl])$/\1i/;
	$x;
}

sub ne_se {
	my $x = shift;
	$x =~ s/ne$/se/;
	$x;
}

sub s_ja {
	my $x = shift;
	$x =~ s/s$/ja/;
	$x;
}

