# *hoc1*: calculadora de quatro operações

Veja o [código desta etapa explicado](https://ramalho.github.io/hoc/etapa1).

## Como compilar

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
(vários outros avisos...)
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

