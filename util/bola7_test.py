from pytest import mark

from bola7 import Adornador

@mark.parametrize("entra, esperado", [
    ('<1>', '❶' ),
    ('<2>', '❷' ),
    ('Abc <2> def <1>.', 'Abc ❷ def ❶.' ),
    ('Abc <#> def <#>.', 'Abc ❶ def ❷.' ),
    ('Abc <#>\ndef <#>.', 'Abc ❶\ndef ❷.' ),
    ('<#> <#> <!> <#>', '❶ ❷ ❶ ❷' ),
])
def test_adornar(entra, esperado):
    adornar = Adornador()
    res = adornar(entra)
    assert esperado == res
