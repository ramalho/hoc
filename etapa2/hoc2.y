%{
#include <stdio.h>
#include <ctype.h>
#include <signal.h>
#include <setjmp.h>

double	mem[26];	/* memória para variáveis 'a'...'z' */

int yylex(void);
void yyerror(char *);
void aviso(char *s);
void recuperar(char* s);
%}
%union {		/* tipo da pilha de yacc */
	double	val;	/* valor numérico */
	int	indice;	/* indice para acessar mem[] */  
}
%token	<val>	 NUMERO
%token	<indice> VAR
%type	<val>	 expr
%right	'='	 /* associatividade direita, menor precedência */
%left	'+' '-'  /* associatividade esquerda */
%left	'*' '/'  /* associatividade esquerda, maior precedência */
%left	NEGATIVO /* hoc1b */
%%
lista:	  /* nada */
	| lista '\n'
	| lista expr '\n'  { printf("\t%.8g\n", $2); }
	| lista error '\n' { yyerrok; }
	;
expr:	  NUMERO	{ $$ = $1; }
	| VAR		{ $$ = mem[$1]; }
	| VAR '=' expr	{ $$ = mem[$1] = $3; }
	| '-' expr %prec NEGATIVO { $$ = -$2; }
	| expr '+' expr	{ $$ = $1 + $3; }
	| expr '-' expr	{ $$ = $1 - $3; }
	| expr '*' expr	{ $$ = $1 * $3; }
	| expr '/' expr	{
		if ($3 == 0.0)
			recuperar("division by zero");
		$$ = $1 / $3; }
	| '(' expr ')'	{ $$ = $2; }
	;
%%
	/* fim da gramática */

char	*nome_prog;		 /* para mensagens de erro */
int	num_linha = 1;
jmp_buf	inicio;			 /* dados para longjmp */

int main(int argc, char* argv[]) /* hoc2 */
{
	void tratar_exc_pf();

	nome_prog = argv[0];

	setjmp(inicio);
	signal(SIGFPE, tratar_exc_pf);

	yyparse();
}

int yylex(void)			 /* hoc2 */
{
	int c;

	while ((c=getchar()) == ' ' || c == '\t')
		;
	if (c == EOF)
		return 0;
	if (c == '.' || isdigit(c)) {	/* número */
		ungetc(c, stdin);
		scanf("%lf", &yylval.val);
		return NUMERO;
	}
	if (islower(c)) {
		yylval.indice = c - 'a';  /* somente ASCII! */
		return VAR;
	}
	if (c == '\n')
		num_linha++;
	return c;
}

void yyerror(char* s)	/* erro de sintaxe */
{
	aviso(s);
}

void aviso(char *s)	/* exibir aviso */
{
	fprintf(stderr, "%s: %s near line %d\n", 
		nome_prog, s, num_linha);
}

void recuperar(char* s)  /* recuperar de um erro de uso */
{
	aviso(s);
	longjmp(inicio, 0);
}

void tratar_exc_pf()	/* tratar exceções de ponto flutuante */
{
	recuperar("floating point exception");
}