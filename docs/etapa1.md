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

O programa `hoc1` é um interpretador de expressões aritméticas interativo. O código-fonte está em [`hoc1.y`](https://github.com/ramalho/hoc/blob/master/etapa1/hoc1.y) ([link](https://github.com/ramalho/hoc/blob/master/etapa1/hoc1.y)).

### Termos técnicos

**Análise léxica** é a transformação do código-fonte em uma série de palavras, números, símbolos, etc., chamados genericamente de *tokens* (ver a seguir).

**Análise sintática** é a montagem de *tokens* para formar expressões e declarações válidas conforme a gramática da linguagem.

**Token** é o menor elemento sintático significativo. Por exemplo, a expressão...

```
peso*2 <= 6.5
```

...contém 5 *tokens*:

* `peso`
* `*`
* `2`
* `<=`
* `6.5`

### Visão geral do código

Neste exemplo simples de uso de **yacc**, as três funções mais importantes são:

#### `int main(int argc, char* argv[])`

É onde tudo começa. A `main` é muito simples neste exemplo. Sua missão principal é invocar `yyparse`.

#### `int yyparse(void)`

Essa função faz a análise sintática. Ela é gerada pela ferramenta **yacc** — seu código aparece no arquivo `y.tab.c`. Ela implementa a lógica do *parser*, usando a regras especificadas em [Definição da gramática](#definição-da-gramática), como veremos. Para ler o código-fonte, `yyparse` invoca repetidamente a função `yylex`, que precisamos implementar. Neste exemplo, `yyparse` realiza os cálculos imediatamente, assim que uma estrutura sintática casa com uma regra da gramática. Em um interpretador mais sofisticado, como veremos a partir da etapa 4, `yyparse` produz uma representação interna do programa, que é passada para um *evaluator* (avaliador), que vai executar as instruções.

#### `int yylex(void)`

Essa função faz a análise léxica. Toda vez que invocada por `yyparse`, `yylex` avança na leitura do código-fonte, e devolve um código tipo `int` que identifica a categoria do *token* que acabou de ser lido. Exemplos de categorias: número, identificador, operador aritmético como `'+'`,  delimitador como `'('` ou `'{'`, etc. Dependendo da categoria do *token*, `yyparse` coloca informações adicionais na variável global `yylval`, que `yyparse` também pode acessar. Para símbolos e delimitadores com apenas um caractere, o código devolvido por `yylex` normalmente é o código ASCII do caractere. Códigos acima de 127 são usados para outras categorias de *tokens* definidas na gramática. Chegando ao fim do código-fonte, `yylex` devolve o código `0`.

Nesse exemplo, quando `yylex` lê o texto `6.49`, ela devolve o código da categoria `NUMERO` e coloca o valor 6.49 em `yylval`.

> 🗒 Na prática, é como se `yylex` devolvesse dois resultados: a categoria e o valor do *token*. Mas funções em C não podem devolver dois resultados — como em Python ou Go — então a variável global `yylval` guarda a segunda parte da informação sobre o *token* que acabou de ser lido para `yyparse` poder acessar. 

### Declarações iniciais

A seguir vamos estudar as 70 linhas de [`hoc1.y`](https://github.com/ramalho/hoc/blob/master/etapa1/hoc1.y) ([código-fonte](https://github.com/ramalho/hoc/blob/master/etapa1/hoc1.y)). Esse arquivo  é uma mistura de linhas em C com linhas na sintaxe especial de **yacc**.

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
3. Declaração da assinatura de três funções que serão definidas no final do arquivo, e serão invocadas por código gerado pelo **yacc**. Sem essas declarações, o compilador gera avisos de "implicit declaration" (declaração implícita).

### Definição da gramática

Após o marcador `%}`, temos três linhas de código **yacc** com declarações `token` e `left`:

```c
%token	NUMERO
%left	'+' '-'  /* associatividade esquerda */
%left	'*' '/'  /* associatividade esquerda, maior precedência */
```

1. A declaração `token NUMERO` define uma categoria de *token* que estamos chamando de `NUMERO`. Em `hoc1`, um `NUMERO` é um valor de ponto flutuante, como 1.618.
2. As declarações dos operadores `+` e `-`, com *associatividade esquerda* — ver [definição](#mais-termos-técnicos) a seguir.
3. As declarações dos operadores `*` e `/`, também com *associatividade esquerda*, porém maior precedência, porque estão declarados depois de  `+` e `-`.

#### Mais termos técnicos

**Precedência** é a ordem de execução dos diferentes operadores. Por exemplo, queremos que as multiplicações e divisões sejam feitas antes das somas e subtrações. Ou seja, o resultado de `4 + 3 * 2` é o mesmo que `4 + 6` (=10) e não `7 * 2` (=14).

**Associatividade** é a ordem de execução de uma sequência com o mesmo operador. Por exemplo, a **associatividade esquerda** do operador `-` significa que `4 - 3 - 2` é calculado da esquerda para direita, assim: `(4 - 3) - 2` (=-1). Um exemplo do caso contrário, **associatividade direita**, é o operador de exponenciação `^` que expressa 2³ como `2 ^ 3` (=8). Conforme a convenção da matemática, queremos que o valor de `4 ^ 3 ^ 2`, seja calculado a partir da direita, assim: `4 ^ (3 ^ 2)`, o mesmo que `4 ^ 9` (=262144). Neste caso seria errado fazer `(4 ^ 3) ^ 2`, que seria `64 ^ 2` (=4096).

#### Regras sintáticas

O próximo trecho delimitado por `%%` define as regras sintáticas que definirão toda a lógica da função `yyparse` que será gerada pela ferramenta **yacc**.

Neste primeiro exemplo, há duas regras — `lista` e `expr`:

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
	/* fim da gramática */

```

A primeira regra diz que uma `lista` pode ter 3 formas:

1. nada (texto vazio);
2. uma `lista` seguida de `'\n'` (caractere de quebra de linha);
3. uma `lista` seguida de `expr` seguida de `'\n'`.

Na prática, essa definição recursiva diz que uma `lista` pode ser formada por 0 ou mais `expr` terminadas por `'\n'`.

A terceira forma de `lista` contém um bloco de código `{…}` à direita. Quando o *parser* casa um trecho do código-fonte com essa forma, temos uma `expr` seguida de `'\n'`, então usamos `printf` para exibir o valor da expressão, que estará em `$2`. 

A regra sobre `expr` é mais interessante. São 6 formas, cada uma com um bloco `{…}` à direita para computar seu valor:

1. um `NUMERO`, como 1.23 — seu valor é o valor da própria expressão, `$1`;
2. duas expressões com o caractere `'+'` no meio — seu valor é a soma das duas expressões;
3. duas expressões com o caractere `'-'` no meio — seu valor é a subtração da primeira pela segunda expressão;
4. duas expressões com o caractere `'*'` no meio — seu valor é a multiplicação das duas expressões;
5. duas expressões com o caractere `'/'` no meio — seu valor é a divisão da primeira pela segunda expressão;
6. um caractere `'('`, uma expressão, e um caractere `')'` — seu valor é o valor da expressão no meio.

> ✋ A gramática definida aqui não suporta o operador `-` unário. Se você passar o texto `-1` para `hoc1`, o programa vai reclamar de um erro de sintaxe. Isso será resolvido na próxima etapa.

### Função principal

Depois do comentário `/* fim da gramática */`, o que temos é só código em linguagem C.

Aqui são definidas duas variáveis globais, e declarada a função `main`:

```c
char	*nome_prog;		 /* para mensagens de erro */
int	num_linha = 1;

int main(int argc, char* argv[]) /* hoc1 */
{
	nome_prog = argv[0];
	yyparse();
}
```

A função `main` faz apenas duas coisas:

1. Atribui o valor do primeiro argumento da linha de comando à variável `nome_prog`. Esse valor será `"hoc1"` neste exemplo.
2. Invoca a função `yyparse` que será gerada pelo **yacc/bison** quando você executar o comando `yacc hoc1.y` no terminal.

Se você inspecionar o arquivo gerado, `y.tab.c`, verá que a função `yyparse` para este exemplo simples tem cerca de 500 linhas de código (da linha 1061 à 1562 no meu caso, mas pode ser diferente para você).

### Analisador léxico

Como já vimos, `yyparse` depende de uma função chamada `yylex` para fazer a análise léxica e devolver o próximo *token* a cada chamada. O resultado de `yylex` é um código numérico que identifica a categoria do *token*, e quando o *token* tem um valor — como um `NUMERO` neste exemplo — o valor é colocado na variável global `yylval`, declarada em `y.tab.c` como sendo do tipo `YYSTYPE` (como vimos em [Declarações iniciais](#declarações-iniciais)).

Por exemplo, se o *token* for `"3.1416"`, `yylex` devolve o código `NUMERO`, e coloca o valor 3.1416 em `yylval`. Outro exemplo: se o *token* é `"*"`, o número `'*'` é devolvido (esse é o número 42, o código ASCII do sinal *). Neste caso, nenhum valor é colocado em `yylval`.

Após a declaração `int c`, o código de `yylex` pode ser divido em 5 partes:

```c
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

O código de `yyparse` gerado por **yacc/bison** também precisa que você forneça uma função `yyerror`, que será chamada para reportar ou tratar situações de erro. Neste exemplo, `yyerror` apenas invoca uma função `aviso`, definida em seguida.

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
