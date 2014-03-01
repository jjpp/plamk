XEROX=~/xerox/bin
XFST=$(XEROX)/xfst
TWOLC=$(XEROX)/twolc
ICONV=iconv
# testimiseks
ESTMORF=wine ~/estmorf/ESTMORF.EXE
EKI_DATA=~/eki/data
EKI_ANA=wine ~/eki/demo_ana.exe

# latin1 to utf-8
TO_UTF8=$(ICONV) -f latin1 -t UTF-8
FROM_UTF8=$(ICONV) -f UTF-8 -t latin1

# estonians used modified latin1 where scaron & zcaron used to be 
# encoded as eth and thorn.
ETHTHORN=sed -e 's/š/ð/g' -e 's/Š/Ð/g' -e 's/ž/þ/g' -e 's/Ž/Þ/g' 
INVERSE_ETHTHORN=sed -e 's/ð/š/g' -e 's/Ð/Š/g' -e 's/þ/ž/g' -e 's/Þ/Ž/g' 

GENERATED_LEX=stems.lexc generated_extra.lexc 
TESTFILE=1984_words_u.txt

# vaikimisi ehitame vaid eesti keele morfoanalüsaatori FST
all: eesti.fst

# vahel on kasulik kõik genereeritud failid ära koristada
clean:
	$(RM) eesti.fst lexicon.fst lex-av.fst rules.fst xfst.out estmorf.out rules-av.twolc \
		rules-av.fst lexicon.lexc $(GENERATED_LEX) exceptions.lexc generated_overrides.lexc \
		exceptions.fst full-compound.fst lihtsonad.fst liitsonamask.fst arvud.fst \
		1984_words_u_l1.txt 1984_words_u_l1.out eki.out liitsonamask.lexc \
		estmorf_check.out reverse-eesti.fst reverse-lex-av.fst reverse-lihtsonad.fst \
		liitsonafilter.lexc liitsonafilter.fst

## peamine FST ehitamine
#eesti.fst: lexicon.fst rules.fst exceptions.fst deriv_filter.txt xfst.script liitsonamask.lexc \
#		liitsonafilter.lexc arvud.lexc
#	$(XFST) -f xfst.script 

%.fst: %.lexc
	$(XFST) -e 'read lexc $<' -e 'set quit-on-fail OFF' -e 'eliminate flag LEXNAME' -e 'save $@' < /dev/null

%.fst: %.twolc
	@printf "read-grammar $<\ncompile\nintersect\n\n\nsave-binary $@\nquit\n" | $(TWOLC) || \
		( $(TWOLC) -i $< -o $@ && $(XFST) -e 'load < $@' -e 'intersect' -e 'save $@' < /dev/null)

lex-av.fst: rules.fst lexicon.fst
	$(XFST) -e 'read regex  [@"rules.fst"].i .o. [@"lexicon.fst"]' -e 'save lex-av.fst' < /dev/null

lihtsonad.fst: deriv_filter.txt exceptions.fst lex-av.fst rules.fst arvud.fst
	$(XFST) -e 'read regex [ @re"deriv_filter.txt" .o. [[@"exceptions.fst"] .P. [@"lex-av.fst"]] .o. ~$$"#" .o.  @"rules.fst" ] | @"arvud.fst"' -e 'save lihtsonad.fst' < /dev/null

full-compound.fst: lihtsonad.fst
	$(XFST) -e 'read regex ("-" "&") [ @"lihtsonad.fst" "&" ("-" "&") ]* @"lihtsonad.fst" ("&" "-")' -e 'save full-compound.fst' < /dev/null

eesti.fst:	liitsonafilter.fst liitsonamask.fst full-compound.fst
	$(XFST) -e 'read regex 	@"liitsonafilter.fst" .o.  @"liitsonamask.fst" .o.  @"full-compound.fst" .o. [ "&" -> "" ]' -e 'save eesti.fst' < /dev/null



# Heli variandis oli ülemine reeglitekiht vaid astmevahelduse jaoks, praktikas sellest ei piisanud?
# rules-av.twolc on fail, kus on vaid rules.twolc algus kuni märgendini "!!!! EOF AV"
rules-av.twolc: rules.twolc
	awk '/!!!! EOF AV/ { x = 1; } { if (!x) { print; } }' rules.twolc  > rules-av.twolc
#	awk '/!!!! EOF AV/ { x = 1; } { if (!x) { print; } }' rules.twolc | sed -e 's/%+:0/%+:%+/' > rules-av.twolc

# põhisõnastiku lexc-lähtetekst pannakse tükkidest kokku, tükkide järjekord on oluline
lexicon.lexc: multichar.lexc main.lexc gi.lexc $(GENERATED_LEX)
	cat $^ > $@

# peamine tyvedesõnastik, genereeritakse peamiselt EKI tüvebaasist
stems.lexc: tyvebaas.txt tyvebaas-lisa.txt eki2lex.pl
	cat tyvebaas.txt tyvebaas-lisa.txt | ./eki2lex.pl

# eranditesõnastiku lexc-lähtetekst
exceptions.lexc: multichar.lexc overrides.lexc generated_overrides.lexc gi.lexc
	cat $^ > $@

# erandifailid. "tõelised" erandid ja paralleelvormid, genereeritakse
# pisut täiendatud EKI andmetest
generated_overrides.lexc generated_extra.lexc: form.exc fcodes.ini exc2lex.pl
	cat form.exc | $(TO_UTF8) | $(INVERSE_ETHTHORN) | ./exc2lex.pl

# liitsõna-regulaaravaldistega lexc-sõnastiku lähtetekst
liitsonamask.lexc: multichar.lexc compound_definitions.lexc compound_rules.lexc
	cat $^ > $@

# liitsõna-erandite jms regulaaravaldis lexc-sõnastikuna
liitsonafilter.lexc: multichar.lexc compound_definitions.lexc compound_filter.lexc
	cat $^ > $@

#
# testimisega seotud kraam
#

# peamine testiviis. alternatiivsete sisenditega testimiseks
# make TESTFILE=testifailinimi xfst.out
xfst.out: eesti.fst $(TESTFILE)
	$(XFST) -e "load eesti.fst" -e "apply up < $(TESTFILE)" -q -pipe > xfst.out < /dev/null

# võrdluseks estmorfi väljund
# TESTFILE on ka siin kasutatav
estmorf.out: $(TESTFILE)
	cat $^ | $(ETHTHORN) | $(FROM_UTF8) | $(ESTMORF) > $@

# "normeeritud" estmorfi väljund
estmorf_check.out: estmorf.out
	cat $^ | fromdos | $(TO_UTF8) | $(INVERSE_ETHTHORN) | ./tolkija.pl > $@

# testfail EKI jaoks
1984_words_u_l1.txt: $(TESTFILE)
	cat $(TESTFILE) | $(ETHTHORN) | $(FROM_UTF8) | todos > $@


eki.out: 1984_words_u_l1.txt
	export EST_MORPHO_DATA=$(EKI_DATA); $(EKI_ANA) 1984_words_u_l1.txt /v3 /s+ /t-
	cat 1984_words_u_l1.out | ./eki_out2out.pl > eki.out

# interaktiivne XFST -- ehitab valmis ja laeb vaikimisi ka kehtiva seisu FSTst
xfsti: eesti.fst
	$(XFST) -e "load eesti.fst"

tundmatud: xfst.out
	grep -FB1 ??? xfst.out | grep -vF ??? | grep -vFe -- | less

test: estmorf.out xfst.out eki.out $(TESTFILE)
	grep -F '???' xfst.out | wc -l
	grep -F '###' estmorf.out | wc -l
	grep -F '###' eki.out | wc -l
	wc -l $(TESTFILE)

testx: xfst.out
	grep -F '???' xfst.out | wc -l


######################################

apertium: apertium-fin-est.est-fin.LR.att.gz apertium-fin-est.est-fin.RL.att.gz

est.apertium.fst: eesti.fst
	hfst-invert eesti.fst -o eesti.mor.fst
	hfst-substitute -F apertium.relabel eesti.mor.fst -o $@

apertium-fin-est.est-fin.LR.att: est.apertium.fst
	hfst-fst2txt est.apertium.fst -o $@

apertium-fin-est.est-fin.RL.att: est.apertium.fst
	hfst-invert est.apertium.fst | hfst-fst2txt -o $@

%.att.gz: %.att
	gzip -9 -f --verbose $<
