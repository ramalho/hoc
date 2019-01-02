# Construção da linguagem *hoc*

* [Porque isso é interessante](#porque-isso-é-interessante)
* [Características de `hoc`](#características-de-hoc)
* [Organização deste repositório](#organização-deste-repositório)
* [Índice de páginas](#índice-de-páginas)

## Porque isso é interessante

No capítulo 8 do livro [The Unix Programming Environment](https://en.wikipedia.org/wiki/The_Unix_Programming_Environment) (UPE), Brian W. Kernighan e Rob Pike mostram como construir uma uma pequena linguagem [Turing-completa](https://pt.wikipedia.org/wiki/Turing_completude) chamada `hoc` (higher-order calculator).

Em [UPE](https://en.wikipedia.org/wiki/), `hoc` serve para apresentar as seguintes ferramentas do ambiente UNIX:

* [**yacc**](https://pt.wikipedia.org/wiki/Yacc): um gerador de analisador sintático, ou seja, um programa que gera o código-fonte de um *parser*, a partir da descrição formal de uma linguagem;
* [**lex**](https://pt.wikipedia.org/wiki/Lex): um gerador de analisador léxico, muitas vezes usado em conjunto com **yacc**;
* [**make**](https://pt.wikipedia.org/wiki/Make): um utilitário que automatiza tarefas na construção de programas.

Estudar a implementação de `hoc` em C é uma boa maneira de aprender como funciona um interpretador por dentro. Um conhecimento básico de C é suficiente para acompanhar este exemplo.

> 🗒 Desde que o GNU Linux substituiu no mercado os UNIX proprietários, **yacc** e **lex** também foram superados por ferramentas livres mais modernas: [**GNU bison**](https://pt.wikipedia.org/wiki/GNU_bison) e [**flex**](https://en.wikipedia.org/wiki/Flex_(lexical_analyser_generator)). Em muitos ambientes, ao instalar **bison** e **flex** você ganha também atalhos chamados `yacc` e `lex` que emulam o funcionamento das ferramentas antigas.

### Minha motivação

Decidi estudar este exemplo para aprender o básico de **lex** e **yacc**, antes de estudar o pacote [**SLY**](https://github.com/dabeaz/sly) de David Beazley, que implementa funcionalidade semelhante em Python, usando metaprogramação em vez de geração de código. Meu plano é usar **SLY** na [Oficina de Linguagens de Programação](https://garoa.net.br/wiki/Turing_Clube/Oficina_de_Linguagens_de_Programa%C3%A7%C3%A3o) do Garoa Hacker Clube. Como achei o exemplo `hoc` muito interessante, e não encontrei o livro [UPE](https://en.wikipedia.org/wiki/The_Unix_Programming_Environment) em português, resolvi contribuir para a nossa cultura de computação apresentando esse exemplo em nosso idioma.

## Características de *hoc*

* só um tipo de dado: números de ponto flutuante;
* interpretador interativo: pode ser usado como um [REPL](https://es.wikipedia.org/wiki/REPL) ou lendo arquivos-fonte;
* operadores aritméticos e funções pré-definidas `sqrt`, `log`, `sin` etc.;
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

> 🗒 A distinção entre procedimentos e funções é natural para quem já programou em Pascal ou Delphi. Muitas linguagens modernas não separam os dois conceitos claramente. Por exemplo, em Python não há procedimentos, há apenas funções que não devolvem nenhum valor explicitamente mas, implicitamente, devolvem o valor `None`, que a gente ignora.

## Organização deste repositório

O diretório `/complete` é um fork do repositório [richardfearn/hoc](https://github.com/richardfearn/hoc) no GitHub. Richard Fearn modificou código original de 1984 para compilar e executar em um sistema GNU/Linux em 2012. Em 1/jan/2019, não está acessível o site onde o código original foi publicado ([http://netlib.bell-labs.com/cm/cs/upe/](http://netlib.bell-labs.com/cm/cs/upe/)).

> 🗒 Você pode compilar o programa rodando `make` no diretório `/complete`, desde que tenha instalado as ferramentas de desenvolvimento do seu sistema, incluindo **bison** e **flex**.

O diretório `/docs` contém esta página que você está lendo, entre outras.

Os demais diretórios contém as 6 etapas da construção de `hoc`, como descrito em [The Unix Programming Environment](https://en.wikipedia.org/wiki/The_Unix_Programming_Environment).

## Índice de páginas

* [**Etapa 1**](etapa1.md): calculadora aritmética, expressões computadas imediatamente.
* **Etapa 2**: variáveis de `a` a `z`.
* **Etapa 3**: variáveis com nomes mais longos, funções e constantes pré-definidas (`sin`, `PI`, etc.).
* **Etapa 4**: refatoração implementando linguagem intermediária baseada em pilha.
* **Etapa 5**: controle de fluxo, blocos delimitados por `{}` e operadores relacionais (`>`, `>=`, etc.).
* **Etapa 6**: comandos `func` e `proc` para definir funções e procedimentos recursivos; entrada e saída de *strings* além de números.

*— [LR](https://twitter.com/ramalhoorg)*
