%{
#include <stdlib.h>
#include "infix-calc.tab.h"
%}
%option noyywrap

DIGITS        [0-9]
LETTERS       [a-zA-Z_]

%%

"+"                             { return PLUS; }
"-"                             { return MINUS; }
"*"                             { return MUL; }
"/"                             { return DIV; }
"("                             { return LPAR; }
")"                             { return RPAR; }
"="                             { return ASSIGN; }
"\n"                            { return NEWLINE; }
{DIGITS}+                       { yylval.value = atoi(yytext);
                                  return NUMBER; }
{LETTERS}({LETTERS}|{DIGITS})*  { yylval.id = strdup(yytext);
                                  return ID; }
[ \t\r]+
