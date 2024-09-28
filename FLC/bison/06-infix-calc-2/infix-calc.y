%{
#include <stdio.h>
#include <strings.h>

typedef struct var_record_t {
  char *name;
  int value;
  struct var_record_t *next;
} var_record_t;

var_record_t *variable_list = NULL;

var_record_t *search_variable(char *);
var_record_t *search_or_create_variable(char *);

int yylex(void);
void yyerror(const char *);
%}

%union {
  int value;
  char *id;
}

%start program

%token <value> NUMBER
%token <id> ID
%token NEWLINE PLUS MINUS
%token MUL DIV RPAR LPAR
%token ASSIGN

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
  | ID ASSIGN exp NEWLINE
  {
    var_record_t *var = search_or_create_variable($1);
    var->value = $3;
    printf("%s = %d\n", $1, $3);
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
  | ID
  {
    var_record_t *var = search_variable($1);
    if (var == NULL) {
      fprintf(stderr, "identifier \"%s\" not yet used", $1);
      YYERROR;
    }
    $$ = var->value;
  }
;
  

%%


var_record_t *search_variable(char *name)
{
  var_record_t *this = variable_list;
  while (this) {
    if (strcmp(this->name, name) == 0)
      return this;
    this = this->next;
  }
  return NULL;
}


var_record_t *search_or_create_variable(char *name)
{
  var_record_t *existing = search_variable(name);
  if (existing)
    return existing;
  var_record_t *new = malloc(sizeof(var_record_t));
  new->name = strdup(name);
  new->value = 0;
  new->next = variable_list;
  variable_list = new;
  return new;
}


void free_variables(void)
{
  var_record_t *this = variable_list;
  while (this) {
    var_record_t *next = this->next;
    free(this->name);
    free(this);
    this = next;
  }
  variable_list = NULL;
}


void yyerror(const char *msg)
{
  fprintf(stderr, "%s\n", msg);
}


int main(int argc, char *argv[])
{
  yyparse();
  free_variables();
  return 0;
}
