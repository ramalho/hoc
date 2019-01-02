# *hoc1*: calculadora de quatro operações

Esta página descreve o programa do diretório [etapa1/](https://github.com/ramalho/hoc/tree/master/etapa1).

* [Exemplo de uso](#exemplo-de-uso)
* [Como compilar](#como-compilar)
* [Explicação do programa](#explicação-do-programa)

## Exemplo de uso

As linhas indentadas são a saída do programa:

```bash
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

```bash
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

```bash
$ cc --version
cc (Ubuntu 7.3.0-27ubuntu1~18.04) 7.3.0
$ cc y.tab.c -o hoc1
$ ls
hoc1  hoc1.y  README.md  y.tab.c
```

### Passo 3: testar

O arquivo `testes.hoc` tem alguns casos de testes básicos.

```
2 + 2
(100 - 32) * 5 / 9
32 + 38 * 9 / 5
```

Uma expressão bem simples, uma expressão com parêntesis para converter 100 °F em °C, e uma expressão para converter 38 °C para °F. Nessa última, a precedência das operações importa: a soma deve ser o último passo para chegar ao resultado correto.

Forneça `testes.hoc` como arquivo de entrada para `hoc1` assim:

```bash
$ ./hoc1 < testes.hoc
	4
	37.777778
	100.4
```

Assim conferimos que 2 + 2 é 4, 100 °F é 37.777776 °C, e 38 °C é 100.4 °F. Faz sentido.

## Explicação do programa

O programa `hoc1` é um interpretador de expressões aritméticas interativo. 

O código-fonte está em [`hoc1.y`](https://github.com/ramalho/hoc/blob/master/etapa1/hoc1.y). A seguir vamos explicar suas 66 linhas.

Neste exemplo simples de uso de **yacc**, temos um *parser* (analisador sintático) que efetua operações imediatamente, assim que uma estrutura sintática casa com uma regra da gramática. Em um interpretador mais sofisticado, como veremos a partir da etapa 4, o parser produz uma representação interna do programa, que é passada para um *evaluator* (avaliador), que vai executar as instruções.

### Declarações iniciais

O código-fonte de `hoc1.y` é uma mistura de linhas em C com linhas na sintaxe especial de **yacc**.

A primeira seção do código, entre os marcadores `%{` e `%}`, é código em C (tirei os marcadores para que a colorização sintática funcione nesta página):

```c
#include <stdio.h>
#include <ctype.h>

#define	YYSTYPE double  /* tipo da pilha de yacc */

int yylex(void);
void yyerror(char *);
void aviso(char *, char *);
```

Aqui temos:

1. Inclusão de dois arquivos da biblioteca-padrão de C.
2. Definição de uma macro em C que define o tipo `YYSTYPE` como `double`. Esse tipo é usado pelo código gerado por **yacc** para representar os valores. Por enquanto, temos um simples tipo numérico de ponto flutuante.
3. Declaração da assinatura de três funções que serão definidas no final do arquito, mas que vão ser invocadas por código gerado pelo **yacc**. Sem essas declarações, o compilador gera avisos de "implicit declaration" (declaração implícita).

### Definição da gramática

Após o marcador `%}`, temos três linhas de código **yacc** com declarações `token` e `left`:

```c
%token	NUMERO
%left	'+' '-'  /* associatividade esquerda */
%left	'*' '/'  /* associatividade esquerda, maior precedência */
```

1. A declaração `token NUMERO`, que define um tipo de *token* — ver [definição](#termos-técnicos) — que estamos chamando de `NUMERO`.
2. As declarações dos operadores `+` e `-`, com *associatividade esquerda* — ver [definição](#termos-técnicos) a seguir.
3. As declarações dos operadores `*` e `/`, também com *associatividade esquerda*, porém maior precedência, porque estão declarados depois de  `+` e `-`.

#### Termos técnicos

**Token** é o menor elemento sintático significativo. Por exemplo, a expressão `peso*2 <= 6.5` contém 5 *tokens*: `peso`, `*`, `2`, `<=` e `6.5`. Uma parte do programa, o analisador léxico, vai agrupar os caracteres formando números, símbolos e palavras completas, conforme as definições de *tokens* e regras sintáticas, como veremos mais adiante.

**Precedência** é a ordem de execução dos diferentes operadores. Por exemplo, queremos que as multiplicações e divisões sejam feitas antes das somas e subtrações. Ou seja, o resultado de `4 + 3 * 2` é o mesmo que `4 + 6` (=10) e não `7 * 2` (=14).

**Associatividade** é a ordem de execução de uma sequência com o mesmo operador. Por exemplo, a **associatividade esquerda** do operador `-` significa que `4 - 3 - 2` é calculado da esquerda para direita, assim: `(4 - 3) - 2` (=-1). Um exemplo do caso contrário, **associatividade direita**, é o operador de exponenciação `^` que expressa 2³ como `2 ^ 3` (=8). Conforme a convenção da matemática, queremos que o valor de `4 ^ 3 ^ 2`, seja calculado a partir da direita, assim: `4 ^ (3 ^ 2)`, o mesmo que `4 ^ 9` (=262144). Neste caso seria errado fazer `(4 ^ 3) ^ 2`, que seria `64 ^ 2` (=4096).

#### Regras sintáticas

O próximo trecho delimitado por `%%` define duas regras sintáticas, `lista` e `expr`:

```c
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
	/* end of grammar */

```

A primeira regra diz que uma `lista` pode ter 3 formas:

1. nada (texto vazio);
2. uma `lista` seguida de `'\n'` (caractere de quebra de linha);
3. uma `lista` seguida de `expr` seguida de `'\n'`.

Essa é uma definição recursiva, que na prática diz que uma lista pode ser formada por 0 ou mais `expr` separadas por `'\n'`.

A terceira forma de `lista` contém um bloco de código `{…}` à direita, com uma chamada para `printf`. Quando o analisador sintático casa um trecho do código-fonte com essa forma, temos uma `expr` seguida de `'\n'`, e podemos exibir seu resultado, que estará em `$2`. 

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

Aqui são definidas duas variáveis globais, e declarada a função `main`:

```c
char	*nome_prog;		/* para mensagens de erro */
int	num_linha = 1;

int
main(int argc, char* argv[])	/* hoc1 */
{
	nome_prog = argv[0];
	yyparse();
}
```

A função `main` faz apenas duas coisas:

1. Atribui o valor do primeiro argumento da linha de comando à variável `nome_prog`. Esse valor será `"hoc1"` neste exemplo.
2. Invoca a função `yyparse`. Esta função não é definida em lugar algum de `hoc1.y`, mas será gerada pelo **yacc/bison** quando você executar o comando `yacc hoc1.y` no terminal.

Se você inspecionar o arquivo gerado, `y.tab.c`, verá que a função `yyparse` para este exemplo simples tem cerca de 500 linhas de código (da linha 1061 à 1562 no meu caso, mas pode ser diferente para você).

### Analisador léxico

O código de `yyparse` espera que exista uma função chamada `yylex`, que faz a análise léxica e devolve o próximo *token* a cada chamada. Na verdade, `yylex` devolve duas informações: seu resultado é um código numérico que identifica a categoria do *token*, e quando o *token* tem um valor (como um valor numérico neste exemplo), o valor é colocado na variável global `yylval`, declarada em `y.tab.c` como sendo do tipo `YYSTYPE`, ou `double` neste exemplo.

Por exemplo, se o *token* for `"3.1416"`, `yylex` devolve o código `NUMERO`, e coloca o valor 3.1416 em `yylval`. Outro exemplo: se o *token* é `"*"`, o número `'*'` é devolvido (esse é o número 42, o código ASCII do sinal *). Neste caso, nenhum valor é colocado em `yylval`.

Após a declaração `int c`, o código de `yylex` pode ser divido em 5 partes:

```c
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
		return NUMERO;
	}
	if (c == '\n')
		num_linha++;
	return c;
}
```

1. Laço `while` que consome caracteres brancos (espaços e tabs), deixando na variável `c` o primeiro caractere não-branco.
2. Se `c` é EOF, devolva o código 0, sinalizando para `yyparse` que não há mais nada a ser lido.
3. Se `c` é um ponto ou um dígito, coloque ele de volta no *buffer* de entrada (`ungetc`), use a função `scanf` para ler um número de ponto flutuante para dentro da variável global `yylval`, e devolva o código `NUMERO`.
4. Se `c` é uma quebra de linha, incremente o contador de linhas.
5. Do contrário, devolva o código ASCII do caractere lido.

Na etapa 3, Kernighan e Pike mostram rapidamente o uso de **lex** para gerar o analisador léxico a partir de regras com expressões regulares.

### Tratamento de erros

O código gerado por **yacc/bison** também precisa que você forneça uma função `yyerror`, que será chamada para reportar ou tratar situações de erro. Neste exemplo, `yyerror` apenas invoca uma função `aviso`, definida em seguida.

```c
void
yyerror(char* s)	/* erro de sintaxe */
{
	aviso(s, (char *)0);
}

void
aviso(char *s, char *t)	/* exibir aviso */
{
	fprintf(stderr, "%s: %s", nome_prog, s);
	if (t)
		fprintf(stderr, " %s", t);
	fprintf(stderr, " perto da linha %d\n", num_linha);
}
```

O tratamento de erros nessa versão `hoc1` é tosco. Isso será melhorado nas próximas etapas.

----

Voltar para o [índice de páginas](index.md#índice-de-páginas).
