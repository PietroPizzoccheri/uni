%{
#include <stdio.h>

int yylex(void);
void yyerror(const char *);
%}

%union {
  int value;
}

%start program

%token <value> NUMBER
%token NEWLINE PLUS MINUS
%token MUL DIV RPAR LPAR
%type <value> exp

%left PLUS MINUS
%left MUL DIV

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
  | exp PLUS exp
  {
    $$ = $1 + $3;
  }
  | exp MINUS exp
  {
    $$ = $1 - $3;
  }
  | exp MUL exp
  {
    $$ = $1 * $3;
  }
  | exp DIV exp
  {
    $$ = $1 / $3;
  }
  | LPAR exp RPAR
  {
    $$ = $2;
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
