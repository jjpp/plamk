#!/usr/bin/perl

use feature "switch"; # alates perl 5.10 

use Data::Dumper;
use utf8;

binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';


my @adj = ();
my @subst = ();
my @name = ();
my @verb = ();
my @adverb = ();
my @interject = ();
my @conjunct = ();
my @pronomen = ();
my @genitive = ();
my @prepostpos = ();
my @number = ();
my @ordinal = ();
my @other = ();

my @undecied = ();

while (<>) {
	chomp();
	s/'//g;
	$_ = substr($_, $[ + 1);

	($w, $k, undef, $stems) = split(' ', $_, 4);
	next unless $k;

	my %stem = split(/[:,]\s*/, $stems);
	$comm = '';


	my $w2 = ':' . $w;
	my $chain = substr($k, $[, 2);

	given ($chain) {
		when ("01") {
			# 
		}

		when ("02") { # {{{
			my $g = $stem{'b0'};

			if ($g eq $w . 'da') {
				$chain = '02_DA';
			} elsif ($w =~ /[ea][rlnm]$/ && $g eq er_ri($w)) {
				$chain = '02_I';
				$w2 =~ s/([ae])([rlnm])$/\u\1\2/; # kaduv E, A
			} elsif ($w =~ /[ae][rlnm]$/ && $g eq er_ra($w)) {
				$chain = '02_A';
				$w2 =~ s/([ae])([rlnm])$/\u\1\2/; # kaduv E. A
			} elsif ($g eq $w . 'i') {
				$chain = '02_I';
			} elsif ($w =~ /ne$/ && $g eq ne_se($w)) {
				$chain = '02_NE-SE';
				$w2 = ':' . substr($w, $[, -2);
			} elsif ($g eq s_nda($w)) {
				$chain = '02_S-NDA';
				$w2 =~ s/s$//;
			} elsif ($g eq s_ja($w)) {
				$chain = '02_S-JA';
				$w2 =~ s/s$//;
			} elsif ($w =~ /t$/ && $g =~ /nde$/) {
				$chain = '02_T-NDE';
				$w2 =~ s/t$//;
			} elsif ($w =~ /(.)\1[eaui][lrmn]$/ && $g eq CCVl_Cl('a', $w)) {
				$chain = '02_A';
				$w2 =~ s/(.)\1([eaui])([lmnr])/\1=\u\2\3/;
			} elsif ($w =~ /(.)\1[eaui][lrmn]$/ && $g eq CCVl_Cl('i', $w)) {
				$chain = '02_I';
				$w2 =~ s/(.)\1([eaui])([lmnr])/\1=\u\2\3/;
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
				$w2 =~ s/bus$/PUs/;
			} elsif ($w =~ /ges$/ && $g =~ /ksa$/) {
				$chain = '03_A';
				$w2 =~ s/ges/KEs/;
			} elsif ($w =~ /gas$/ && $g =~ /ksa$/) {
				$chain = '03_A';
				$w2 =~ s/gas/KAs/;
			} elsif ($w =~ /nnis$/ && $g =~ /ndsa$/) {
				$chain = '03_A';
				$w2 =~ s/nnis/nDIs/;
			} elsif ($w =~ /her$/ && $g =~ /tra$/) {
				$chain = '03_A';
				$w2 =~ s/her$/hTEr/;
			} elsif ($w =~ /nner$/ && $g =~ /ndri$/) {
				$chain = '03_I';
				$w2 =~ s/nner$/nDEr/;
			}

			else {
				$w = '! ??? ' . $w;
			}
		}
		when ("04") {
			my $g = $stem{'b0'}; 
			if ($g eq $w . 'me') {
			
			}

			else {
				$w = '! ??? ' . $w;
			}
		}
		when ("05") {
			my $g = $stem{'bt'};

			if ($g =~ /sa$/ && substr($w, $[, -2) eq substr($g, $[, -2)) {
				$chain = '05_A';
				$w2 =~ s/([aieu])s/\u\1s/;
			} elsif ($w =~ /bus$/ && $g =~ /psa$/) {
				$chain = '05_A';
				$w2 =~ s/bus$/PUs/;
			} elsif ($w =~ /ges$/ && $g =~ /ksa$/) {
				$chain = '05_A';
				$w2 =~ s/ges/KEs/;
			} elsif ($w =~ /gas$/ && $g =~ /ksa$/) {
				$chain = '05_A';
				$w2 =~ s/gas/KAs/;
			} elsif ($w =~ /nnis$/ && $g =~ /ndsa$/) {
				$chain = '05_A';
				$w2 =~ s/nnis/nDIs/;
			} elsif ($w eq $g . 's') {
				$chain = '05_S-0';
				$w2 = ':' . $g;
			} elsif ($g eq V_me($w)) {
				given ($w) {
					when (/i$/) { $chain = '05_I-ME'; }
					when (/u$/) { $chain = '05_U-ME'; }
					when (/e$/) { $chain = '05_E-ME'; }
				}
				$w2 =~ s/[iue]$//;
			} elsif ($w =~ /([lrn])\1e$/ && $g =~ /[lrn]dme$/) {
				$chain = '05_E-ME';
				$w2 =~ s/([lrn])\1e$/\1D/;
			} elsif ($w =~ /[dgb]e$/ && $g =~ /[tkp]me$/) {
				$chain = '05_E-ME';
				$w2 =~ s/de$/T/;
				$w2 =~ s/ge$/K/;
				$w2 =~ s/be$/P/;
			}

			else {
				$w = '! ??? ' . $w;
			}
			
		}
		when ("06") {
			# everything went better than expected.
		}
		when ("07") {
			my $g = $stem{'bt'};

			$chain = '07_S-0';

			if ($g . 's' eq $w) {
				$w2 = ':' . $g;
			} elsif ($g =~ /kri$/) { # nugris 
				$w2 =~ s/gris$/Kri/;
			} elsif ($w =~ /dis$/) { # aldis
				$w2 =~ s/dis$/Ti/;
			} elsif ($w =~ /([rln])\1as$/ && $g =~ /[rln]da$/) {
				$w2 =~ s/([rln])\1as$/\1Da/;
			} elsif ($w =~ /dras$/ && $g =~ /tra$/) {
				$w2 =~ s/dras$/Tra/;
			} elsif ($w =~ /b[rl]as$/ && $g =~ /p[rl]a$/) {
				$w2 =~ s/b([rl])as$/P\1a/;
			} elsif ($w =~ /kas$/ && $g =~ /kka$/) {
				$w2 =~ s/kas$/kKa/;
			} elsif ($w =~ /has$/ && $g =~ /hta$/) {
				$w2 =~ s/has$/hTa/;
			} elsif ($w =~ /bas$/ && $g =~ /pa$/) {
				$w2 =~ s/bas$/Pa/;
			} elsif ($w =~ /gas$/ && $g =~ /ka$/) {
				$w2 =~ s/gas$/Ka/;
			} elsif ($w =~ /([ptk])[aei]s$/ && $g =~ /([ptk])\1[aei]$/) {
				$w2 =~ s/([ptk])([aei])s$/\1=\2/;
			} elsif ($w =~ /([mv])[aei]s$/ && $g =~ /b[aei]$/) {
				$w2 =~ s/([mv])([aei])s$/B\2/;
			} elsif ($w =~ /jes$/ && $g =~ /ge$/) {
				$w2 =~ s/jes$/Ge/;
			} elsif ($w =~ /ras$/ && $g =~ /rga$/) {
				$w2 =~ s/ras$/rGa/;
			} elsif ($w =~ /das$/ && $g =~ /ta$/) {
				$w2 =~ s/das$/Ta/;
			} elsif ($w =~ /bjas$/ && $g =~ /pja$/) {
				$w2 =~ s/bjas$/Pja/;
			}

			else {
				$w = '! ??? ' . $w;
			}
		}
	
		when("08") {
			my $g = $stem{'bt'};

			if ($g eq er_ra($w)) { # kukal-kukla
				$chain = '08_A';
				$w2 =~ s/([ea])([lr])$/\u\1\2/;
			} elsif ($g eq er_re($w)) { # tütar-tütre
				$chain = '08_E';
				$w2 =~ s/([ea])([lr])$/\u\1\2/;
			} elsif ($w =~ /mm[ae][lr]$/ && $g =~ /mb[lr][ae]$/) {
				$chain = $g =~ /e$/ ? '08_E' : '08_A';
				$w2 =~ s/mm([ae])([lr])$/mB\2/;
			} elsif ($w =~ /nn[ae][lr]$/ && $g =~ /nd[lr][ae]$/) {
				$chain = $g =~ /e$/ ? '08_E' : '08_A';
				$w2 =~ s/nn([ae])([lr])$/nD\2/;
			}
		
			else {
				$w = '! ??? ' . $w;
			}
		}

		when("09") {
			my $g = $stem{'b0'};

			if ($g eq $w . 'e') {
				$chain = '09_E';
			} elsif ($g eq s_kse($w)) {
				$chain = '09_S-KSE';
				$w2 =~ s/s$//;
			}
			
			else {
				$w = '! ??? ' . $w;
			}
		}

		when ("10") {
			my $g = $stem{'b0'};
			if ($g eq ne_se($w)) {
				$chain = '10_NE-SE-S';
				$w2 =~ s/ne$//;
			}

			elsif ($g eq $w . 'se') {
				$chain = '10_0-SE-S';
			}

			elsif ($w =~ /ke$/ && $g =~ /kse$/) {
				$chain = '10_KSE';
				$w2 =~ s/ke$/k/;
			}
			
			else {
				$w = '! ??? ' . $w;
			}
		}

		when("11") {
			my $g = $stem{'b0'};
			if ($g eq $w . 'e') {
				$chain = '11';
			}
		}

		when ("12") {
			my $g = $stem{'b0'};
			if ($g eq ne_se($w)) {
				$chain = '12_NE-SE-S';
				$w2 =~ s/ne$//;
			}

			elsif ($w =~ /ke$/ && $g =~ /kese$/) {
				$chain = '12_0-SE-S';
			}

			else {
				$w = '! ??? ' . $w;
			}
		}

		when ("13") {
			my $g = $stem{'bn'};
			if ($g eq $w . 'e') {
				$chain = '13';
			}
		}

		when ("14") {
			$chain = '14';
			$w2 =~ s/s$/S/;
		}

		when ("15") {
			$chain = '15';
			$w2 =~ s/si$/S/;
		}

		when ("16") { }
		when ("17") {
			if ($stem{'a0g'} ne '#') {
				$chain = '17_Adt';
				$w2 =~ s/(.)([aeui])$/\1=\2/;
			}
		}

		when ("18") {
			$chain .= '_Adt' if $stem{'atv'} ne '#';
			$chain .= '_PlPV' if $stem{'anv'} ne '#';

			my $pikk = $stem{'atv'} ne '#' ? '=' : '';

			if ($w =~ /g[eaui]$/) {
				$w2 =~ s/g([eaui])$/G${pikk}\1/;
			} elsif ($w =~ /d[eaui]$/) {
				$w2 =~ s/d([eaui])$/D${pikk}\1/;
			} elsif ($w =~ /b[eaui]$/) {
				$w2 =~ s/b([eaui])$/B${pikk}\1/;
			} elsif ($w =~ /j[eaui]$/) {
				$w2 =~ s/j([eaui])$/j${pikk}\1/;
			} else {
				$w = '! ??? ' . $w;
			}
		}

		when ("19") { }

		when ("20") {
			my $g = $stem{'b0'};
			$w2 =~ s/i$/=/;
		}

		when ("21") { 
			$w2 =~ s/g([eaui])$/G=i/;
		}

		when ("22") {
			my $g = $stem{'bn'};

			unless ($g =~ /^$w/) {
				$w2 =~ s/([pktbgd])$/\u\1/;
			}

			given ($g) {
				when (/a$/) { $chain = '22_A'; }
				when (/e$/) { $chain = '22_E'; }
				when (/i$/) { $chain = '22_I'; }
				when (/u$/) { $chain = '22_U'; }
				default { $w = '! ??? ' . $w; }
			}

		}

		when ("23") {
			my $g = $stem{'bt'};

			given ($g) {
				when (/a$/) { $chain = '23_A'; }
				when (/i$/) { $chain = '23_I'; }
				default { $w = '! ??? ' . $w; }
			}

			$w2 =~ s/ss$/sS/;
		}

		when ("24") {
			my $g = $stem{'bn'};
			my $p = $stem{'bt'};

			given ($g) {
				when (/a$/) { $chain = '24_A'; }
				when (/e$/) { $chain = '24_E'; }
				when (/u$/) { $chain = '24_U'; }
				default { $w = '! ??? ' . $w; }
			}
			
			if ($w =~ /[gbd]e[rlv]$/ && $p =~ /[kpt][rlv][aeu]$/) {
				$w2 =~ s/ge([rlv])$/KE\1/;
				$w2 =~ s/be([rlv])$/PE\1/;
				$w2 =~ s/de([rlv])$/TE\1/;
			} elsif ($w =~ /[rlhsdb]i$/ && $g =~ /[rlhsdb]j[aeu]$/) {
				$w2 =~ s/i$/j/;
			} elsif ($w =~ /[rl]i$/ && $g =~ /[rl]ve$/) {
				$w2 =~ s/i$//;
				$chain = '24_I-VE';
			} elsif ($w =~ /hi$/ && $g =~ /h[eu]$/) {
				$w2 =~ s/i$/I/;
			}


			else {
				$w = '! ??? ' . $w;
			}


		}

		when ("25") {
			$w2 .= 'K';
		}

		when ("26") {
			if ($stem{'a0r'} eq '#' || $stem{'a0r'} eq '0') {
				$chain = '26_ii';
			} else {
				$chain = '26';
				$w2 =~ s/([aeuoöõüä])\1$/\1./;
			}
		}

		default {
			$w = '! TODO ' . $w;
		}
	}

	my $list = undef;
	given ($k) { # {{{
		when (/A/) {
			$w .= '+A';
			$w .= '+S' if /S/;
			$list = \@adj;
		}

		when (/S/) {
			$w .= '+S';
			$list = \@subst;
		}

		when (/H/) {
			$w .= '+H';
			$list = \@name;
		}

		when (/D/) {
			$w .= '+D';
			$list = \@adverb;
		}

		when (/V/) {
			$list = \@verb;
		}

		when (/I/) {
			$w .= '+I';
			$list = \@interject;
		}

		when (/J/) {
			$w .= '+J';
			$list = \@conjunct;
		}

		when (/P/) {
			$w .= '+P';
			$list = \@pronomen;
		}

		when (/G/) {
			$w .= '+G';
			$list = \@genitive;
		}

		when (/K/) {
			$w .= '+K';
			$list = \@preppostpos;
		}

		when (/N/) {
			$w .= '+N';
			$list = \@number;
		}

		when (/O/) {
			$w .= '+O';
			$list = \@ordinal;
		}

		when (/X/) {
			$w .= '+X';
			$list = \@other;
		}

		default {
			print "Tundmatu sõnaliik '$k' - $w / $stems\n";
			$list = \@undecied;
		}
		
	} # }}}

	if ($w2 eq ':' . $w) {
		$w2 = '';
	}

	print "$w$w2 $chain; ! $stems\n" if $chain =~ /^26/;

	push @{$list}, " $w$w2 $chain; ! $comm$stems\n";
	$total ++;
}

print "Kokku sõnu: $total\n";
write_lex("lex_adj.txt", "Omadussõna", @adj);
write_lex("lex_subst.txt", "Nimisõna", @subst);
write_lex("lex_name.txt", "Pärisnimi", @name);

exit 0;

sub write_lex {
	my $file = shift;
	my $lexicon = shift;
	open F, ">$file";
	binmode F, ':utf8';
	print F "LEXICON $lexicon\n";
	print F @_;
	close F;
	print "Sõnastik '$lexicon': " . scalar(@_) . " rida.\n";
}

sub er_ri {
	my $x = shift;
	$x =~ s/[ea]([rlnm])$/\1i/;
	$x;
}

sub er_ra {
	my $x = shift;
	$x =~ s/[ea]([rlnm])$/\1a/;
	$x;
}

sub er_re {
	my $x = shift;
	$x =~ s/[ea]([rlnm])$/\1e/;
	$x;
}

sub er_ru {
	my $x = shift;
	$x =~ s/[ea]([rlnm])$/\1u/;
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

sub s_nda {
	my $x = shift;
	$x =~ s/s$/nda/;
	$x;
}

sub s_kse {
	my $x = shift;
	$x =~ s/s$/kse/;
	$x;
}

sub V_me {
	my $x = shift;
	$x =~ s/[eiu]$/me/;
	$x;
}

sub CCVl_Cl {
	my $suffix = shift;
	my $x = shift;
	$x =~ s/(.)\1[eaui]([lmnr])$/\1\2$suffix/;
	$x;
}

# vim: foldmethod=marker
