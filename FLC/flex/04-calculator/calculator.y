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
    printf("syntax error\n");
  return 0;
}

int parse(void)
{
  if (yylex() != NUM)
    return 1;
  int accum = atoi(yytext);
  
  int op_input = yylex();
  while (op_input != END) {
    if (yylex() != NUM)
      return 1;
    int right_side=atoi(yytext);
    
    if (op_input == PLUS)
      accum += right_side;
    else if (op_input == MINUS)
      accum -= right_side;
    else
      return 1;
      
    op_input = yylex();
  }
  printf("%d\n", accum);
  return 0;
}
