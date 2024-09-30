%{
#include <stdlib.h>
#include <stdio.h>

#define END 0
#define NUM 1
#define PLUS 2
#define MINUS 3
%}

%option noyywrap

%%

[ \t]+
[0-9]+   { return NUM; }
"+"      { return PLUS; }
"-"      { return MINUS; }
"\n"     { return END; }

%%

int parse(void);

int main(int argc, char **argv)
{
  if (parse() == 1)
    printf("\nsyntax error\n");
  return 0;
}

int parse(void)
{
  if (yylex() != NUM)
    return 1;

  int accum = atoi(yytext); //store read values as number - yytext return a matched text from the input
  int parser = yylex();  // saves the first value to start parsing

  while (parser != END) {
    if (yylex() != NUM)
      return 1;

    int right_side=atoi(yytext);
    
    if (parser == PLUS)
      accum += right_side;
    else if (parser == MINUS)
      accum -= right_side;
    else
      return 1;

    parser = yylex();  //this with the while above parses all the inputs
  }
  printf("%d\n", accum);
  return 0;
}
