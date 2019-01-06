# *hoc1*: calculadora de quatro operações

Veja o [código desta etapa explicado](https://ramalho.github.io/hoc/etapa1).

## Como compilar

Use `make` para gerar o código do programa em C a partir do arquivo `hoc1b.y`, e compilar o resultado em um executável.

Resultado em um	Ubuntu 18.04.1 LTS:

```bash
$ make hoc1b
yacc  hoc1b.y 
mv -f y.tab.c hoc1b.c
cc    -c -o hoc1b.o hoc1b.c
cc   hoc1b.o   -o hoc1b
rm hoc1b.o hoc1b.c
```

## Como testar

O arquivo `testes.hoc` tem alguns casos de testes básicos.

```
2 + 2
-3 -4 
(100 - 32) * 5 / 9
32 + 38 * 9 / 5
```

Forneça `testes.hoc` para `hoc1b` via entrada padrão, usando `<`. Esse é resultado esperado:

```
$ ./hoc1b < testes.hoc
	4
	-7
	37.777778
	100.4
```

Para entender o código de `hoc1b.y`, leia a [explicação](https://ramalho.github.io/hoc/etapa1b).
