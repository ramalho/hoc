import re

TAG_NUMERO = re.compile(r'<([#!\d]\d?)>')

BOLA_1 = 0x2776

class Adorno:
    def __init__(self):
        self.contador = (n for n in range(1, 10))

    def __call__(self, texto):
        tags = TAG_NUMERO.findall(texto)
        for tag in tags:
            if tag == '#':
                numero = next(self.contador)
            elif tag == '!':
                self.__init__()
                numero = next(self.contador)
            else:
                numero = int(tag)
            bola = chr(BOLA_1 + numero - 1)
            texto = texto.replace(f'<{tag}>', bola, 1)
        return texto


if __name__ == '__main__':
    import sys
    with open(sys.argv[1]) as entrada:
        adorno = Adorno()
        print(adorno(entrada.read()))
