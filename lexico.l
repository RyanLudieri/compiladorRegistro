%{
    #include "sintatico.h"
    int yyerror(char *);
    int numLinha = 1;
    char atomo[100];
%}

identificador [a-zA-Z]([a-zA-Z0-9])*
numero       [0-9]+
espaco       [ \t\r]+
novalinha    [\n]

%x coment

%%
programa          return T_PROGRAMA;
inicio            return T_INICIO;
fimprograma       return T_FIM;
leia              return T_LEIA;
escreva           return T_ESCREVA;
se                return T_SE;
entao             return T_ENTAO;
senao             return T_SENAO;
fimse             return T_FIMSE;
enquanto          return T_ENQUANTO;
faca              return T_FACA;
fimenquanto       return T_FIMENQTO; 
def               return T_DEF;
fimdef            return T_FIMDEF;  
"+"               return T_MAIS;
"-"               return T_MENOS;
"*"               return T_VEZES;
div               return T_DIV;
">"               return T_MAIOR;
"<"               return T_MENOR;
"="               return T_IGUAL;
e                 return T_E;
ou                return T_OU;
nao               return T_NAO;
"<-"              return T_ATRIB;
"("               return T_ABRE;
")"               return T_FECHA;
inteiro           return T_INTEIRO;
logico            return T_LOGICO;
registro          return T_REGISTRO;
V                 return T_V;
F                 return T_F;


"//".*            /*nada*/
"/*"              BEGIN(coment);
<coment>"*/"      BEGIN(INITIAL);
<coment>.         /*nada*/
<coment>\n        numLinha++;

{identificador}      { strcpy(atomo, yytext); return T_IDENTIF; }
{identificador}"."   { 
                        strcpy(atomo, yytext);
                        atomo[strlen(atomo)-1] = 0; //Para apagar o ponto 
                        return T_IDPONTO; 
                     }
{numero}             { strcpy(atomo, yytext); return T_NUMERO; }
{espaco}             /* nada */
{novalinha}          numLinha++;
.                 yyerror("lexico!");

%%
int yywrap(void) {return 1; }

int yyerror(char *s){
    printf("Erro na linha %d: %s\n", numLinha, s);
    exit(100);
}

