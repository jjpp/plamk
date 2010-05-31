#!/usr/bin/perl

%g = ();

$root = undef;
$lex = undef;

while (<>) {
	s/\!.*$//;
	chomp();

	if (/^LEXICON\s+(\S+)\b/) {
		$root = $1 unless defined($root);
		$lex = $1;
		if (!exists $g{$lex}) {
			$g{$lex} = {};
		}
		next;
	}

	next unless defined $lex;

	for (split(';')) {
		next unless /\s*(\S*|\S+\s*:\s*\S+)\s+(\S+)\b/;
#		print "$lex: $_\n";
		$g{$lex} -> {$2} = 1;
	}
}

print "digraph G {\n";

for $n (sort keys %g) {
	for $t (sort keys %{$g{$n}}) {
		print "\"$n\" -> \"$t\";\n";
	}
}

print "}\n";
