#!/bin/sh

W=$1
XFST=~/xerox/bin/xfst
LOOKUP=~/xerox/bin/lookup
FST=${FST:-eesti.fst}

rm -f reverse-$FST

[ -r $FST ] || make $FST

$XFST -e "load $FST" -e 'invert' -e "save reverse-$FST" -stop

(
for num in sg pl; do
	for cs in nom gen part ill in el all ad abl tr term es abes kom; do
		echo "$W+$num+$cs"
	done
done

echo "$W+prefix"
echo "$W+sg+adit"

) | $LOOKUP reverse-$FST | grep -v '^$' | awk '{printf "%-40s %s %s\n", $1, $2, $3}'



