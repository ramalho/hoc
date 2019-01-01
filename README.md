# Linguagem `hoc`

* [Porque isso é interessante](#Porque-isso-é-interessante)
* [Sobre este repositório](#Sobre-este-repositório)
* [Características de `hoc`](#Características-de-hoc)

## Porque isso é interessante

`hoc` é uma pequena linguagem [Turing-completa](https://pt.wikipedia.org/wiki/Turing_completude) apresentada no capítulo 8 do livro [The Unix Programming Environment](https://en.wikipedia.org/wiki/) de Brian W. Kernighan e Rob Pike (Prentice Hall, 1984).

Estudar a implementação de `hoc` em C é uma boa maneira de aprender como funciona um interpretador por dentro. Um conhecimento básico de C é suficiente para acompanhar este exemplo.

No livro [UPE](https://en.wikipedia.org/wiki/), `hoc` serve para apresentar as seguintes ferramentas do ambiente UNIX:

* [**yacc**](https://pt.wikipedia.org/wiki/Yacc): um gerador de analisador sintático, ou seja, um programa que gera o código-fonte de um *parser* a partir da descrição formal de uma linguagem;
* [**lex**](https://pt.wikipedia.org/wiki/Lex): um gerador de analisador léxico, muitas vezes usado em conjunto com **yacc**;
* [**make**](https://pt.wikipedia.org/wiki/Make): um utilitário que automatiza tarefas na construção de programas.

> Desde que o GNU Linux substituiu no mercado os UNIX proprietários, **yacc** e **lex** também foram superados por ferramentas livres mais modernas: [**GNU bison**](https://pt.wikipedia.org/wiki/GNU_bison) e [**flex**](https://en.wikipedia.org/wiki/Flex_(lexical_analyser_generator)). Em muitos ambientes, ao instalar **bison** e **flex** você ganha também atalhos chamados `yacc` e `lex` que emulam o funcionamento das ferramentas antigas.

## Sobre este repositório

O diretório `/complete` é um fork do repositório [richardfearn/hoc](https://github.com/richardfearn/hoc) no GitHub. Richard Fearn obteve o código original em um site que não está disponível em 1/jan/2019 (http://netlib.bell-labs.com/cm/cs/upe/), e o modificou para que fosse possível compilar e executar em um sistema GNU/Linux.

> Você pode compilar o programa rodando `make` no diretório `/complete`, desde que tenha instalado as ferramentas de desenvolvimento do seu sistema, incluindo **bison** e **flex**.

Os demais diretórios contém as 6 etapas da construção de `hoc`, como descrito em [The Unix Programming Environment](https://en.wikipedia.org/wiki/):

1. calculadora aritmética, expressões computadas imediatamente;
2. variáveis de `a` a `z`;
3. variáveis com nomes mais longos, funções e constantes pré-definidas (`sin`, `PI`, etc.);
4. refatoração implementando linguagem intermediária baseada em pilha;
5. controle de fluxo, blocos delimitados por `{}` e operadores relacionais (`>`, `>=`, etc.).
6. comandos `func` e `proc` para definir funções e procedimentos recursivos; entrada e saída de *strings* além de números.

## Características de `hoc`

* apenas um tipo de dado: números de ponto flutuante;
* interpretador interativo: pode ser usado como um [REPL](https://es.wikipedia.org/wiki/REPL) ou lendo arquivos-fonte;
* operadores aritméticos e funções pré-definidas (`sqrt`, `log`, `sin` etc.);
* constantes pré-definidas `PI`, `E`, `PHI` etc.;
* comandos de controle de fluxo: `if-else`, `while`;
* funções e procedimentos definidos pelo usuário, com recursividade.

### Exemplo

Exibir números da sequência de Fibonacci menores do que 1000:

```
$ ./hoc fib.hoc 
1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987
```

Código-fonte de `fib.hoc`:

```
proc fib() {
	a = 0
	b = 1
	while (b < $1) {
		print b
		c = b
		b = a+b
		a = c
	}
	print "\n"
}
fib(1000)
```

No código acima, a variável `$1` é o primeiro argumento passado para   `fib`. A palavra reservada `proc` serve para declarar um procedimento: uma sub-rotina que não devolve um valor, assim como um médodo do tipo `void` em Java. Para declarar uma função que devolve um número em `hoc`, usa-se  `func`.

> A distinção entre procedimentos e funções é natural para quem já programou em Pascal ou Delphi. Muitas linguagens modernas não separam os dois conceitos claramente. Por exemplo, em Python não há procedimentos, há apenas funções que não devolvem nenhum valor explicitamente (implicitamente, devolvem o valor `None`).
