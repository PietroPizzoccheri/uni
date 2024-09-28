%{
#include <stdio.h>

int next_var_id = 1;
FILE *output;

int yylex(void);
void yyerror(const char *);
%}

%union {
  int value;
  int var_id;
}

%start program

%token <value> NUMBER
%token NEWLINE PLUS
%token MINUS MUL DIV
%type <var_id> exp

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
  | exp exp PLUS
  {
    $$ = next_var_id++;
    fprintf(output, "  int v%d = v%d + v%d;\n", $$, $1, $2);
  }
  | exp exp MINUS
  {
    $$ = next_var_id++;
    fprintf(output, "  int v%d = v%d - v%d;\n", $$, $1, $2);
  }
  | exp exp MUL
  {
    $$ = next_var_id++;
    fprintf(output, "  int v%d = v%d * v%d;\n", $$, $1, $2);
  }
  | exp exp DIV
  {
    $$ = next_var_id++;
    fprintf(output, "  int v%d = v%d / v%d;\n", $$, $1, $2);
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
