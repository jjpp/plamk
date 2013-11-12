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

GENERATED_LEX=lex_tyved.txt lex_extra.txt 
TESTFILE=1984_words_u.txt

# vaikimisi ehitame vaid eesti keele morfoanalüsaatori FST
all: eesti.fst

# vahel on kasulik kõik genereeritud failid ära koristada
clean:
	$(RM) eesti.fst lex.fst lex-av.fst rules.fst xfst.out estmorf.out rul-av.txt \
		rules-av.fst lex_full.txt $(GENERATED_LEX) lex_exc.txt lex_override_gen.txt \
		lex_exc.fst full-compound.fst lihtsonad.fst liitsonamask.fst arvud.fst \
		1984_words_u_l1.txt 1984_words_u_l1.out eki.out liitsona_full.txt \
		estmorf_check.out reverse-eesti.fst reverse-lex-av.fst reverse-lihtsonad.fst \
		liitsona_filter_full.txt liitsonafilter.fst

## peamine FST ehitamine
#eesti.fst: lex.fst rules.fst lex_exc.fst deriv_filter.txt xfst.script liitsona_full.txt \
#		liitsona_filter_full.txt arvud.txt
#	$(XFST) -f xfst.script 

lex-av.fst: rules.fst lex.fst
	$(XFST) -e 'read regex  [@"rules.fst"].i .o. [@"lex.fst"]' -e 'save lex-av.fst' < /dev/null

arvud.fst: arvud.txt
	$(XFST) -e 'read lexc arvud.txt' -e 'eliminate flag LEXNAME' -e 'save arvud.fst' < /dev/null

lihtsonad.fst: deriv_filter.txt lex_exc.fst lex-av.fst rules.fst arvud.fst
	$(XFST) -e 'read regex [ @re"deriv_filter.txt" .o. [[@"lex_exc.fst"] .P. [@"lex-av.fst"]] .o. ~$$"#" .o.  @"rules.fst" ] | @"arvud.fst"' -e 'save lihtsonad.fst' < /dev/null

liitsonamask.fst:	liitsona_full.txt
	$(XFST) -e 'read lexc liitsona_full.txt' -e 'eliminate flag LEXNAME' -e 'save liitsonamask.fst' < /dev/null


liitsonafilter.fst:	liitsona_filter_full.txt
	$(XFST) -e 'read lexc liitsona_filter_full.txt' -e 'eliminate flag LEXNAME' -e 'save liitsonafilter.fst' < /dev/null

full-compound.fst: lihtsonad.fst
	$(XFST) -e 'read regex ("-" "&") [ @"lihtsonad.fst" "&" ("-" "&") ]* @"lihtsonad.fst" ("&" "-")' -e 'save full-compound.fst' < /dev/null

eesti.fst:	liitsonafilter.fst liitsonamask.fst full-compound.fst
	$(XFST) -e 'read regex 	@"liitsonafilter.fst" .o.  @"liitsonamask.fst" .o.  @"full-compound.fst" .o. [ "&" -> "" ]' -e 'save eesti.fst' < /dev/null


# kahetasemelised reeglid
rules.fst: rul.txt
	@printf "read-grammar rul.txt\ncompile\nintersect\n\n\nsave-binary rules.fst\nquit\n" | $(TWOLC) || \
		( $(TWOLC) -i rul.txt -o rules.fst && $(XFST) -e 'load < rules.fst' -e 'intersect' -e 'save rules.fst' < /dev/null)


# Heli variandis oli ülemine reeglitekiht vaid astmevahelduse jaoks, praktikas sellest ei piisanud?
# rul-av.txt on fail, kus on vaid rul.txt algus kuni märgendini "!!!! EOF AV"
rul-av.txt: rul.txt
	awk '/!!!! EOF AV/ { x = 1; } { if (!x) { print; } }' rul.txt  > rul-av.txt
#	awk '/!!!! EOF AV/ { x = 1; } { if (!x) { print; } }' rul.txt | sed -e 's/%+:0/%+:%+/' > rul-av.txt

# av-reeglid FSTks kompileerituna
rules-av.fst: rul-av.txt
	@printf "read-grammar rul-av.txt\ncompile\nintersect\n\n\nsave-binary rules-av.fst\nquit\n" | $(TWOLC) || $(TWOLC) -i rul-av.txt -o rules-av.fst

# põhisõnastik
lex.fst: lex_full.txt
	$(XFST) -e "read lexc lex_full.txt" -e 'eliminate flag LEXNAME' -e "save stack lex.fst" < /dev/null

# põhisõnastiku lexc-lähtetekst pannakse tükkidest kokku, tükkide järjekord on oluline
lex_full.txt: lex_multichar.txt lex_main.txt lex_gi.txt $(GENERATED_LEX)
	cat $^ > $@

# peamine tyvedesõnastik, genereeritakse peamiselt EKI tüvebaasist
lex_tyved.txt: tyvebaas.txt tyvebaas-lisa.txt eki2lex.pl
	cat tyvebaas.txt tyvebaas-lisa.txt | ./eki2lex.pl

# eranditesõnastik
lex_exc.fst: lex_exc.txt
	$(XFST) -e "read lexc lex_exc.txt" -e 'eliminate flag LEXNAME' -e "save stack lex_exc.fst" < /dev/null

# eranditesõnastiku lexc-lähtetekst
lex_exc.txt: lex_multichar.txt lex_override.txt lex_override_gen.txt lex_gi.txt
	cat $^ > $@

# erandifailid. "tõelised" erandid ja paralleelvormid, genereeritakse
# pisut täiendatud EKI andmetest
lex_override_gen.txt lex_extra.txt: form.exc fcodes.ini exc2lex.pl
	cat form.exc | $(TO_UTF8) | $(INVERSE_ETHTHORN) | ./exc2lex.pl

# liitsõna-regulaaravaldistega lexc-sõnastiku lähtetekst
liitsona_full.txt: lex_multichar.txt liitsona_def.txt liitsona.txt
	cat $^ > $@

# liitsõna-erandite jms regulaaravaldis lexc-sõnastikuna
liitsona_filter_full.txt: lex_multichar.txt liitsona_def.txt liitsona_filter.txt
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


