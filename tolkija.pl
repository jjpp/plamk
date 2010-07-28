#!/usr/bin/perl

open(TABLE, "< morftrtabel.txt") or die "$!\n";
while (<TABLE>) {
	chomp;
	@r = split(/@/);
	push (@tabel, [@r]);
}
close(TABLE);

$lipp = 0;

while (<>) {
	chomp;
	if (/^[^ ]+/) {
		print "$_\n";
		next;
	}

	$tolgendus = $_;

	if ($tolgendus =~ m{(.*)\s+//(_._) (.*)//}) {
		$root = $1;
		$pos = $2;
		@inf = split(/,/, $3);

		foreach $m (@inf) {
			$m =~ s/\s+/ /g;
			$m =~ s/^\s+//g;
			next if ($m eq '');

			$morf = $pos . " " . $m;
			$morf =~ s/\s+$//;
			$lipp = 0;

			foreach $rida (@tabel) {
				if ($morf eq $rida->[1]) {
					print $root . " //" . $rida -> [3] . " //\n";
					$lipp++;
				}
			}

			if (!$lipp) {
				print $root . " //" . $morf . " //\n";
				$lipp = 0;
			}
		}

		if ($3 =~ /^\s*$/) {
			$morf = $pos;  
			foreach $rida (@tabel) {
				if ($morf =~ /$rida->[1]/) {
					print $root . " //" . $rida -> [3] . " //\n";
				}
			}
		}
		#	$tolgendus="    ".$root." //".$morf." //";
	} else {
		print "$tolgendus\n";
	}
}
