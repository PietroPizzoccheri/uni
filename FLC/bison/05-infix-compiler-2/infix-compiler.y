%{
#include <stdio.h>

int next_var_id = 1;
FILE *output;

int yylex(void);
void yyerror(const char *);
%}

%union {
  int value;
  char *string;
}

%start program

%token <value> NUMBER
%token <string> STRING
%token PLUS MINUS MUL DIV
%token RPAR LPAR
%token LSQUARE RSQUARE
%token INTERR
%token NEWLINE

%type <value> exp

%left PLUS MINUS
%left MUL DIV


%%


program:
  {
    fprintf(output, "#include <stdio.h>\n\n");
    fprintf(output, "int main(int argc, char *argv[])\n");
    fprintf(output, "{\n");
  }
  lines NEWLINE
  {
    fprintf(output, "  printf(\"bye!\\n\");\n");
    fprintf(output, "  return 0;\n");
    fprintf(output, "}\n");
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
    fprintf(output, "  printf(\"result = %%d\\n\", v%d);\n\n", $1);
  }
;

exp:
  NUMBER
  {
    $$ = next_var_id++;
    fprintf(output, "  int v%d = %d;\n", $$, $1);
  }
  | exp PLUS exp
  {
    $$ = next_var_id++;
    fprintf(output, "  int v%d = v%d + v%d;\n", $$, $1, $3);
  }
  | exp MINUS exp
  {
    $$ = next_var_id++;
    fprintf(output, "  int v%d = v%d - v%d;\n", $$, $1, $3);
  }
  | exp MUL exp
  {
    $$ = next_var_id++;
    fprintf(output, "  int v%d = v%d * v%d;\n", $$, $1, $3);
  }
  | exp DIV exp
  {
    $$ = next_var_id++;
    fprintf(output, "  int v%d = v%d / v%d;\n", $$, $1, $3);
  }
  | LPAR exp RPAR
  {
    $$ = $2;
  }
  | LSQUARE INTERR STRING RSQUARE
  {
    $$ = next_var_id++;
    fprintf(output, "  int v%d;\n", $$);
    fprintf(output, "  printf(\"%%s? \", \"%s\");\n", $3);
    fprintf(output, "  scanf(\"%%d\", &v%d);\n", $$);
    free($3);
  }
;
  

%%


void yyerror(const char *msg)
{
  fprintf(stderr, "%s\n", msg);
}


int main(int argc, char *argv[])
{
  output = fopen("output.c", "w");
  yyparse();
  fclose(output);
  return 0;
}
