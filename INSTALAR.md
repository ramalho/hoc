# Como instalar as ferramentas

Para seguir este tutorial, você precisa instalar o utilitário **yacc**, além das ferramentas usuais de desenvolvimento, como *cc* e *make*. Na etapa 3, há um exemplo de uso de **lex**, mas as outras etapas não usam esta ferramenta.

> 🗒  **yacc** e **lex** são ferramentas antigas que foram superadas por programas compatíveis mais modernos, com mais recursos e licenças livres.  Para substituir **yacc**, temos **GNU bison** e **byacc** (*Berkeley yacc*). 
O substituto moderno de **lex** chama-se **flex**.

A seguir, instruções para instalar esses pacotes em diferentes ambientes.

## Fedora release 29

No *Fedora*, instalei os pacotes **byacc** e **flex** para obter os comandos `yacc` e `lex`:

```bash
$ sudo dnf install byacc flex
...
Installed:
  byacc-1.9.20170709-6.fc29.x86_64    flex-2.6.1-10.fc29.x86_64   m4-1.4.18-9.fc29.x86_64
$ yacc -V
yacc - 1.9 20170709
$ lex -V
lex 2.6.1
```
