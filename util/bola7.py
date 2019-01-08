#!/usr/bin/env python3

import re
import sys
import shutil

TAG_NUMERO = re.compile(r'<([#!\d]\d?)>')

BOLA_1 = 0x2776

class Adornador:
    def __init__(self):
        self.proximo = 1

    def __call__(self, texto):
        tags = TAG_NUMERO.findall(texto)
        for tag in tags:
            if tag == '!':
                numero = 1
                self.proximo = 2
            elif tag == '#':
                numero = self.proximo
                self.proximo += 1
            else:
                numero = int(tag)
            bola = chr(BOLA_1 + numero - 1)
            texto = texto.replace(f'<{tag}>', bola, 1)
        return texto


if __name__ == '__main__':
    nome_arq = sys.argv[1]
    shutil.copyfile(nome_arq, nome_arq+'.BKP')
    adornar = Adornador()
    with open(nome_arq) as arq:
        entrada = arq.read()
    with open(nome_arq, 'wt') as arq:
        arq.write(adornar(entrada))
