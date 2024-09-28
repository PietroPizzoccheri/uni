%{
#include <stdlib.h>
#include "rpn-calc.tab.h"
%}
%option noyywrap

%%

"+"           { return PLUS; }
"-"           { return MINUS; }
"*"           { return MUL; }
"/"           { return DIV; }
"\n"          { return NEWLINE; }
[0-9]+        { yylval.value = atoi(yytext);
                return NUMBER; }
[ \t\r]+
