CXX   = g++-8
EXE = iplC
CXXDEBUG = -g -Wall
CXXSTD = -std=c++11


.PHONY: all
all: parser lexer 	
	$(CXX) $(CXXSTD) $(CXXDEBUG) -o $(EXE) driver.cpp parser.o scanner.o ast.cc ast.hh
.PHONY : parser
parser: parser.yy scanner.hh ast.hh ast.cc
	bison -d -v $<
	$(CXX) $(CXXSTD) $(CXXDEBUG) -c parser.tab.cc -o parser.o 
.PHONY: lexer
lexer: scanner.l scanner.hh parser.tab.hh parser.tab.cc	ast.hh ast.cc
	flex++ --outfile=scanner.yy.cc  $<
	$(CXX) $(CXXSTD) $(CXXDEBUG) -c scanner.yy.cc -o scanner.o
.PHONY:clean
clean:
	rm  -f ${EXE} parser.tab.cc parser.output parser.o scanner.o scanner.yy.cc parser.tab.hh position.hh location.hh stack.hh
