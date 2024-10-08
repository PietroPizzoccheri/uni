%{  
int nest = 0;
%}

%x COMMENT
%option noyywrap

%%

  /*
    FIRST SCANNER, it just rewrite the input but when it finds /* calls the second scanner and updates the integer nest
  */

<INITIAL>[^/]*      { ECHO; }
<INITIAL>"/"+[^*/]* { ECHO; }
<INITIAL>"/*"       {
                      nest++;
                      BEGIN(COMMENT);
                    }

  /*
    THIS IS THE SECOND SCANNER FOR COMMENTS
  */

<COMMENT>[^/*]*
<COMMENT>"/"+[^*/]*
<COMMENT>"/*"       {
                      nest++;
                    }


<COMMENT>"*"+[^*/]*
<COMMENT>"*"+"/"    { 
                      nest--;
                      if (nest == 0)
                        BEGIN(INITIAL);
                    }

%%

int main(int argc , char* argv[])
{
  return yylex();
}
