%{
#include <stdlib.h>
#include "infix-compiler.tab.h"
%}
%option noyywrap

%%

"+"           { return PLUS; }
"-"           { return MINUS; }
"*"           { return MUL; }
"/"           { return DIV; }
"("           { return LPAR; }
")"           { return RPAR; }
"\n"          { return NEWLINE; }
[0-9]+        { yylval.value = atoi(yytext);
                return NUMBER; }
[ \t\r]+
