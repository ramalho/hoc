# *hoc2*: variáveis e tratamento de erros

Aqui está descrito o programa do diretório [etapa2/](https://github.com/ramalho/hoc/tree/master/etapa2).

* [Explicação do programa](#explicação-do-programa)
* [Construir e testar](#construir-e-testar)

## Explicação do programa

Nesta etapa 2 implementamos variáveis e o operador de atribuição `=` na linguagem `hoc`. Para reduzir as mudanças necessárias, por enquanto vamos suportar variáveis com nomes de uma letra apenas, e somente minúsculas de "a" até "z".

O operador de atribuição terá associatividade direita, e formará uma expressão cujo valor é o número que está sendo atribuído. Essas características permitem atribuições múltiplas, assim:

```c
a = b = c = 3
```

Usaremos variáveis de "a" até "z" porque assim é fácil transformar o nome em um índice para um *array* de 26 posições. Introduzir variáveis na gramática traz uma complicação: agora a pilha de execução de **yacc** precisará lidar com valores de dois tipos: `double` para os números, e `int` para os índices das variáveis. Para isso usaremos uma declaração `%union` do **yacc**. Ela define um tipo que é a união de dois ou mais tipos.

Também vamos melhorar o tratamento de erros. Em `hoc1b`, uma expressão com erro de sintaxe como `3+/2` encerra o interpretador. Em `hoc2` vamos mostrar um aviso e continuar.

> ✋ No texto original de [UPE](https://en.wikipedia.org/wiki/The_Unix_Programming_Environment), os autores comentam que a versão `hoc1` também encerra quando ocorre uma divisão por zero. Não consegui reproduzir este erro. Quando digito `1/0` em `hoc1b` aparece o resultado `inf`, e para `-1/0`, o resultado é `-inf` — que correspondem a ∞ e -∞ pela norma [IEEE 754-1985](https://en.wikipedia.org/wiki/IEEE_754-1985#Positive_and_negative_infinity).

### Mudanças no prólogo

O prólogo de `hoc2.y` fica assim entre as marcas `%{` e `%}` (aqui omitidas para não atrapalhar a colorização da sintaxe na Web):


```c
#include <stdio.h>
#include <ctype.h>
#include <signal.h>	/* ❶ */
#include <setjmp.h>

double	mem[26];	/* ❷ memória para variáveis 'a'...'z' */

int yylex(void);
void yyerror(char *);
void aviso(char *s);	/* ❸ */
void recuperar(char* s);
```

1. Inclusão das bibliotecas `signal.h` e `setjmp.h` que usaremos para tratar erros.
2. Declaração do *array* de 26 posições para as variáveis.
3. Declaração das funções `aviso` e `recuperar`, implementadas no final do arquivo.

### Mudanças nas declarações de *yacc*

Após o final do prólogo marcado por `%}`  temos várias novidades nas delcarações de **yacc**:

```c
%}
%union {		/* ❶ tipo da pilha de yacc */
	double	val;	/* valor numérico */
	int	indice;	/* indice para acessar mem[] */  
}
%token	<val>	 NUMERO	/* ❷ */
%token	<indice> VAR	/* ❸ */
%type	<val>	 expr	/* ❹ */
%right	'='	 	/* ❺ associatividade direita */
%left	'+' '-'		/* associatividade esquerda */
%left	'*' '/'		
%left	NEGATIVO
```

1. A pilha de **yacc** agora vai conter elementos definidos pela união desses dois tipos: `double` quando for um valor numérico, ou `int` quando for o índice de uma variável no array `mem[]`.
2. A declaração da categoria de *token* `NUMERO` agora inclui o tipo `<val>`, que se refere ao membro `double val` da união declarada acima.
3. A nova declaração da categoria `VAR` inclui o tipo `<indice>`, indicando o membro `int indice` na união.
4. Esta declaração indica que o tipo de uma expressão é `<val>`, o mesmo que `double val` na união.
5. O *token* `=` é declarado com associatividade direita e precedência mínima (porque aparece antes dos demais operadores).

### Mudanças na gramática

A gramática, como sempre declarada entre `%%`, agora fica assim:

```c
%%
lista:	  /* nada */
	| lista '\n'
	| lista expr '\n'  { printf("\t%.8g\n", $2); }
	| lista error '\n' { yyerrok; }		/* ❶ */
	;
expr:	  NUMERO	{ $$ = $1; }
	| VAR		{ $$ = mem[$1]; }	/* ❷ */
	| VAR '=' expr	{ $$ = mem[$1] = $3; }  /* ❸ */
	| '-' expr %prec NEGATIVO { $$ = -$2; }
	| expr '+' expr	{ $$ = $1 + $3; }
	| expr '-' expr	{ $$ = $1 - $3; }
	| expr '*' expr	{ $$ = $1 * $3; }
	| expr '/' expr	{			/* ❹ */
		if ($3 == 0.0)
			recuperar("division by zero");
		$$ = $1 / $3; }
	| '(' expr ')'	{ $$ = $2; }
	;
%%
	/* fim da gramática */
```

1. Esta nova regra usa a palavra `error` que tem um significado especial em uma gramática **yacc**. Ela serve para indicar que estados de erro poderão acontecer e serão tratados, em vez de encerrar o programa.
2. Quando a expressão se reduz a uma variável (que é um índice `int`), seu valor é obtido acessando a posição correspondente em `mem[]`.
3. Em uma expressão de atribuição, o efeito é colocar o valor da `expr` à direita na posição de `mem[]` que corresponde ao índice da variável. 
4. A ação associada à divisão agora faz um teste: se o denominador tem valor 0.0, o *parser* desvia para a função `recuperar` com uma mensagem de divisão por zero. Isso evita os resultados `inf` e `-inf` que tínhamos em `hoc1b`.


### Mudanças no epílogo

O código em C após o fim da gramática tem várias novidades. Primeiro, as variáveis globais e a função principal:

```c
char	*nome_prog;		 /* para mensagens de erro */
int	num_linha = 1;
jmp_buf	inicio;			 /* ❶ dados para longjmp */

int main(int argc, char* argv[]) /* hoc2 */
{
	void tratar_exc_pf();

	nome_prog = argv[0];

	setjmp(inicio);			/* ❷ */
	signal(SIGFPE, tratar_exc_pf);	/* ❸ */

	yyparse();
}
```

1. A variável `inicio` armazenará uma *struct* com dados para o funcionamento das chamadas `setjmp` e `longjmp` que servirão para reiniciar o interpretador em caso de erro ou exceção.
2. A chamada `setjmp(inicio)` armazena informações sobre este ponto do programa para permitir o desvio para este local quando `longjmp` for invocada na função `recuperar`, definida mais abaixo. Na prática, `setjmp` marca um alvo, ou destino, para um desvio de execução.
3. Essa chamada registra a função `tratar_exc_pf` como *handler* (tratadora) para quando o sistema operacional levantar um sinal `SIGFPE` que é uma exceção de ponto flutuante usada para indicar *overflow* ou outros erros.

> ✋ Não consegui reproduzir a exceção de *overflow* citada no texto original de [UPE](https://en.wikipedia.org/wiki/The_Unix_Programming_Environment). Quando digito `1e300*1e300` em `hoc2` aparece o resultado `inf` — o ∞ da norma [IEEE 754-1985](https://en.wikipedia.org/wiki/IEEE_754-1985#Positive_and_negative_infinity). Se você sabe como provocar uma exceção de ponto flutuante em `hoc2`, por gentileza faça um *pull-request*, pois assim poderemos demonstrar ou uso de `signal` e acionar a função `tratar_exc_pf`.

A função de análise léxica ganha mudanças no acesso à variável `yylval`, e mais algumas linhas para tratar um *token* de variável:

```c
int yylex(void)			 /* hoc2 */
{
	int c;

	while ((c=getchar()) == ' ' || c == '\t')
		;
	if (c == EOF)
		return 0;
	if (c == '.' || isdigit(c)) {		/* número */
		ungetc(c, stdin);
		scanf("%lf", &yylval.val);	/* ❶ */
		return NUMERO;
	}
	if (islower(c)) {			/* ❷ */	
		yylval.indice = c - 'a';  	/* só ASCII */
		return VAR;			/* ❸ */
	}
	if (c == '\n')
		num_linha++;
	return c;
}
```

1. Agora `yyval` não é mais um valor simples, e sim uma união de dois membros. Aqui salvamos o valor numérico lido por `scanf` no endereço do membro `yylval.val`.
2. Esse novo `if` testa se `c` é o código ASCII de uma letra minúscula. Em caso afirmativo, `yyval.indice` recebe o valor de `c` menos `'a'` (o código ASCII do "a" minúsculo). Por exemplo, o índice da variável `'a'` será 0, `'b'` será 1, etc.
3. Depois de armazenar o índice em `yylval`, devolvemos para o parser a indicação de que um *token* da categoria `VAR`.

E finalmente, temos as funções de tratamento de erros:

```c
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
```


* **`yyerror`**, que é chamada pelo *parser* gerado por **yacc**, agora usa nossa função `aviso`. 
* **`aviso`** apenas exibe uma mensagem em `stderr`, informando a linha onde o erro foi detectado.
* **`recuperar`** exibe um aviso, e desvia a execução para o ponto marcado pela chamada `setjmp(inicio)` na função `main`.
* **`tratar_exc_pf`** usa `recuperar` para avisar que houve uma exceção de ponto flutuante.

> ✋ `tratar_exc_pf` é a função que não consegui testar, porque ao testar `hoc2` eu não consegui gerar uma exceção que produza o sinal `SIGFPE`.

## Construir e testar

Use `make` para gerar o código em C e compilar:

```bash
$ make hoc2
yacc  hoc2.y 
mv -f y.tab.c hoc2.c
cc    -c -o hoc2.o hoc2.c
cc   hoc2.o   -o hoc2
rm hoc2.o hoc2.c
```

Para testar, use o arquivo `testes.hoc`. Este é o resultado esperado:

```bash
$ ./hoc2 < testes.hoc 
	4
	-7
	14
	0
	37.777778
	100
./hoc2: division by zero near line 7
	100
```

O arquivo `testes.hoc` agora tem este conteúdo:

```
a = 2 + 2
-3 - a
x = y = z = 2 + 3 * 4
-x - y * 2 + z * 3
c = (100 - 32) * 5 / 9
f = 32 + c * 9 / 5
1/0
f
```

Além de exercitar as variáveis e expressões de atribuição, na penúltima linha há uma divisão por zero. Isso demonstra que o interpretador exibe a mensagem corretamente, e se recupera, inclusive mantendo o valor da variável f que é o resultado da última linha: 100.

----

Voltar para o [índice de páginas](index.md#índice-de-páginas).
