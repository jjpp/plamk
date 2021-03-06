#!/usr/bin/perl -w

# Copyright © 2010 by Jaak Pruulmann-Vengerefeldt. All rights reserved.

use feature "switch"; # alates perl 5.10 

use Data::Dumper;
use utf8;
use strict;

binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';


my @tyved = ();
my @kind = ();

my $total = 0;

while (<>) {
	chomp();
	s/'//g;
	s/`//g;
	next if /^$/;
	$_ = substr($_, $[ + 1);


	my ($w, $k, undef, $stems) = split(' ', $_, 4);
	next unless $k;

	$stems = '' unless defined($stems);
	my %stem = split(/[:,]\s*/, $stems);
	my $comm = '';
	@kind = ();


#	$w = lc($w);

	my $chain = substr($k, $[, 2);
	if ($chain >= 27 && $chain < 39) {
		$w =~ s/ma$//;
	}

	my $w2 = ':' . $w;


	given ($chain) {
		when ("01") {
			# 
		}

		when ("02") { # {{{
			my $g = $stem{'b0'};

			if ($w eq 'mõlema') {
				$chain = '02_S-0';
			} elsif ($g eq $w . 'da') {
				$chain = '02_DA';
			} elsif ($w =~ /[ea][rlnm]$/ && $g eq er_ri($w)) {
				$chain = '02_I';
				$w2 =~ s/([ae])([rlnm])$/\u${1}1$2/; # kaduv E, A
			} elsif ($w =~ /[ae][rlnm]$/ && $g eq er_ra($w)) {
				$chain = '02_A';
				$w2 =~ s/([ae])([rlnm])$/\u${1}1$2/; # kaduv E. A
			} elsif ($g eq $w . 'i') {
				$chain = '02_I';
			} elsif ($w =~ /ne$/ && $g eq ne_se($w)) {
				$w2 = ':' . substr($w, $[, -2);
				$chain = $w2 =~ /[aeiouõäöü]$/ ? '02_Vok_NE-SE' : '02_NE-SE';
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
				$w2 =~ s/(.)\1([eaui])([lmnr])/$1=\u${2}1$3/;
			} elsif ($w =~ /(.)\1[eaui][lrmn]$/ && $g eq CCVl_Cl('i', $w)) {
				$chain = '02_I';
				$w2 =~ s/(.)\1([eaui])([lmnr])/$1=\u${2}1$3/;
			} elsif ($w eq $g . 's') {
				if ($w =~ /[kg]as$/ && syllcount($g) == 3) {
					$chain = '02_GAS_S-0';
					$w2 =~ s/as$//;
				} else {
					$chain = '02_S-0';
					$w2 = ':' . $g;
				}
			} elsif ($w . 'e' eq $g) {
				$chain = '02_E';
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
				$w2 =~ s/(.)u([lrvs])$/$1U1$2/;
			}
			elsif ($w =~ /(.)\1e([lrv])$/ && $g =~ /[lrv]a$/) {
				$chain = '02_A';
				$w2 =~ s/(.)\1e([lrv])$/$1=E1$2/;
			}
			elsif ($w =~ /(.)\1u([lrvs])$/ && $g =~ /[lrvs]a$/) {
				$chain = '02_A';
				$w2 =~ s/(.)\1u([lrvs])$/$1=U1$2/;
			}
			elsif ($w =~ /(.)\1i([lrvs])$/ && $g =~ /[lrvs]a$/) {
				$chain = '02_A';
				$w2 =~ s/(.)\1i([lrvs])$/$1=I1$2/;
			}
			elsif ($w =~ /(.)e([lrv])$/ && $g =~ /[lrv]a$/) {
				$chain = '02_A';
				$w2 =~ s/(.)e([lrv])$/$1=E1$2/;
			}
			elsif ($w =~ /(.)u([lrvs])$/ && $g =~ /[lrvs]a$/) {
				$chain = '02_A';
				$w2 =~ s/(.)u([lrvs])$/$1U1$2/;
			}
			elsif ($w =~ /(.)i([lrvs])$/ && $g =~ /[lrvs]a$/) {
				$chain = '02_A';
				$w2 =~ s/(.)i([lrvs])$/$1=I1$2/;
			} elsif ($w =~ /ne$/ && $g =~ /sa$/) {
				$chain = '02_NE-SA';
				$w2 =~ s/ne$//;
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
				$w2 =~ s/([aieu])s/\u${1}1s/;
			} elsif ($w =~ /bus$/ && $g =~ /psa$/) {
				$chain = '03_A';
				$w2 =~ s/bus$/P1U1s/;
			} elsif ($w =~ /ges$/ && $g =~ /ksa$/) {
				$chain = '03_A';
				$w2 =~ s/ges/K1E1s/;
			} elsif ($w =~ /gas$/ && $g =~ /ksa$/) {
				$chain = '03_A';
				$w2 =~ s/gas/K1A1s/;
			} elsif ($w =~ /nnis$/ && $g =~ /ndsa$/) {
				$chain = '03_A';
				$w2 =~ s/nnis/nD1I1s/;
			} elsif ($w =~ /her$/ && $g =~ /tra$/) {
				$chain = '03_A';
				$w2 =~ s/her$/hT1E1r/;
			} elsif ($w =~ /nner$/ && $g =~ /ndri$/) {
				$chain = '03_I';
				$w2 =~ s/nner$/nD1E1r/;
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
				$w2 =~ s/([aieu])s/\u${1}1s/;
			} elsif ($w =~ /bus$/ && $g =~ /psa$/) {
				$chain = '05_A';
				$w2 =~ s/bus$/P1U1s/;
			} elsif ($w =~ /ges$/ && $g =~ /ksa$/) {
				$chain = '05_A';
				$w2 =~ s/ges/K1E1s/;
			} elsif ($w =~ /gas$/ && $g =~ /ksa$/) {
				$chain = '05_A';
				$w2 =~ s/gas/K1A1s/;
			} elsif ($w =~ /nnis$/ && $g =~ /ndsa$/) {
				$chain = '05_A';
				$w2 =~ s/nnis/nD1I1s/;
			} elsif ($w =~ /hus$/ && $g =~ /htu$/) {
				$chain = '05_S-0';
				$w2 =~ s/hus/hT1u/;
			} elsif ($w eq $g . 's') {
				$chain = '05_S-0';
				$w2 = ':' . $g;
			} elsif ($g eq V_me($w)) {
				given ($w) {
					when (/i$/) { $chain = '05_I-ME'; }
					when (/u$/) { $chain = '05_U-ME'; }
					when (/e$/) { $chain = '05_E-ME'; }
					when (/a$/) { $chain = '05_A-ME'; }
				}
				$w2 =~ s/[aiue]$//;
			} elsif ($w =~ /([lrn])\1e$/ && $g =~ /[lrn]dme$/) {
				$chain = '05_E-ME';
				$w2 =~ s/([lrn])\1e$/$1D1/;
			} elsif ($w =~ /[dgb]e$/ && $g =~ /[tkp]me$/) {
				$chain = '05_E-ME';
				$w2 =~ s/de$/T1/;
				$w2 =~ s/ge$/K1/;
				$w2 =~ s/be$/P1/;
			} elsif ($w =~ /[sh]e$/ && $g =~ /[sh]kme$/) {
				$chain = '05_E-ME';
				$w2 =~ s/([sh])e$/$1K1/;
			} elsif ($w =~ /[ui]e$/ && $g =~ /[ui]dme$/) {
				$chain = '05_E-ME';
				$w2 =~ s/([ui])e$/$1D1/;
			} elsif ($w =~ /ie$/ && $g =~ /igme$/) {
				$chain = '05_E-ME';
				$w2 =~ s/ie$/iG1/;
			} elsif ($w =~ /he$/ && $g =~ /htme$/) {
				$chain = '05_E-ME';
				$w2 =~ s/he$/hT1/;
			} elsif ($w =~ /me$/ && $g =~ /mne$/) {
				$chain = '05_E-NE';
				$w2 =~ s/mme$/m=/;
				$w2 =~ s/me$/m/;
			}

			else {
				$w = '! ??? ' . $w;
			}
			
		}
		when ("06") {
			my $g = $stem{'at'};

			if ($g eq $w) {
				# välte muutus? kõik jääb samaks
			} elsif ($w =~ /ve$/ && $g =~ /be$/) {
				$w2 =~ s/ve$/B1e/;
			} elsif ($w =~ /ve$/ && $g =~ /be$/) {
				$w2 =~ s/ve$/B1e/;
			} elsif ($w =~ /([kpt])e$/ && $g =~ /([kpt])\1e$/) {
				$w2 =~ s/([kpt])e$/$1\u${1}1e/;
			} elsif ($w =~ /([lnr])\1e$/ && $g =~ /[lnr]de$/) {
				$w2 =~ s/([lnr])\1e/$1D1e/;
			} elsif ($w =~ /mme$/ && $g =~ /mbe$/) {
				$w2 =~ s/mme/mB1e/;
			} elsif ($w =~ /[lnr]e$/ && $g =~ /[lnr]de$/) {
				$w2 =~ s/([lnr])e/$1D1e/;
			} elsif ($w =~ /he$/ && $g =~ /hte$/) {
				$w2 =~ s/he/hT1e/;
			} elsif ($w =~ /he$/ && $g =~ /hke$/) {
				$w2 =~ s/he/hK1e/;
			} elsif ($w =~ /se$/ && $g =~ /ske$/) {
				$w2 =~ s/se/sK1e/;
			} elsif ($w =~ /[lr]e$/ && $g =~ /[lr]ge$/) {
				$w2 =~ s/([lr])e/$1G1e/;
			} elsif ($w =~ /se$/ && $g =~ /sse$/) {
				$w2 =~ s/se/sS1e/;
		 	} elsif ($w =~ /ge$/ && $g =~ /ke$/) {
				$w2 =~ s/ge$/K1e/;
		 	} elsif ($w =~ /be$/ && $g =~ /pe$/) {
				$w2 =~ s/be$/P1e/;
		 	} elsif ($w =~ /de$/ && $g =~ /te$/) {
				$w2 =~ s/de$/T1e/;
		 	} elsif ($w =~ /je$/ && $g =~ /ge$/) {
				$w2 =~ s/je$/G1e/;
		 	} elsif ($w =~ /e$/ && $g =~ /de$/) {
				$w2 =~ s/e$/D1e/;
		 	} elsif ($w =~ /e$/ && $g =~ /ge$/) {
				$w2 =~ s/e$/G1e/;
		 	} elsif ($w =~ /dve$/ && $g =~ /tve$/) {
				$w2 =~ s/dve$/T1ve/;
			}

			else {
				$w = '! ??? ' . $w;
			}
		}

		when ("07") {
			my $g = $stem{'bt'};

			$chain = '07_S-0';

			if ($g . 's' eq $w) {
				$w2 = ':' . $g;
			} elsif ($g =~ /kri$/) { # nugris 
				$w2 =~ s/gris$/K1ri/;
			} elsif ($w =~ /dis$/) { # aldis
				$w2 =~ s/dis$/T1i/;
			} elsif ($w =~ /([rln])\1as$/ && $g =~ /[rln]da$/) {
				$w2 =~ s/([rln])\1as$/$1D1a/;
			} elsif ($w =~ /dras$/ && $g =~ /tra$/) {
				$w2 =~ s/dras$/T1ra/;
			} elsif ($w =~ /b[rl]as$/ && $g =~ /p[rl]a$/) {
				$w2 =~ s/b([rl])as$/P1$1a/;
			} elsif ($w =~ /kas$/ && $g =~ /kka$/) {
				$w2 =~ s/kas$/kK1a/;
			} elsif ($w =~ /has$/ && $g =~ /hta$/) {
				$w2 =~ s/has$/hT1a/;
			} elsif ($w =~ /bas$/ && $g =~ /pa$/) {
				$w2 =~ s/bas$/P1a/;
			} elsif ($w =~ /gas$/ && $g =~ /ka$/) {
				$w2 =~ s/gas$/K1a/;
			} elsif ($w =~ /([ptk])[aei]s$/ && $g =~ /([ptk])\1[aei]$/) {
				$w2 =~ s/([ptk])([aei])s$/$1\u${1}1$2/;
			} elsif ($w =~ /([mv])[aei]s$/ && $g =~ /b[aei]$/) {
				$w2 =~ s/([mv])([aei])s$/B1$2/;
			} elsif ($w =~ /jes$/ && $g =~ /ge$/) {
				$w2 =~ s/jes$/G1e/;
			} elsif ($w =~ /ras$/ && $g =~ /rga$/) {
				$w2 =~ s/ras$/rG1a/;
			} elsif ($w =~ /das$/ && $g =~ /ta$/) {
				$w2 =~ s/das$/T1a/;
			} elsif ($w =~ /bjas$/ && $g =~ /pja$/) {
				$w2 =~ s/bjas$/P1ja/;
			}

			else {
				$w = '! ??? ' . $w;
			}
		}
	
		when("08") {
			my $g = $stem{'bt'};

			if ($w =~ /mm[ae][lr]$/ && $g =~ /mb[lr][ae]$/) {
				$chain = $g =~ /e$/ ? '08_E' : '08_A';
				$w2 =~ s/mm([ae])([lr])$/mB1$2/;
			} elsif ($w =~ /nn[ae][lr]$/ && $g =~ /nd[lr][ae]$/) {
				$chain = $g =~ /e$/ ? '08_E' : '08_A';
				$w2 =~ s/nn([ae])([lr])$/nD1\u${1}1$2/;
			} elsif ($g eq er_ra($w)) { # kukal-kukla
				$chain = '08_A';
				$w2 =~ s/([ea])([lrnm])$/\u${1}1$2/;
			} elsif ($g eq er_re($w)) { # tütar-tütre
				$chain = '08_E';
				$w2 =~ s/([ea])([lrnm])$/\u${1}1$2/;
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
			} else {
				$w = '! ??? ' . $w;
			}
		}

		when ("14") {
			$chain = '14';
			my $g = $stem{'bn'};

			if ($g eq $w . 'e') {
				# 
			} elsif ($g eq s_e($w)) {
				$w2 =~ s/s$/S1/;
			} elsif ($g eq s_ne($w)) {
				$chain = '14_S-NE';
				$w2 =~ s/s$//;
			} else { #elsif ($w =~ /rs$/ && $g =~ /rre$/) {
				$w2 =~ s/s$/S1/;
			}
			
#			else {
#				$w = '! ??? ' . $w;
#			}
				
		}

		when ("15") {
			$chain = '15';
			$w2 =~ s/si$/S1/;
		}

		when ("16") { 
			if ($stem{'a0g'} ne '#') {
				if ($w =~ /gri$/ && $stem{'a0g'} =~ /kri$/) {
					$chain = '16_GRI_Adt';
					$w2 =~ s/gri$//;
				} else {
					$chain = '16_Adt';
					$w2 =~ s/(.)([aeui])$/$1=$2/;
				}
			}
		}

		when ("17") {
			if ($w eq 'ini') {
				$w = '! erand ' . $w;
			}

			if ($stem{'a0g'} ne '#') {
				$chain = '17_Adt';
				$w2 =~ s/(.)([aeui])$/$1=$2/;
			}
		}

		when ("18") {
#			$chain .= '_Adt' if $stem{'atg'} ne '#';
			$chain .= '_PlPV' if $stem{'atv'} ne '#';
			$chain .= '_PlV' if $stem{'anv'} ne '#';

			my $pikk = $stem{'atg'} ne '#' ? '=' : '';

			if ($w =~ /g[eaui]$/) {
				$w2 =~ s/g([eaui])$/G1${pikk}$1/;
			} elsif ($w =~ /d[eaui]$/) {
				$w2 =~ s/d([eaui])$/D1${pikk}$1/;
			} elsif ($w =~ /b[eaui]$/) {
				$w2 =~ s/b([eaui])$/B1${pikk}$1/;
			} elsif ($w =~ /j[eaui]$/) {
				$w2 =~ s/j([eaui])$/j${pikk}$1/;
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
			$w2 =~ s/g([eaui])$/G1=/;

			if ($w eq 'tõbi') {
				$w = '! erand ' . $w;
			}
		}

		when ("22") {
			my $g = $stem{'bn'};
			my $p = $stem{'bt'};

			if (($w eq 'silm' && $g eq 'silma') ||
			    ($w eq 'pikk' && $g eq 'pika') ||
			    ($w eq 'king' && $g eq 'kinga')) {
				$w = '! erandlik tyvemitmus: ' . $w;
			} elsif ($g =~ /^${w}()[aeiu]$/ && $g eq $p) {
				$g =~ /([aeiu])$/;
				$chain = "22_\u$1";
			} elsif ($g =~ /^${w}()[aeiu]$/ && $w =~ /[kpt]$/) {
				$w2 =~ s/([kpt])$/$1\u${1}1/;
				$chain = "22_KPT_I";
			} elsif ($w =~ /[kpt](v?)$/ && $g =~ /[gbd](v?)[aeiu]$/) {
				$w2 =~ s/([kpt])(v?)$/\u${1}1$2/;
				$g =~ /([aeiu])$/;
				$chain = "22_\u$1";
			} elsif ($w =~ /([kpts])\1$/ && $g =~ /[kpts][aeiu]$/) {
				$w2 =~ s/([kpts])$/\u${1}1/;
				$g =~ /([aeiu])$/;
				$chain = "22_\u$1";
			} elsif ($w =~ /([fš])\1$/ && $g =~ /[fš][aeiu]$/) {
				$w2 =~ s/([fš])$/=/;
				$chain = "22_FI";
			} elsif ($w =~ /h[tk]$/ && $g =~ /h[aeiu]$/) {
				$w2 =~ s/([kpt])$/\u${1}1/;
				$g =~ /([aeiu])$/;
				$chain = "22_\u$1";
			} elsif ($w =~ /sk$/ && $g =~ /s[aeiu]$/) {
				$w2 =~ s/([kpt])$/\u${1}1/;
				$g =~ /([aeiu])$/;
				$chain = "22_\u$1";
			} elsif ($w =~ /[rnl]d$/ && $g =~ /([rnl])\1[aeiu]$/) {
				$w2 =~ s/([gbd])$/\u${1}1/;
				$g =~ /([aeiu])$/;
				$chain = "22_\u$1";
			} elsif ($w =~ /[rnl]b$/ && $g =~ /([rnl])v[aeiu]$/) {
				$w2 =~ s/([gbd])$/\u${1}1/;
				$g =~ /([aeiu])$/;
				$chain = "22_\u$1";
			} elsif ($w =~ /mb$/ && $g =~ /mm[aeiu]$/) {
				$w2 =~ s/([gbd])$/\u${1}1/;
				$g =~ /([aeiu])$/;
				$chain = "22_\u$1";
			} elsif ($w =~ /[rl]g$/ && $g =~ /[rl]j[aeu]$/) {
				$w2 =~ s/([gbd])$/\u${1}1/;
				$g =~ /([aeiu])$/;
				$chain = "22_\u$1";
			} elsif ($g =~ /[aeiu]$/ && 
					(($w eq _V($g) . 'g') 
					|| ($w eq _V($g) . 'd')))  { # urg-uru, laid-laiu
				$w2 =~ s/([gbd])$/\u${1}1/;
				$g =~ /([aeiu])$/;
				$chain = "22_\u$1";
			} elsif ($w =~ /b$/ && $g =~ /v[ai]$/) {
				$w2 =~ s/([gbd])$/\u${1}1/;
				$g =~ /([aeiu])$/;
				$chain = "22_\u$1";
			} elsif ($w =~ /^$g()[dg]$/ && $stem{'bt'} =~ /u$/) {
				$w2 =~ s/([gbd])$/\u${1}1/;
				$chain = '22_0-U';
			} elsif ($w =~ /ks$/ && $g =~ /he$/) {
				$w2 =~ s/ks$//;
				$chain = '22_KS-HE';
			} elsif ($w =~ /uub$/ && $g =~ /uue$/) { 
				$w2 =~ s/b$//;
				$chain = '22_B-E-BE';
			} elsif ($w =~ /ood$/ && $g =~ /oe$/) {
				$w2 =~ s/od$//;
				$chain = '22_OOD-OE';
			} elsif ($w =~ /aa[dsg]$/ && $g =~ /ae$/) {
				$w2 =~ s/a([dsg])$//;
				$chain = "22_AA\u$1-AE";
			} elsif ($w =~ /eg$/ && $g =~ /ja$/) {
				$w2 =~ s/eg$//;
				$chain = '22_EG-JA';
			}

			else {
				$w = '! ??? ' . $w;
			}

#			unless ($g =~ /^$w/) {
#				$w2 =~ s/([ao])eg$/$1JG/;
#				$w2 =~ s/([pktbgd])$/\u$1/;
#			}
#
#			given ($g) {
#				when (/a$/) { $chain = '22_A'; }
#				when (/e$/) { $chain = '22_E'; }
#				when (/i$/) { $chain = '22_I'; }
#				when (/u$/) { $chain = '22_U'; }
#				default { $chain = '22_0-U'; }
#			}
		}

		when ("23") {
			my $g = $stem{'bt'};

			given ($g) {
				when (/a$/) { $chain = '23_A'; }
				when (/i$/) { $chain = '23_I'; }
				default { $w = '! ??? ' . $w; }
			}

			$w2 =~ s/ss$/sS1/;
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
				$w2 =~ s/ge([rlv])$/K1E1$1/;
				$w2 =~ s/be([rlv])$/P1E1$1/;
				$w2 =~ s/de([rlv])$/T1E1$1/;
			} elsif ($w =~ /[rlhsdb]i$/ && $g =~ /[rlhsdb]j[aeu]$/ && $g eq $p) {
				$w2 =~ s/i$/j/;
			} elsif ($w =~ /[rlhsdb]i$/ && $g =~ /[rlhsdb]j[aeu]$/) {
				$w2 =~ s/gi$/K1j/;
				$w2 =~ s/di$/T1j/;
				$w2 =~ s/bi$/P1j/;
			} elsif ($w =~ /[rl]i$/ && $g =~ /[rl]ve$/) {
				$w2 =~ s/i$//;
				$chain = '24_I-VE';
			} elsif ($w =~ /hi$/ && $g =~ /h[eu]$/) {
				$w2 =~ s/i$/I1/;
			}


			else {
				$w = '! ??? ' . $w;
			}


		}

		when ("25") {
			$w2 .= 'K1';
		}

		when ("26") {
			if ($stem{'a0r'} eq '#' || $stem{'a0r'} eq '0') {
				$chain = '26_ii';
			} else {
				$chain = '26';
				$w2 =~ s/([aeuoöõüä])\1$/$1./;
			}
		}

		when ("27") { }

		when ("28") {
			$b = $stem{'an'};

			if ($w eq $b) {
				# 
			} elsif ($w =~ /([gbdkpt])[aeiu]$/) {
				$w2 =~ s/([gbdkpt])([aeiu])$/\u${1}1$2/;
			} elsif ($w =~ /([fšs])\1[aeiu]$/) {
				$w2 =~ s/([fšs])\1([aeiu])$/$1=$2/;
			}

			else {
				$w = '! ??? ' .$w;
			}

			$w = '! /// ' . $w if ($w eq 'küündi');
		}

		when ("29") {
			$b = $stem{'an'};

			if ($w eq $b) {
				# 
			} elsif ($w =~ /([gbdkpt])[aeiu]$/) {
				$w2 =~ s/([gbdkpt])([aeiu])$/\u${1}1$2/;
			} elsif ($w =~ /([fšs])\1[aeiu]$/) {
				$w2 =~ s/([fšs])\1([aeiu])$/$1=2$2/;
			} elsif ($w =~ /([kpt])[rlj]a$/) {
				$w2 =~ s/([kpt])([rlj])a$/\u${1}1$2a/;
			}

			else {
				$w = '! ??? ' .$w;
			}
		}

		when ("30") {
			$w2 =~ s/le$//;
			$w2 =~ s/([gbdkpt])$/\u${1}1/ unless $w eq er_re($stem{'bn'});
			if ($w eq 'vähkre') {
				$w = '! erand ' . $w;
			}
		}

		when ("31") {
			$w2 =~ s/le$/l/;
		}

		when ("32") {
			$chain = '32_E' if $stem{'bn'} =~ /e$/;
		}

		when ("33") {
			$chain = '33_E' if $stem{'bn'} =~ /e$/;
		}

		when ("34") {
			if ($w eq 'tund') {
				$w = '! erandlik tyvevokaal ' . $w;
			} elsif ($stem{'bn'} eq $w . 'a') {
				#
			} elsif ($stem{'cn'} . 'd' eq $w) {
				$chain = '34_D_TUD';
				$w2 =~ s/d$//;
			} elsif ($stem{'cn'} . 'k' eq $w) {
				$chain = '34_K_TUD';
				$w2 =~ s/k$//;
			} else {
				$w2 =~ s/([gbdkpt])$/\u${1}1/;
			}
		}

		when ("35") {
			$chain = $w =~ /p$/ ? '35_P' : '35_T';
			if ($stem{'cn'} ne $w . 'e') {
				$w2 =~ s/([pt])$/\u${1}1/;
			}
		}

		when ("36") {
			$w2 =~ s/e$//;

			$w = '! ??? ' . $w if $stem{'bn'} eq '#'; # pesema-kusema
		}

		when ("37") { }

		when ("38") { 
			if ($stem{'ct'} eq '#') {
				$chain = '38_SIN';
			} else {
				$w2 =~ s/([aeiouäöüõ])\1$/$1./;
			}
		}

		when ("41") { # muutumatud sõnad
			$chain = 'GI';
#			given ($k) {
#				when(/I/) {
#					$chain = 'GI';
#				}
#
#				when(/D/) {
#					$chain = 'GI';
#				}
#
#				default {
#					$w = '! ??? ' . $k . ' ' . $w;
#				}
#			}
		}

		default {
			$w = '! TODO ' . $w;
		}
	}

	if (substr($k, $[, 2) >= 27 && substr($k, $[, 2) < 39 && $w !~ /^\s*\!/) {
		$w = substr($w2, $[ + 1);
	}

	my $list = undef;
	push (@kind, '+Adv') if $k =~ /D/;
	push (@kind, '+A') if $k =~ /A/;
	push (@kind, '+S') if $k =~ /S/;
	push (@kind, '+H') if $k =~ /H/;
	push (@kind, '') if $k =~ /V/;
	push (@kind, '+I') if $k =~ /I/;
	push (@kind, '+J') if $k =~ /J/;
	push (@kind, '+Pron') if $k =~ /P/;
	push (@kind, '+G') if $k =~ /G/;
	push (@kind, '+K') if $k =~ /K/;
	push (@kind, '+Num') if $k =~ /N/;
	push (@kind, '+Ord') if $k =~ /O/;
	push (@kind, '+X') if $k =~ /X/;

	if (!scalar @kind) {
		print "Tundmatu sõnaliik '$k' - $w / $stems\n";
		push @kind, '+X';
	} # }}}


#	print "$w$w2 $chain; ! $stems\n" if $k =~ /^13/;

	for (@kind) {
		my $w3 = $w2;
		if ($w3 eq ':' . $w . $_) {
			$w3 = '';
		}
		push @tyved, " $w$_$w3 $chain; ! ($k -> @kind) $comm$stems\n";
	}
	$total ++;
}

write_lex("stems.lexc", "Tüved", @tyved);

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

sub er_ri {
	my $x = shift;
	$x =~ s/[ea]([rlnm])$/$1i/;
	$x;
}

sub er_ra {
	my $x = shift;
	$x =~ s/[ea]([rlnm])$/$1a/;
	$x;
}

sub er_re {
	my $x = shift;
	$x =~ s/[ea]([rlnm])$/$1e/;
	$x;
}

sub er_ru {
	my $x = shift;
	$x =~ s/[ea]([rlnm])$/$1u/;
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

sub s_e {
	my $x = shift;
	$x =~ s/s$/e/;
	$x;
}

sub s_ne {
	my $x = shift;
	$x =~ s/s$/ne/;
	$x;
}

sub V_me {
	my $x = shift;
	$x =~ s/[aeiu]$/me/;
	$x;
}

sub _V {
	my $x = shift;
	$x =~ s/[aeiu]$//;
	$x;
}

sub CCVl_Cl {
	my $suffix = shift;
	my $x = shift;
	$x =~ s/(.)\1[eaui]([lmnr])$/$1$2$suffix/;
	$x;
}

sub syllcount {
	my $w = shift;
	my $syll = 0;
	while (length($w) > 0) {
		$w =~ s/^[^aeiouõäöü]+//;
		$w =~ s/^[aeiouõäöü]+//;
		$w =~ s/^[^aeiouõäöü]+//;

		$syll ++;
	}

	return $syll;
}

# vim: foldmethod=marker
