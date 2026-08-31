all: exec

exec: lex.yy.cc
	g++ ./Example/parsers/lex.yy.cc -o exec

lex.yy.cc: scannerlexico.l
	flex -+ ./Example/parsers/scannerlexico.l

clean:
	rm -f ./Example/parsers/lex.yy.cc ./Example/parsers/exec