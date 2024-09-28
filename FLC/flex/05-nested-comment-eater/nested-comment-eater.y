%{  
int nest = 0;
%}

%x COMMENT
%option noyywrap

%%

<INITIAL>[^/]*      { ECHO; }
<INITIAL>"/"+[^*/]* { ECHO; }
<INITIAL>"/*"       {
                      nest++;
                      BEGIN(COMMENT);
                    }
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
