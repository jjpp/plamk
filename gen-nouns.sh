#!/bin/sh

W=$1
XFST=/home/jjpp/dev/keel/xerox/bin/xfst
LOOKUP=/home/jjpp/dev/keel/xerox/bin/lookup
FST=${FST:-eesti.fst}

rm -f reverse-$FST

$XFST -e "load $FST" -e 'invert' -e "save reverse-$FST" -stop

(
for num in sg pl; do
	for cs in nom gen part ill in el all ad abl tr ter es ab kom adit; do
		echo "$W+$num+$cs"
	done
done) | $LOOKUP reverse-$FST 



