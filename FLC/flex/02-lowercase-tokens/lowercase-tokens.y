%{
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

#define UPPER 1
#define LOWER 2
%}

%option noyywrap

%%

[A-Z]  { return UPPER; }
.      { return LOWER; }

%%>

int main(int argc, char **argv)
{
  int tok = yylex();
  while (tok) {
    if (tok == UPPER)
      printf("%c", tolower(yytext[0]));
    else
      printf("%s", yytext);
    tok = yylex();
  }
}
