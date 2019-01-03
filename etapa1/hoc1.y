%{
#include <stdio.h>
#include <ctype.h>

#define	YYSTYPE double  /* tipo da pilha de yacc */

int yylex(void);
void yyerror(char *);
%}
%token	NUMERO
%left	'+' '-'  /* associatividade esquerda */
%left	'*' '/'  /* associatividade esquerda, maior precedência */
%%
lista:	  /* nada */
	| lista '\n'
	| lista expr '\n'  { printf("\t%.8g\n", $2); }
	;
expr:	  NUMERO { $$ = $1; }
	| expr '+' expr	{ $$ = $1 + $3; }
	| expr '-' expr	{ $$ = $1 - $3; }
	| expr '*' expr	{ $$ = $1 * $3; }
	| expr '/' expr	{ $$ = $1 / $3;  }
	| '(' expr ')'	{ $$ = $2; }
	;
%%
	/* fim da gramática */

char	*nome_prog;		 /* para mensagens de erro */
int	num_linha = 1;

int main(int argc, char* argv[]) /* hoc1 */
{
	nome_prog = argv[0];
	yyparse();
}

int yylex(void)			 /* hoc1 */
{
	int c;

	while ((c=getchar()) == ' ' || c == '\t')
		;
	if (c == EOF)
		return 0;
	if (c == '.' || isdigit(c)) {	/* número */
		ungetc(c, stdin);
		scanf("%lf", &yylval);
		return NUMERO;
	}
	if (c == '\n')
		num_linha++;
	return c;
}

void yyerror(char* s)	/* erro de sintaxe */
{
	fprintf(stderr, "%s: %s near line %d\n", 
		nome_prog, s, num_linha);
}
