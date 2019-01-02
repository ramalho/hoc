# *hoc1*: calculadora de quatro operações

Esta página descreve o programa do diretório [etapa1/](https://github.com/ramalho/hoc/tree/master/etapa1).

* [Exemplo de uso](#exemplo-de-uso)
* [Como compilar](#como-compilar)
* [Explicação do programa](#explicação-do-programa)

## Exemplo de uso

As linhas indentadas são a saída do programa:

```
$ ./hoc1
1 + 2
	3
(100 - 32) * 5 / 9
	37.777778
37.8 * 9 / 5 + 32
	100.04
37.777778 * 9 / 5 + 32
	100
```

## Construção do programa

### Passo 1: gerar o *parser*

Use `yacc` (na verdade, **bison**), para gerar o código do programa em C.

Resultado em um	Ubuntu 18.04.1 LTS:

```
$ yacc --version
bison (GNU Bison) 3.0.4
(etc...)
$ yacc hoc1.y
$ ls
hoc1.y  README.md  y.tab.c
```

Isso gera o arquivo `y.tab.c`, com todo o código da calculadora.

### Passo 2: compilar o executável

Use o compilador `cc` para gerar o executável `hoc1`:

```
$ cc --version
cc (Ubuntu 7.3.0-27ubuntu1~18.04) 7.3.0
$ cc y.tab.c -o hoc1
y.tab.c: In function ‘yyparse’:
y.tab.c:1118:16: warning: implicit declaration of function ‘yylex’ [-Wimplicit-function-declaration]
       yychar = yylex ();
                ^~~~~
(...vários outros avisos...)
$ ls
hoc1  hoc1.y  README.md  y.tab.c
```

> ✋ Eu gostaria de eliminar todos os avisos gerados nessa compilação, se possível sem suprimir os avisos no compilador, mas sim seguindo as regras dele. Porém tenho pouca experiência com C, e alguns avisos vêm do código gerado, `y.tab.c`, então não sei como resolver. Se você sabe resolver pelo menos parte desses avisos, faça um *pull request* ou entre em contato pelo *issue tracker* do repositório para a gente parear. Agradeço desde já!

### Passo 3: testar

O arquivo `testes.hoc` tem alguns casos de testes básicos.

```
2 + 2
(100 - 32) * 5 / 9
32 + 38 * 9 / 5
```

Uma expressão bem simples, uma expressão com parêntesis para converter 100 °F em °C, e uma expressão para converter 38 °C para °F. Nessa última, a precedência das operações importa: a soma deve ser o último passo para chegar ao resultado correto.

Forneça `testes.hoc` como arquivo de entrada para `hoc1` assim:

```
$ ./hoc1 < testes.hoc
	4
	37.777778
	100.4
```

Assim conferimos que 2 + 2 é 4, 100 °F é 37.777776 °C, e 38 °C é 100.4 °F. Faz sentido.

## Explicação do programa

O código fonte de `hoc1` é [`hoc1.y`](https://github.com/ramalho/hoc/blob/master/etapa1/hoc1.y). A seguir vamos explicar suas 66 linhas.

Neste exemplo simples de uso de **yacc**, temos um *parser* (analisador sintático) que efetua operações diretamente. Em um interpretador mais sofisticado, como veremos a partir da etapa 4, o parser produz uma representação interna do programa, que é passada para um *evaluator* (avaliador), que efetivamente executa as instruções.

Note que o código-fonte de `hoc1.y` é uma mistura de linhas em C com linhas na sintaxe especial de **yacc**.

### Definição da gramática

As primeiras 6 linhas de `hoc1.y` contém uma linha em C, delimitada por `%{` e `%}`, e três linhas de código **yacc** com declarações `token` e `left`:

```
%{
#define	YYSTYPE double  /* tipo da pilha de yacc */
%}
%token	NUMBER
%left	'+' '-'  /* associatividade esquerda, mesma precedência */
%left	'*' '/'  /* associatividade direita, maior precedência */
```

Aqui temos:

* A definição de uma macro em C que define o tipo `YYSTYPE` como `double`. Esse tipo é usado pelo código gerado por **yacc** para representar os valores. Por enquanto, temos um simples tipo numérico de ponto flutuante.
* A declaração `token NUMBER`, que define um tipo de *token* — elemento sintático básico — que estamos chamando de `NUMBER`.
* As declarações dos operadores `+` e `-`, com *associatividade esquerda*.
* As declarações dos operadores `*` e `/`, também com *associatividade esquerda*, porém maior precedência, porque estão declarados depois de  `+` e `-`.

#### Termos técnicos

**Token** é o menor elemento sintático significativo. Por exemplo, a expressão `peso*2 <= 6.5` contém 5 *tokens*: `peso`, `*`, `2`, `<=` e `6.5`. Os caracteres são agrupados para formar números, símbolos e palavras completas, conforme as definições de *tokens* e regras sintáticas, como veremos a seguir.

**Precedência** é a ordem de execução dos diferentes operadores. Por exemplo, queremos que as multiplicações e divisões sejam feitas antes das somas e subtrações. Ou seja, o resultado de `4 + 3 * 2` é o mesmo que `4 + 6` (=10) e não `7 * 2` (=14).

**Associatividade** é a ordem de execução de uma sequência com o mesmo operador. Por exemplo, a **associatividade esquerda** do operador `+` significa que `4 + 3 + 2` é calculado da esquerda para direita, assim: `(4 + 3) + 2`. Um exemplo do caso contrário, **associatividade direita**, é o operador de exponenciação `^` que expressa 2³ como `2 ^ 3` (=8). Conforme a convenção da matemática, queremos que o valor de `4 ^ 3 ^ 2`, seja calculado a partir da direita, assim: `4 ^ (3 ^ 2)`, o mesmo que `4 ^ 9` (=262144). Neste caso seria errado fazer `(4 ^ 3) ^ 2`, que seria `64 ^ 2` (=4096).

#### Regras sintáticas

O próximo trecho delimitado por `%%` define duas regras sintáticas, `list` e `expr`:

```
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

```

A primeira regra diz que uma `list` pode ter 3 formas:

1. nada (texto vazio);
2. uma `list` seguida de `'\n'` (caractere de quebra de linha);
3. uma `list` seguida de `expr` seguida de `'\n'`.

Essa é uma definição recursiva, que na prática diz que uma lista pode ser formada por 0 ou mais `expr` separadas por `'\n'`.

A terceira forma de `list` contém um bloco de código `{…}` à direita, com uma chamada para `printf`. Quando o analisador sintático casa um trecho do código-fonte com essa forma, temos uma `expr` seguida de `'\n'`, e podemos exibir seu resultado, que estará em `$2`. 

A regra sobre `expr` é mais interessante. São 6 formas, cada uma com um bloco `{…}` à direita para computar seu valor:

1. um número simples, ex. 1.23 — seu valor é o valor da própria expressão, `$1`;
2. duas expressões com o caractere `'+'` no meio — seu valor é a soma das duas expressões;
3. duas expressões com o caractere `'-'` no meio — seu valor é a subtração da primeira pela segunda expressão;
4. duas expressões com o caractere `'*'` no meio — seu valor é a multiplicação das duas expressões;
5. duas expressões com o caractere `'/'` no meio — seu valor é a divisão da primeira pela segunda expressão;
6. um caractere `'('`, uma expressão, e um caractere `')'` — seu valor é o valor da expressão no meio.

> ✋ A gramática definida aqui não suporta o operador `-` unário. Se você passar o texto `-1` para `hoc1`, o programa vai reclamar de um erro de sintaxe. Isso será resolvido na próxima etapa.


### Função principal

Depois do comentário `/* end of grammar */`, o que temos é só código em linguagem C.

Aqui são incluídos dois arquivos da biblioteca padrão, definidas duas variáveis globais, e declarada a função `main`:

```
#include <stdio.h>
#include <ctype.h>
char	*progname;		/* para mensagens de erro */
int	lineno = 1;

int
main(int argc, char* argv[])	/* hoc1 */
{
	progname = argv[0];
	yyparse();
}
```

A função `main` faz apenas duas coisas:

1. Atribuir o valor do primeiro argumento da linha de comando à variável `progname`. Esse valor será `"hoc1"` neste exemplo.
2. Invocar a função `yyparse`. Esta função não é definida em lugar algum de `hoc1.y`, mas será gerada pelo **yacc/bison** quando você executar o comando `yacc hoc1.y` no terminal.

Se você inspecionar o arquivo gerado, `y.tab.c`, verá que a função `yyparse` para este exemplo simples tem cerca de 500 linhas de código (da linha 961 à 1466 no meu caso, mas pode ser diferente para você).

### Analisador léxico

O código de `yyparse` espera que exista uma função chamada `yylex`, que faz a análise léxica e devolve o próximo *token* a cada chamada. Na verdade, `yylex` devolve duas informações: seu resultado é um código numérico que identifica a categoria do *token*, e quando o *token* tem um valor (como um valor numérico neste exemplo), o valor é colocado na variável global `yylval`, declarada em `y.tab.c` como sendo do tipo `YYSTYPE`, ou `double` neste exemplo.

Por exemplo, se o *token* for `"3.1416"`, `yylex` devolve o código `NUMBER`, e coloca o valor 3.1416 em `yylval`. Outro exemplo: se o *token* é `"*"`, o número `'*'` é devolvido (esse é o número 42, o código ASCII do sinal *). Neste caso, nenhum valor é colocado em `yylval`.

Após a declaração `int c`, o código de `yylex` pode ser divido em 5 partes:

```
yylex(void)			/* hoc1 */
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
```

1. Laço `while` que consome caracteres brancos (espaços e tabs), deixando na variável `c` o primeiro caractere não-branco.
2. Se `c` é EOF, devolva o código 0, sinalizando para `yyparse` que não há mais nada a ser lido.
3. Se `c` é um ponto ou um dígito, coloque ele de volta no *buffer* de entrada (`ungetc`), use a função `scanf` para ler um número de ponto flutuante para dentro da variável global `yylval`, e devolva o código `NUMBER`.
4. Se `c` é uma quebra de linha, incremente o contador de linhas.
5. Do contrário, devolva o código ASCII do caractere lido.

Na etapa 3, Kernighan e Pike mostram rapidamente o uso de **lex** para gerar o analisador léxico a partir de regras com expressões regulares.

### Tratamento de erros

O código gerado por **yacc/bison** também precisa que você forneça uma função `yyerror`, que será chamada para reportar ou tratar situações de erro. Neste exemplo, `yyerror` apenas invoca uma função `warning`, definida no mesmo arquivo `hoc1.y`.

```
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
```

O tratamento de erros nessa versão `hoc1` é tosco. Isso será melhorado nas próximas etapas.
