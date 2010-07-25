XEROX=/home/jjpp/dev/keel/xerox/bin
XFST=$(XEROX)/xfst
LEXC=$(XEROX)/lexc
TWOLC=$(XEROX)/twolc
ICONV=iconv
ESTMORF=wine /home/jjpp/dev/keel/estmorf/x/ESTMORF.EXE
EKI_DATA=/home/jjpp/dev/keel/eki_bin/data
EKI_ANA=wine /home/jjpp/dev/keel/eki_bin/demo_ana.exe

ETHTHORN=sed -e 's/š/ð/g' -e 's/Š/Ð/g' -e 's/ž/þ/g' -e 's/Ž/Þ/g' 
INVERSE_ETHTHORN=sed -e 's/ð/š/g' -e 's/Ð/Š/g' -e 's/þ/ž/g' -e 's/Þ/Ž/g' 

GENERATED_LEX=lex_tyved.txt lex_extra.txt 
TESTFILE=1984_words_u.txt


all: eesti.fst

test: estmorf.out xfst.out eki.out $(TESTFILE)
	fgrep '???' xfst.out | wc -l
	fgrep '###' estmorf.out | wc -l
	fgrep '###' eki.out | wc -l
	wc -l $(TESTFILE)

testx: xfst.out
	fgrep '???' xfst.out | wc -l

clean:
	$(RM) eesti.fst lex.fst lex-av.fst rules.fst xfst.out estmorf.out rul-av.txt \
		rules-av.fst lex_full.txt $(GENERATED_LEX) lex_exc.txt lex_override_gen.txt \
		lex_exc.fst full-compound.fst lihtsonad.fst liitsonamask.fst arvud.fst \
		1984_words_u_l1.txt 1984_words_u_l1.out eki.out liitsona_full.txt

eesti.fst: lex.fst rules.fst rules-av.fst lex_exc.fst deriv_filter.txt xfst.script liitsona_full.txt arvud.txt
	$(XFST) -f xfst.script 

#		-e 'read regex [[@"lex_exc.fst"] .P. [@"lex-av.fst"]] .o. [@"rules.fst"];' \


lex.fst: lex_full.txt
	$(XFST) -e "read lexc lex_full.txt" -e "save stack lex.fst" -stop

rules.fst: rul.txt
	echo -ne "read-grammar rul.txt\ncompile\nintersect\n\n\nsave-binary rules.fst\nquit\n"  | $(TWOLC)

lex_exc.fst: lex_exc.txt
	$(XFST) -e "read lexc lex_exc.txt" -e "save stack lex_exc.fst" -stop

rul-av.txt: rul.txt
	awk '/!!!! EOF AV/ { x = 1; } { if (!x) { print; } }' rul.txt  > rul-av.txt
#	awk '/!!!! EOF AV/ { x = 1; } { if (!x) { print; } }' rul.txt | sed -e 's/%+:0/%+:%+/' > rul-av.txt

rules-av.fst: rul-av.txt
	echo -ne "read-grammar rul-av.txt\ncompile\nintersect\n\n\nsave-binary rules-av.fst\nquit\n"  | $(TWOLC)

lex_full.txt: lex_multichar.txt lex_main.txt lex_gi.txt $(GENERATED_LEX)
	cat $^ > $@

lex_exc.txt: lex_multichar.txt lex_override.txt lex_override_gen.txt lex_gi.txt
	cat $^ > $@

lex_tyved.txt: tyvebaas.txt tyvebaas-lisa.txt eki2lex.pl
	cat tyvebaas.txt tyvebaas-lisa.txt | $(ICONV) -flatin1 -tutf8 | $(INVERSE_ETHTHORN) | ./eki2lex.pl

lex_extra.txt: lex_override_gen.txt

lex_override_gen.txt: form.exc fcodes.ini exc2lex.pl
	cat form.exc | $(ICONV) -flatin1 -tutf8 | $(INVERSE_ETHTHORN) | ./exc2lex.pl

liitsona_full.txt: lex_multichar.txt liitsona.txt
	cat $^ > $@

1984_words_u_l1.txt: $(TESTFILE)
	cat $(TESTFILE) | $(ETHTHORN) | $(ICONV) -futf8 -tlatin1 | todos > $@

xfst.out: eesti.fst $(TESTFILE)
	$(XFST) -e "load eesti.fst" -e "apply up < $(TESTFILE)" -stop -q -pipe > xfst.out

estmorf.out: 1984_words_u.txt
	cat $(TESTFILE) | $(ETHTHORN) | $(ICONV) -futf8 -tlatin1 | $(ESTMORF) > estmorf.out

eki.out: 1984_words_u_l1.txt
	export EST_MORPHO_DATA=$(EKI_DATA); $(EKI_ANA) 1984_words_u_l1.txt /v3 /s+ /t-
	cat 1984_words_u_l1.out | ./eki_out2out.pl > eki.out
	

xfsti: eesti.fst
	$(XFST) -e "load eesti.fst"

