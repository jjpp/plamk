XEROX=/home/jjpp/dev/keel/xerox/bin
XFST=$(XEROX)/xfst
LEXC=$(XEROX)/lexc
TWOLC=$(XEROX)/twolc
ICONV=iconv
ESTMORF=wine /home/jjpp/dev/keel/estmorf/x/ESTMORF.EXE

ETHTHORN=sed -e 's/š/ð/g' -e 's/Š/Ð/g' -e 's/ž/þ/g' -e 's/Ž/Þ/g' 
INVERSE_ETHTHORN=sed -e 's/ð/š/g' -e 's/Ð/Š/g' -e 's/þ/ž/g' -e 's/Þ/Ž/g' 

GENERATED_LEX=lex_subst.txt lex_adj.txt lex_name.txt lex_verb.txt lex_adv.txt
TESTFILE=1984_words_u.txt


all: eesti.fst

test: estmorf.out xfst.out $(TESTFILE)
	fgrep '???' xfst.out | wc -l
	fgrep '###' estmorf.out | wc -l
	wc -l $(TESTFILE)

clean:
	$(RM) eesti.fst lex.fst lex-av.fst rules.fst xfst.out estmorf.out rul-av.txt \
		rules-av.fst lex_full.txt $(GENERATED_LEX)

eesti.fst: lex.fst rules.fst rules-av.fst
	$(XFST) -e "load rules-av.fst" -e "load lex.fst" -e "invert" -e "compose" \
		-e "invert" -e "save stack lex-av.fst" \
		-e "load rules.fst" -e "turn" -e "compose" \
		-e "save stack eesti.fst" -stop
#	$(XFST) -e "load rules.fst" -e "load lex.fst" -e "compose net" -e "save stack eesti.fst" -stop

lex.fst: lex_full.txt
	$(XFST) -e "read lexc lex_full.txt" -e "save stack lex.fst" -stop

rules.fst: rul.txt
	echo -ne "read-grammar rul.txt\ncompile\nintersect\n\n\nsave-binary rules.fst\nquit\n"  | $(TWOLC)

rul-av.txt: rul.txt
	awk '/!!!! EOF AV/ { x = 1; } { if (!x) { print; } }' rul.txt | sed -e 's/%+:0/%+:%+/' > rul-av.txt

rules-av.fst: rul-av.txt
	echo -ne "read-grammar rul-av.txt\ncompile\nintersect\n\n\nsave-binary rules-av.fst\nquit\n"  | $(TWOLC)

lex_full.txt: lex_main.txt $(GENERATED_LEX)
	cat $^ > $@

lex_adj.txt: tyvebaas.txt tyvebaas-lisa.txt eki2lex.pl
	cat tyvebaas.txt tyvebaas-lisa.txt | $(ICONV) -flatin1 -tutf8 | $(INVERSE_ETHTHORN) | ./eki2lex.pl

lex_subst.txt: lex_adj.txt
lex_name.txt: lex_adj.txt
lex_verb.txt: lex_adj.txt

xfst.out: eesti.fst $(TESTFILE)
	$(XFST) -e "load eesti.fst" -e "apply up < $(TESTFILE)" -stop -q -pipe > xfst.out

estmorf.out: 1984_words_u.txt
	cat $(TESTFILE) | $(ETHTHORN) | $(ICONV) -futf8 -tlatin1 | $(ESTMORF) > estmorf.out

xfsti: eesti.fst
	$(XFST) -e "load eesti.fst"

