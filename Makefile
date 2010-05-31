XEROX=/home/jjpp/dev/keel/xerox/bin
XFST=$(XEROX)/xfst
LEXC=$(XEROX)/lexc
TWOLC=$(XEROX)/twolc


all: eesti.fst

clean:
	$(RM) eesti.fst lex.fst rules.fst

eesti.fst: lex.fst rules.fst
	$(XFST) -e "load stack rules.fst" -e "load stack lex.fst" -e "compose net" -e "save stack eesti.fst" -stop

lex.fst: lex2.txt
	$(XFST) -e "read lexc lex2.txt" -e "save stack lex.fst" -stop

rules.fst: rul.txt
	echo -ne "read-grammar rul.txt\ncompile\nintersect\n\n\nsave-binary rules.fst\nquit\n"  | $(TWOLC)


