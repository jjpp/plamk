XEROX=/home/jjpp/dev/keel/xerox/bin
XFST=$(XEROX)/xfst
LEXC=$(XEROX)/lexc
TWOLC=$(XEROX)/twolc


all: eesti.fst

eesti.fst: lex.fst rules.fst
	echo -ne "load stack lex.fst\nload stack rules.fst\ncompose net\nsave stack eesti.fst\n" | $(XFST)

lex.fst: lex2.txt
	echo -ne "read lexc lex2.txt\nsave stack lex.fst\n" | $(XFST)

rules.fst: rul.txt
	echo -ne "read-grammar rul.txt\ncompile\nintersect\n\n\nsave-binary rules.fst\nquit\n"  | $(TWOLC)


