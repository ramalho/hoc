# *hoc1b*: sinal negativo e *make*

Esta página descreve os arquivos do diretório [etapa1b/](https://github.com/ramalho/hoc/tree/master/etapa1b).

* [Explicação do programa](#explicação-do-programa)
* [Construir e testar](#construir-e-testar)
* [Introdução a *make*](#introdução-a-make)

## Explicação do programa

Uma das vantagens de usar o **yacc/bison** é que a definição de alto nível da gramática facilita mudar ou acrescentar novos recursos à linguagem que estamos desenvolvendo.

Para incorporar o sinal de número negativo, será preciso apenas mais duas linhas de código. O código-fonte completo está em [`hoc1b.y`](https://github.com/ramalho/hoc/blob/master/etapa1b/hoc1b.y) ([link](https://github.com/ramalho/hoc/blob/master/etapa1b/hoc1b.y)).

### Mudanças na gramática

A primeira mudança é acresecentar a declaração do *token* `NEGATIVO` que vai representar o operador também conhecido como *unary minus* (menos unário).

```c
%token	NUMERO
%left	'+' '-'  /* associatividade esquerda */
%left	'*' '/'  /* associatividade esquerda, maior precedência */
%left	NEGATIVO /* hoc1b */
```

Colocar `NEGATIVO` por último dá a precedência mais alta para esse sinal.

A próxima mudança é incluir uma nova forma nas regras sintáticas de `expr`:

```c
expr:	  NUMERO { $$ = $1; }
	| '-' expr %prec NEGATIVO { $$ = -$2; }	/* hoc1b */ 
	| expr '+' expr	{ $$ = $1 + $3; }
	| expr '-' expr	{ $$ = $1 - $3; }
	/* etc... */
```

A 2ª linha estabelece que a forma `'-' expr` terá precedência alta (`%prec NEGATIVO`), e seu valor será o negativo da expressão (`$$ = -$2`). A forma da 4ª linha (`expr '-' expr`) continuará sendo usada quando o sinal `'-'` aparecer entre duas expressões.

## Construir e testar

Use `yacc` para gerar o código em C, compile, e teste:

```bash
$ yacc hoc1b.y
$ cc y.tab.c -o hoc1b
$ ./hoc1b < testes.hoc
	4
	-7
	37.777778
	100.4
```

Para testar o sinal de negativo, incluí a linha `-3 - 4` em `testes.hoc`. Por isso, o resultado -7.

Agora vamos ver como automatizar a construção do programa.

## Introdução a *make*

Toda vez que fazemos uma alteração em um arquivo `.y`, temos que rodar `yacc` e depois `cc`. É inconveniente, mas o pior fazer é uma mudança no arquivo `.y`, esquecer um desses passos e ficar testando um executável que não foi atualizado, como já aconteceu comigo. 

É fácil criar um *script* no shell para rodar esses comandos, mas é melhor usar a ferramenta `make`, pois ela foi projetada para construir programas, processa arquivos `.y` automaticamente, e evita realizar passos desnecessários — por exemplo, não executa o compilador se o arquivo-fonte `hoc.y` não foi tocado.

Se você executar o comando `make hoc1b` no diretório `etapa1b/`, verá esta saída:

```bash
$ make hoc1b
yacc  hoc1b.y 
mv -f y.tab.c hoc1b.c
cc    -c -o hoc1b.o hoc1b.c
cc   hoc1b.o   -o hoc1b
rm hoc1b.o hoc1b.c
```

Observe os comandos executados por `make`: 

1. `yacc` para processar `hoc1b.y` e gerar `y.tab.c`; 
2. `mv` para renomear `y.tab.c` para `hoc1b.c`;
3. `cc` para compilar `hoc1b.c` e gerar o arquivo-objeto `hoc1b.o`;
4. `cc` para montar o executável `hoc1b` a partir de `hoc1b.o`;
5. `rm` para apagar `hob1b.o` e `hob1b.c`.

Se você rodar `make hoc1b` de novo, `make` não faz nada além de avisar que o executável `hoc1b` já está atualizado:

```bash
$ make hoc1b
make: 'hoc1b' is up to date.
```

Toda essa lógica e muito mais está embutida no `make`.

Veremos depois como criar um `Makefile` para configurar as ações do `make`.

----

Voltar para o [índice de páginas](index.md#índice-de-páginas).
