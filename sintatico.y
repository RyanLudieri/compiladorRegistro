%{

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #include "lexico.c"
    #include "utils.c"
    int contaVar = 0;
    int rotulo = 0;
    int ehRegistro = 0;
    int tipo;
    int tam; // tamanho da estrutura qdo percorre expressão de acesso
    int des = 0; // deslocamento para chegar no campo
    int pos; // posicao do tipo na tabela de simbolos
    int indice;
    ptno campos = NULL;
%}

%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_IDENTIF
%token T_LEIA
%token T_ESCREVA
%token T_ENQUANTO
%token T_FACA
%token T_FIMENQTO
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ATRIB
%token T_VEZES
%token T_DIV
%token T_MAIS
%token T_MENOS
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_V
%token T_F
%token T_NUMERO
%token T_NAO
%token T_ABRE
%token T_FECHA
%token T_LOGICO
%token T_INTEIRO
%token T_DEF 
%token T_FIMDEF
%token T_REGISTRO
%token T_IDPONTO

%start programa

%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

%%

programa
    : cabecalho definicao_registro variaveis 
        {
            mostraTab();
            empilha(contaVar);
            if(contaVar != 0)
                fprintf(yyout, "\tAMEM\t%d\n", contaVar);    
        }
    T_INICIO lista_comandos T_FIM
        {
            int conta = desempilha();
            if(conta)
                fprintf(yyout, "\tDMEN\t%d\n", conta);
        }
        {fprintf(yyout, "\tFIMP\n");}
    ;

cabecalho
    : T_PROGRAMA T_IDENTIF
        {
            fprintf(yyout, "\tINPP\n");

            strcpy(elemTab.id, "inteiro"); // Copia o conteudo de uma string para outra
            elemTab.tip = INT; 
            elemTab.end = -1;
            elemTab.tam = 1;
            elemTab.pos = pos;
            //elemTab.campo = campos;
            insereSimbolo(elemTab); // Insere símbolo na tabela de símbolos
            pos++;

            strcpy(elemTab.id, "logico"); // Copia o conteudo de uma string para outra
            elemTab.tip = LOG; 
            elemTab.end = -1;
            elemTab.tam = 1;
            elemTab.pos = pos;
            //elemTab.campo = campos;
            insereSimbolo(elemTab); // Insere símbolo na tabela de símbolos
            pos++;
        }
    ;

tipo
    : T_LOGICO
        {
            tipo = LOG;
            tam = 1;
            pos = buscaSimbolo("logico");
            //elemTab.campo = NULL;
            
        }
    |T_INTEIRO
        {
            tipo = INT;
            tam = 1;
            pos = buscaSimbolo("inteiro");
            //elemTab.campo = NULL;
            
        }
    |T_REGISTRO T_IDENTIF
        {
            tipo = REG;
            pos = buscaSimbolo(atomo);
            tam = tabSimb[pos].tam;
            elemTab.campo = tabSimb[pos].campo;
            campos = NULL;
        }
    ;

definicao_registro
    : /*vazio*/
    | define definicao_registro
    ;

define
    : T_DEF
          {
            elemTab.campo = campos;
          }
     definicao_campos T_FIMDEF T_IDENTIF
         {
            //pos = 2;

            strcpy(elemTab.id, atomo); // Copia o conteudo de uma string para outra
            elemTab.tip = REG; 
            elemTab.end = -1;

            // Aqui ficava o problema do tamanho
            elemTab.tam = tabSimb[pos].tam;
            elemTab.tam = elemTab.tam + campos->tam;
            elemTab.pos++; // + tam
            //elemTab.campo = insereCampo(campos,atomo,tipo,pos,des,tam);
            elemTab.campo = campos;
            insereSimbolo(elemTab); // Insere símbolo na tabela de símbolos
            //pos++;
            
         }
    ;

definicao_campos
    : tipo lista_campos definicao_campos
        {
            des = 0; // Passo importante para resetar o deslocamento
                     //de um registro para outro 
        }
    | tipo lista_campos
        {
            des = 0;    // Passo importante para resetar o deslocamento
                        //de um registro para outro 
        }
    ;

lista_campos
    : lista_campos T_IDENTIF
        {
            
            campos = insereCampo(campos,atomo,tipo,pos,des,tam);
            //des = campos->desl + tam;
            des = des + tam;
            //tam++;
            
        }
    | T_IDENTIF
        {
            campos = insereCampo(campos,atomo,tipo,pos,des,tam);
            des = des + tam;
            //des = campos->desl + tam;
            //tam++;  
        }
    ;

variaveis
    : /*vazio*/
    | declaracao_variaveis
    ;

declaracao_variaveis
    : tipo lista_variaveis declaracao_variaveis
    | tipo lista_variaveis
    ;

lista_variaveis
    : lista_variaveis
    T_IDENTIF 
        {
            strcpy(elemTab.id, atomo);
            elemTab.end = contaVar;
            elemTab.tip = tipo;
            elemTab.tam = tam;
            elemTab.pos = pos;
            insereSimbolo(elemTab);
            if(elemTab.tip == REG){
                contaVar = contaVar + tam;
            }
            else{
                contaVar++;
            }
        }
    | T_IDENTIF
        {
            strcpy(elemTab.id, atomo);
            elemTab.end = contaVar;
            elemTab.tip = tipo;
            elemTab.tam = tam;
            elemTab.pos = pos;
            insereSimbolo(elemTab);
            if(elemTab.tip == REG){
                contaVar = contaVar + tam;
            }
            else{
                contaVar++;
            }
        }
    ;

lista_comandos
    : /*vazio*/
    | comando lista_comandos
    ;

comando
    : entrada_saida
    | atribuicao
    | selecao
    | repeticao
    ;

entrada_saida
    : entrada
    | saida
    ;

entrada
    :T_LEIA T_IDENTIF
    {
        int pos = buscaSimbolo(atomo);
        if(tabSimb[pos].tip == REG){
            for (int i = 0; i < tam; i++){
                fprintf(yyout, "\tLEIA\n");
                fprintf(yyout, "\tARZG\t%d\n", tabSimb[pos].end);
            }
        }
        else {
            fprintf(yyout, "\tLEIA\n");
            fprintf(yyout, "\tARZG\t%d\n", tabSimb[pos].end);
        }

    }
    ;

saida
    :T_ESCREVA expressao
        {   
            desempilha();
            int pos = buscaSimbolo(atomo);
            if(tabSimb[pos].tip == REG){
                tam = tabSimb[pos].tam;
                for (int i = 0; i < tam; i++) {
                    fprintf(yyout, "\tESCR\n");
                }
            }
            else {
                fprintf(yyout, "\tESCR\n");
            }
            
        }
    ;

atribuicao
    /*
    : T_IDENTIF
        {
            int pos = buscaSimbolo(atomo);
            empilha(pos); 
        } 
    T_ATRIB expressao
    {
        int tip = desempilha();
        int pos = desempilha();
        if(tabSimb[pos].tip != tip)
            yyerror("Incompatibilidade de tipo!");
        fprintf(yyout, "\tARGZ\t%d\n", tabSimb[pos].end);
           
    }
    ;
    */
    : expressao_acesso
       { 
         // TODO #10 - FEITO
         // Tem que guardar o TAM, DES e o TIPO (POS do tipo, se for registro)
          empilha(tam);
          empilha(des);
          empilha(tipo);
          // Possivelmente errado
          if(tipo == REG)
            empilha(pos);
       }
     T_ATRIB expressao
       { 
          int tipexp = desempilha();
          int tipvar = desempilha();
          int des = desempilha();
          int tam = desempilha();
          /*
          fprintf(yyout,"%d\n",tipexp);
          fprintf(yyout,"%d\n",tipvar);
          if (tipexp != tipvar)
             yyerror("Incompatibilidade de tipo!");
          */
          // TODO #11 - FEITO
          // Se for registro, tem que fazer uma repetição do
          // TAM do registro de ARZG
          if(tipo == REG)
            for (int i = 0; i < tam; i++)
                fprintf(yyout, "\tARZG\t%d\n", des + i); 
          else
            fprintf(yyout, "\tARZG\t%d\n", des);
       }
   ;

selecao
    : T_SE expressao T_ENTAO 
        {
            int t = desempilha();
            if(t != LOG)
                yyerror("Incompatibilidade de tipo!");
            fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo);
            empilha(rotulo);
        }
    lista_comandos T_SENAO
        {
            fprintf(yyout, "\tDSVS\tL%d\n", ++rotulo);
            int rot = desempilha();
            fprintf(yyout, "L%d\tNADA\n", rot);
            empilha(rotulo);    
        } 
    lista_comandos T_FIMSE
        {
            int rot = desempilha();
            fprintf(yyout, "L%d\tNADA\n", rot);
        }
    ;

repeticao
    : T_ENQUANTO 
        {
            fprintf(yyout, "L%d\tNADA\n", ++rotulo);
            empilha(rotulo);
        }
    expressao T_FACA 
        {
            int t = desempilha();
            if(t != LOG)
                yyerror("Incompatibilidade de tipo!");
            fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo);
            empilha(rotulo);
        }
    lista_comandos T_FIMENQTO
    {
        int rot1 = desempilha();
        int rot2 = desempilha();
        fprintf(yyout, "\tDSVS\tL%d\n", rot2);
        fprintf(yyout, "L%d\tNADA\n", rot1);
    }
    ;

expressao
    : expressao T_VEZES expressao
        {   testaTipo(INT,INT,INT); fprintf(yyout, "\tMULT\n");}
    | expressao T_MAIS expressao
        {   testaTipo(INT,INT,INT); fprintf(yyout, "\tSOMA\n");}
    | expressao T_DIV expressao
        {   testaTipo(INT,INT,INT); fprintf(yyout, "\tDIV\n");}
    | expressao T_MENOS expressao
        {   testaTipo(INT,INT,INT); fprintf(yyout, "\tSUBT\n");}
    | expressao T_MAIOR expressao
        {   testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMMA\n");}
    | expressao T_MENOR expressao
        {   testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMME\n");}
    | expressao T_IGUAL expressao
        {   testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMIG\n");}
    | expressao T_E expressao
        {   testaTipo(LOG,LOG,LOG); fprintf(yyout, "\tCONJ\n");}
    | expressao T_OU expressao
        {   testaTipo(LOG,LOG,LOG); fprintf(yyout, "\tDISJ\n");}
    | termo
    ;

expressao_acesso
    : T_IDPONTO
        {
            if (!ehRegistro) {
                    ehRegistro = 1;
                    int pos = buscaSimbolo(atomo);
                    if(tabSimb[pos].tip != REG)
                        yyerror("Incompatibilidade de tipo");
                    empilha(tabSimb[pos].tam);
                    empilha(tabSimb[pos].pos);
                    empilha(des);

            }
            else {
                // Possivelmente errado
                //int pos = buscaSimbolo(atomo);
                //campos = NULL;
                campos = busca(campos,atomo);
                if(campos == NULL)
                    yyerror("O campo não é registro");
                empilha(campos->tam);
                empilha(campos->pos);
                empilha(campos->desl);

            }
        }
        expressao_acesso
    ;
    | T_IDENTIF
        {   
            if(ehRegistro) {
                campos = busca(tabSimb[pos].campo,atomo);
                if(campos == NULL)
                    yyerror("O campo não é registro");
                empilha(campos->tam);
                // Ou empilha(campos->tipo);
                empilha(campos->pos);
                empilha(campos->desl);

            }
            else {
            int pos = buscaSimbolo(atomo);
            // fprintf(yyout, "\tCRVG\t%d\n", tabSimb[pos].end);
            empilha(tabSimb[pos].tip);
            empilha(tabSimb[pos].tam);
            empilha(des);
            }
            ehRegistro = 0; // Para sinalizar que não é registro
        }
    
    
termo 
    : expressao_acesso
        {
          indice = buscaSimbolo(atomo);
            
          if(tabSimb[indice].tip == REG) {
            for (int i = tabSimb[indice].tam ; i > 0; i--) {
                fprintf(yyout, "\tCRVG\t%d\n", i);
                empilha(tipo);
                // des = tabSimb[pos].campo->desl; 
            }
          }
          else {
            fprintf(yyout, "\tCRVG\t%d\n", tabSimb[indice].end);  
            empilha(tipo);
          }
          pos = indice;
          //des = ;
          //tip =;
        }
    | T_NUMERO
        {
            fprintf(yyout, "\tCRCT\t%s\n", atomo);
            empilha(INT);
        }
        
    | T_V
        {
            fprintf(yyout, "\tCRCT\t1\n");
            empilha(LOG);
        }
    | T_F
        {
            fprintf(yyout, "\tCRCT\t0\n");
            empilha(LOG);
        }
    | T_NAO termo
        {
            int t = desempilha();
            if(t != LOG)
                yyerror("Incompatibilidade de tipo");
            fprintf(yyout, "\tNEGA\n");
            empilha(LOG);
        }
    | T_ABRE expressao T_FECHA
    ;


%%
int main (int argc, char *argv[]) {
    char *p, nameIn[100], nameOut[100];
    argv++;
    if(argc < 2){
        puts("/nCompilador da linguagem SIMPLES");
        puts("\n\tUSO: ./simples <Nome>[.simples]\n\n");
        exit(1);
    }
    p = strstr(argv[0], ".simples");
    if(p) *p = 0;
    strcpy(nameIn, argv[0]);
    strcat(nameIn, ".simples");
    strcpy(nameOut, argv[0]);
    strcat(nameOut, ".mvs");
    yyin = fopen(nameIn, "rt");
    if(!yyin){
        puts("Programa fonte não encontrado!");
        exit(2);
    }
    yyout = fopen(nameOut, "wt");
    yyparse();
    printf("programa ok!\n");
    return 0;
}
