#!/bin/sh

W=$1
XFST=/home/jjpp/dev/keel/xerox/bin/xfst
LOOKUP=/home/jjpp/dev/keel/xerox/bin/lookup
FST=${FST:-eesti.fst}

[ -r $FST ] || make $FST

rm -f reverse-$FST
$XFST -e "load $FST" -e 'invert' -e "save reverse-$FST" -stop

(
for form in \
	"+V+sup+ill" "+V+sup+in" "+V+sup+el" "+V+sup+ab" "+V+sup+tr" "+V+sup+imps" \
	"+V+inf" "+V+ger" \
	"+V+partic+pres+ps" "+V+partic+pres+imps" "+V+partic+past+ps" "+V+partic+past+imps" \
	"+V+indic+pres+ps1+sg+ps+af" "+V+indic+pres+ps2+sg+ps+af" "+V+indic+pres+ps3+sg+ps+af" \
	"+V+indic+pres+ps1+pl+ps+af" "+V+indic+pres+ps2+pl+ps+af" "+V+indic+pres+ps3+pl+ps+af" \
	"+V+indic+pres+ps+neg" "+V+indic+pres+imps+af" "+V+indic+pres+imps+neg" \
	"+V+indic+impf+ps1+sg+ps+af" "+V+indic+impf+ps2+sg+ps+af" "+V+indic+impf+ps3+sg+ps+af" \
	"+V+indic+impf+ps1+pl+ps+af" "+V+indic+impf+ps2+pl+ps+af" "+V+indic+impf+ps3+pl+ps+af" \
	"+V+indic+impf+imps+af" \
	"+V+quot+pres+ps" "+V+quot+pres+imps" "+V+quot+past+imps" "+V+quot+partic+past+af" \
	"+V+cond+pres+ps1+sg+ps+af" "+V+cond+pres+ps2+sg+ps+af" "+V+cond+pres+ps3+sg+ps+af" \
	"+V+cond+pres+ps1+pl+ps+af" "+V+cond+pres+ps2+pl+ps+af" "+V+cond+pres+ps3+pl+ps+af" \
	"+V+cond+pres+imps" \
	"+V+cond+partic+past+ps1+sg+af" "+V+cond+partic+past+ps2+sg+af" "+V+cond+partic+past+ps3+sg+af" \
	"+V+cond+partic+past+ps1+pl+af" "+V+cond+partic+past+ps2+pl+af" "+V+cond+partic+past+ps3+pl+af" \
	"+V+cond+past+imps" \
	"+V+imper+pres+ps1+sg" "+V+imper+pres+ps2+sg" "+V+imper+pres+ps3+sg+ps+af" \
	"+V+imper+pres+ps1+pl+ps+af" "+V+imper+pres+ps2+pl+ps+af" "+V+imper+pres+ps3+pl+ps+af" \
	"+V+imper+pres+imps"; do
	echo "$W$form"
done) | $LOOKUP reverse-$FST | grep -v '^$' | awk '{printf "%-40s %s %s\n", $1, $2, $3}'





