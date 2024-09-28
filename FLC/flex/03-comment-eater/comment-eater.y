%x COMMENT
%option noyywrap

%%

"/*"                { BEGIN(COMMENT); }
<COMMENT>[^*]*      // eat all characters except "*"
<COMMENT>"*"+[^*/]* // eat single "*" not followed by "/"
<COMMENT>"*"+"/"    { BEGIN(INITIAL); }

%%

int main(int argc , char* argv[])
{
  return yylex();
}
