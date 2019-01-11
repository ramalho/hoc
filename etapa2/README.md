# *hoc2*: calculadora com variáveis

Veja o [código desta etapa explicado](https://ramalho.github.io/hoc/etapa2).

## Como compilar

Use `make` para gerar o código do programa em C a partir do arquivo `hoc2.y`, e compilar o resultado em um executável:

```bash
$ make hoc2
yacc  hoc2.y 
mv -f y.tab.c hoc2.c
cc    -c -o hoc2.o hoc2.c
cc   hoc2.o   -o hoc2
rm hoc2.o hoc2.c
```


## Como testar

O arquivo `testes.hoc` tem alguns casos de testes básicos.

Forneça `testes.hoc` para `hoc1b` via entrada padrão, usando `<`. Esse é resultado esperado — inclusive a divisão por zero, que é proposital:

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

Para entender o código de `hoc2.y`, leia a [explicação](https://ramalho.github.io/hoc/etapa2).
