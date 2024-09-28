%{
#include <stdio.h>

int yylex(void);
void yyerror(const char *);
%}

%union {
  int value;
}

%token <value> NUMBER
%token NEWLINE PLUS
%token MINUS MUL DIV
%type <value> exp

%%

program:
  lines NEWLINE
  {
    printf("bye!\n");
    YYACCEPT;
  }
;

lines:
  lines line
  | %empty
  ;
        
line: 
  exp NEWLINE
  {
    printf("result = %d\n", $1);
  }
;

exp:
  NUMBER
  {
    $$ = $1;
  }
  | exp exp PLUS
  {
    $$ = $1 + $2;
  }
  | exp exp MINUS
  {
    $$ = $1 - $2;
  }
  | exp exp MUL
  {
    $$ = $1 * $2;
  }
  | exp exp DIV
  {
    $$ = $1 / $2;
  }
;
  
%%

void yyerror(const char *msg)
{
  fprintf(stderr, "%s\n", msg);
}


int main(int argc, char *argv[])
{
  yyparse();
  return 0;
}
