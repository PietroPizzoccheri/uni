%{  
int nest = 0;

    /*
    WHEN HAVING MULTIPLE SCANNERS EACH SCANNER HAS RULES MARKED WITH THEIR NAME,
    WHEN DECLARING A SCANNER LIKE BELOW %x MAKES THAT THE DECLARED SCANNER ONLY USES HIS RULES,
    %s MAKE THE DECLARED SCANNER ALSO USE OTHER RULES,
    <INITIAL> DOESN'T NEED TO BE DECLARED AND IS %s 
    */
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
    THIS IS THE SECOND SCANNER FOR COMMENTS THAT ALSO COUNTS NESTING
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
