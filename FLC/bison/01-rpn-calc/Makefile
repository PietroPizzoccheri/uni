LEX_SRC = rpn-calc.l
YACC_SRC = rpn-calc.y
C_SRC = lex.yy.c $(patsubst %.y, %.tab.c, $(YACC_SRC))
EXEC_NAME = rpn-calc

all: $(EXEC_NAME)

$(EXEC_NAME): $(C_SRC)
	cc -o $@ $^

%.tab.c: %.y
	bison -d $<

%.tab.h: %.tab.c

lex.yy.c: $(LEX_SRC)
	flex $<

clean:
	rm -rf *.c *.o *.h $(EXEC_NAME)
