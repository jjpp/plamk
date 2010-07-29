#!/bin/sh

# filter, mis teeb .kym-failist väiketähtedega testifaili:
# - unixi reavahed
# - lausemärgendus ära.
# - kirjavahemärgid ära.
# - täpitähed sgml-entity esitusest UTF8sse
# - esimene ja teine veerg väiketäheliseks
# - ainult unikaalsed sõna-analüüs variandid

tr -d '\r' | grep -v '</\?s>' | grep -v '</\?p>' | grep -v '//_Z_ ' | \
	sed -e 's/&auml;/ä/g' -e 's/&uuml;/ü/g' -e 's/&ouml;/ö/g' -e 's/&otilde;/õ/g' \
		-e 's/&Auml;/Ä/g' -e 's/&Uuml;/Ü/g' -e 's/&Ouml;/Ö/g' -e 's/&Otilde;/Õ/g' \
		-e 's/&scaron;/š/g' -e 's/&zcaron;/ž/g' -e 's/&Scaron;/Š/g' -e 's/&Zcaron;/Ž/g' | \
	awk '{ if (!ENVIRON["CASESENSITIVE"]) { $1 = tolower($1); } print $1; }' | \
	${SORTER:-sort -u}
