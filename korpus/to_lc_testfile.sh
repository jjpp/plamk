#!/bin/sh

# filter, mis teeb .kym-failist väiketähtedega testifaili:
# - unixi reavahed
# - lausemärgendus ära.
# - kirjavahemärgid ära.
# - täpitähed sgml-entity esitusest UTF8sse
# - esimene ja teine veerg väiketäheliseks
# - süntaksianalüüsist tulevad teadmised ära.
# - ainult unikaalsed sõna-analüüs variandid

tr -d '\r' | grep -v '</\?s>' | grep -v '</\?p>' | grep -v '//_Z_ ' | \
	sed -e 's/&auml;/ä/g' -e 's/&uuml;/ü/g' -e 's/&ouml;/ö/g' -e 's/&otilde;/õ/g' \
		-e 's/&Auml;/Ä/g' -e 's/&Uuml;/Ü/g' -e 's/&Ouml;/Ö/g' -e 's/&Otilde;/Õ/g' \
		-e 's/&scaron;/š/g' -e 's/&zcaron;/ž/g' -e 's/&Scaron;/Š/g' -e 's/&Zcaron;/Ž/g' | \
	awk '{ if (!ENV["CASESENSITIVE"]) { $1 = tolower($1); $2 = tolower($2); } print; }' | \
	sed -e 's/_V_ \(main\|aux\|mod\)/_V_/g' \
		-e 's/_A_ pos/_A_/g' \
		-e 's/_S_ com/_S_/g' \
		-e 's/_S_ prop/_H_/g' \
		-e 's/_K_ pre/_K_/' \
		-e 's/_K_ post/_K_/' \
		-e 's/_J_ sub/_J_/' \
		-e 's/_J_ crd/_J_/' \
		-e 's/_V_ quot pres ps \(neg\|af\) /_V_ quot pres ps /' \
		-e 's/_V_ imper pres ps2 sg ps \(neg\|af\) /_V_ imper pres ps2 sg /' \
		-e 's/_V_ partic past ps \(neg\|af\) /_V_ partic past ps /' \
		-e 's/_V_ cond pres imps \(neg\|af\) /_V_ cond pres imps /' \
	| sort | uniq -c
