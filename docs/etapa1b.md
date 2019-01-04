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

Toda vez que fazemos uma alteração em um arquivo `.y`, temos que rodar `yacc` e depois `cc`. É inconveniente, mas o pior é esquecer um desses passos, como já aconteceu comigo. Ao preparar a etapa 1, houve um momento em que eu editava `hoc1.y` e repetia o comando `yacc hoc1.y`, mas o comportamento do executável continuava igual. Perdi alguns minutos até perceber que eu estava testando uma versão velha do executável porque estava esquecendo de compilar o `y.tab.c`  gerado! E se você esquecer de rodar `yacc` antes do `cc`, terá o mesmo problema: não verá mudança alguma no executável, pois estará apenas compilando uma versão velha do `y.tab.c`.

É fácil criar um *script* no shell para rodar esses comandos, mas é bem melhor usar a ferramenta `make`, pois ela foi projetada para construir programas, processa arquivos `.y` automaticamente, e evita realizar passos desnecessários — por exemplo, não executa o compilador se o arquivo-fonte `hoc.y` não foi tocado.

Para começar a usar `make`, você precisa criar um arquivo chamado `Makefile`. Para essa etapa, o `Makefile` é bem simples:

```make
hoc1b:	hoc1b.o
	cc hoc1b.o -o hoc1b
```

Nesse `Makefile`, está definido que `hoc1b` depende de `hoc1b.o`, que deve ser compilado com `cc`. Não é preciso citar o arquivo `hoc1b.y`, porque `make` é programado para processar arquivos `.y` com `yacc`.

Uma vez criado o `Makefile`, se você executar o comando `make` no diretório `etapa1b/`, verá esta saída:

```bash
$ make
yacc  hoc1b.y 
mv -f y.tab.c hoc1b.c
cc    -c -o hoc1b.o hoc1b.c
cc hoc1b.o -o hoc1b
rm hoc1b.c
```

Observe os comandos executados por `make`: 

1. `yacc` processa `hoc1b.y`, gerando `y.tab.c`; 
2. `mv` renomeia `y.tab.c` para `hoc1b.c`;
3. `cc` compila `hoc1b.c`, gerando o arquivo-objeto `hoc1b.o`;
4. `cc` monta o executável `hoc1b`;
5. `rm` apaga `hob1b.c`.

O resultado é a criação dos arquivos `hoc1b.o` e `hoc1b`:

```bash
$ ls
hoc1b  hoc1b.o  hoc1b.y  Makefile  README.md  testes.hoc
```

Depois disso, se você executar `make` novamente, ele não faz nada além de avisar que `hoc1b` já é a versão mais atual:

```bash
$ make
make: 'hoc1b' is up to date.
```

Tudo isso com um `Makefile` de apenas duas linhas e 36 bytes!

> 🗒 No livro [UPE](https://en.wikipedia.org/wiki/The_Unix_Programming_Environment), o nome do `makefile` é escrito assim, em minúsculas. Atualmente a convenção é usar `M` maiúsculo em `Makefile`, conforme o [manual do GNU make](https://www.gnu.org/software/make/manual/html_node/Makefile-Names.html). O motivo é dar mais destaque a este arquivo que é o mais útil para uma pessoa interessada em compilar um programa.

----

Voltar para o [índice de páginas](index.md#índice-de-páginas).
