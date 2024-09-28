%{
#include <stdlib.h>
#include "infix-compiler.tab.h"
%}
%option noyywrap

DIGITS        [0-9]
LETTERS       [a-zA-Z_]

%%

"+"                                  { return PLUS; }
"-"                                  { return MINUS; }
"*"                                  { return MUL; }
"/"                                  { return DIV; }
"("                                  { return LPAR; }
")"                                  { return RPAR; }
"["                                  { return LSQUARE; }
"]"                                  { return RSQUARE; }
"?"                                  { return INTERR; }
"\n"                                 { return NEWLINE; }
{DIGITS}+                            { yylval.value = atoi(yytext);
                                       return NUMBER; }
{LETTERS}({LETTERS}|{DIGITS}|" ")*   { yylval.string = strdup(yytext);
                                       return STRING; }
[ \t\r]+
