%{
#include <stdio.h>
#include <ctype.h>

#define	YYSTYPE double  /* tipo da pilha de yacc */

int yylex(void);
void warning(char *, char *);
void yyerror(char *);
%}
%token	NUMBER
%left	'+' '-'  /* associatividade esquerda */
%left	'*' '/'  /* associatividade esquerda, maior precedência */
%%
list:	  /* nada */
	| list '\n'
	| list expr '\n'  { printf("\t%.8g\n", $2); }
	;
expr:	  NUMBER { $$ = $1; }
	| expr '+' expr	{ $$ = $1 + $3; }
	| expr '-' expr	{ $$ = $1 - $3; }
	| expr '*' expr	{ $$ = $1 * $3; }
	| expr '/' expr	{ $$ = $1 / $3;  }
	| '(' expr ')'	{ $$ = $2; }
	;
%%
	/* end of grammar */

char	*progname;		/* para mensagens de erro */
int	lineno = 1;

int
main(int argc, char* argv[])	/* hoc1 */
{
	progname = argv[0];
	yyparse();
}

int yylex(void)			/* hoc1 */
{
	int c;

	while ((c=getchar()) == ' ' || c == '\t')
		;
	if (c == EOF)
		return 0;
	if (c == '.' || isdigit(c)) {	/* número */
		ungetc(c, stdin);
		scanf("%lf", &yylval);
		return NUMBER;
	}
	if (c == '\n')
		lineno++;
	return c;
}

void
warning(char *s, char *t)	/* exibir aviso */
{
	fprintf(stderr, "%s: %s", progname, s);
	if (t)
		fprintf(stderr, " %s", t);
	fprintf(stderr, " near line %d\n", lineno);
}

void
yyerror(char* s)	/* erro de sintaxe */
{
	warning(s, (char *)0);
	/* execerror(s, (char *)0); */
}

