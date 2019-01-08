from pytest import mark

from bola7 import Adorno

@mark.parametrize("entra, esperado", [
    ('<1>', '❶' ),
    ('<2>', '❷' ),
    ('Abc <2> def <1>.', 'Abc ❷ def ❶.' ),
    ('Abc <#> def <#>.', 'Abc ❶ def ❷.' ),
    ('Abc <#>\ndef <#>.', 'Abc ❶\ndef ❷.' ),
    ('<#> <#> <!> <#>', '❶ ❷ ❶ ❷' ),
])
def test_decorar(entra, esperado):
    adorno = Adorno()
    res = adorno(entra)
    assert esperado == res
