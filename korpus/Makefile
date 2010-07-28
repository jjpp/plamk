# korpusepõhiste testfailidega majandamine

VPATH=failid
vpath %.kym failid

all:	1984.check 1984.uwords full.check full.uwords

cs:	1984.cscheck 1984.csuwords full.cscheck full.csuwords

clean:
	rm -rf failid/ *.check *.uwords *.cscheck *.csuwords

failid.zip:
	wget http://www.cl.ut.ee/korpused/morfkorpus/failid.zip


full.check: failid/*.kym
	cat failid/*.kym | ./to_lc_testfile.sh > $@

full.uwords: failid/*.kym
	cat failid/*.kym | ./to_lc_words.sh > $@

full.cscheck: failid/*.kym
	cat failid/*.kym | CASESENSITIVE=1 ./to_lc_testfile.sh > $@

full.csuwords: failid/*.kym
	cat failid/*.kym | CASESENSITIVE=1 ./to_lc_words.sh > $@

%.check: %.kym
	cat $< | ./to_lc_testfile.sh > $@

%.uwords: %.kym
	cat $< | ./to_lc_words.sh > $@

%.cscheck: %.kym
	cat $< | CASESENSITIVE=1 ./to_lc_testfile.sh > $@

%.csuwords: %.kym
	cat $< | CASESENSITIVE=1 ./to_lc_words.sh > $@


failid/1984.kym: failid.zip
	unzip -n failid.zip; touch failid/*


