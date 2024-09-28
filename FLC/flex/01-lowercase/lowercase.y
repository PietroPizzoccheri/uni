%{
// COMPILE THIS FILE WITH flex -o name.c name.y and then gcc -o scanner name.c

#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
%}

%option noyywrap

UPPER [A-Z]

%%

{UPPER}   { putchar(tolower(yytext[0])); }

%%

int main(int argc, char *argv[])
{
  return yylex();
}
