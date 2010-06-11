XEROX=/home/jjpp/dev/keel/xerox/bin
XFST=$(XEROX)/xfst
LEXC=$(XEROX)/lexc
TWOLC=$(XEROX)/twolc
ICONV=iconv
ESTMORF=wine /home/jjpp/dev/keel/estmorf/x/ESTMORF.EXE

ETHTHORN=sed -e 's/š/ð/g' -e 's/Š/Ð/g' -e 's/ž/þ/g' -e 's/Ž/Þ/g' 
INVERSE_ETHTHORN=sed -e 's/ð/š/g' -e 's/Ð/Š/g' -e 's/þ/ž/g' -e 's/Þ/Ž/g' 

GENERATED_LEX=lex_subst.txt lex_adj.txt lex_name.txt lex_verb.txt lex_adv.txt \
	lex_inter.txt lex_conj.txt lex_pronom.txt lex_gen.txt lex_number.txt lex_ordinal.txt \
	lex_other.txt lex_prepost.txt lex_extra.txt
TESTFILE=1984_words_u.txt


all: eesti.fst

test: estmorf.out xfst.out $(TESTFILE)
	fgrep '???' xfst.out | wc -l
	fgrep '###' estmorf.out | wc -l
	wc -l $(TESTFILE)

clean:
	$(RM) eesti.fst lex.fst lex-av.fst rules.fst xfst.out estmorf.out rul-av.txt \
		rules-av.fst lex_full.txt $(GENERATED_LEX) lex_exc.txt lex_override_gen.txt \
		lex_exc.fst

eesti.fst: lex.fst rules.fst rules-av.fst lex_exc.fst deriv_filter.txt
	$(XFST) -e 'read regex  [@"rules-av.fst"].i .o. [@"lex.fst"];' \
		-e "save stack lex-av.fst" \
		-e "clear" \
		-e 'read regex @re"deriv_filter.txt" .o. [[@"lex_exc.fst"] .P. [@"lex-av.fst"]] .o. [@"rules.fst"];' \
		-e "save stack eesti.fst" -stop

#		-e 'read regex [[@"lex_exc.fst"] .P. [@"lex-av.fst"]] .o. [@"rules.fst"];' \


lex.fst: lex_full.txt
	$(XFST) -e "read lexc lex_full.txt" -e "save stack lex.fst" -stop

rules.fst: rul.txt
	echo -ne "read-grammar rul.txt\ncompile\nintersect\n\n\nsave-binary rules.fst\nquit\n"  | $(TWOLC)

lex_exc.fst: lex_exc.txt
	$(XFST) -e "read lexc lex_exc.txt" -e "save stack lex_exc.fst" -stop

rul-av.txt: rul.txt
	awk '/!!!! EOF AV/ { x = 1; } { if (!x) { print; } }' rul.txt | sed -e 's/%+:0/%+:%+/' > rul-av.txt

rules-av.fst: rul-av.txt
	echo -ne "read-grammar rul-av.txt\ncompile\nintersect\n\n\nsave-binary rules-av.fst\nquit\n"  | $(TWOLC)

lex_full.txt: lex_multichar.txt lex_main.txt lex_gi.txt $(GENERATED_LEX)
	cat $^ > $@

lex_exc.txt: lex_multichar.txt lex_override.txt lex_override_gen.txt lex_gi.txt
	cat $^ > $@

lex_adj.txt: tyvebaas.txt tyvebaas-lisa.txt eki2lex.pl
	cat tyvebaas.txt tyvebaas-lisa.txt | $(ICONV) -flatin1 -tutf8 | $(INVERSE_ETHTHORN) | ./eki2lex.pl

lex_subst.txt: lex_adj.txt
lex_name.txt: lex_adj.txt
lex_verb.txt: lex_adj.txt
lex_extra.txt: lex_override_gen.txt

lex_override_gen.txt: form.exc fcodes.ini exc2lex.pl
	cat form.exc | $(ICONV) -flatin1 -tutf8 | $(INVERSE_ETHTHORN) | ./exc2lex.pl

xfst.out: eesti.fst $(TESTFILE)
	$(XFST) -e "load eesti.fst" -e "apply up < $(TESTFILE)" -stop -q -pipe > xfst.out

estmorf.out: 1984_words_u.txt
	cat $(TESTFILE) | $(ETHTHORN) | $(ICONV) -futf8 -tlatin1 | $(ESTMORF) > estmorf.out

xfsti: eesti.fst
	$(XFST) -e "load eesti.fst"

