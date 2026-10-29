# U.A. Startup — pacote experimental para MDPro4

**ID da carta:** `210000001`  
**Tipo:** Magia Normal

## Efeitos planejados

1. Adicione 1 monstro "U.A." do Deck à mão. Só pode ativar 1 "U.A. Startup" por turno.
2. Se o oponente Invocar por Invocação-Especial um ou mais monstros: você pode banir esta carta do Cemitério como custo; Invoque por Invocação-Especial 1 monstro "U.A." do seu Cemitério.

O segundo efeito é opcional e pode ser usado em cada evento válido de Invocação-Especial do oponente, desde que a carta já esteja no Cemitério e haja alvo e zona disponíveis.

## Arquivos neste repositório

- `script/c210000001.lua`: script Lua dos efeitos
- `test-strings.conf`: textos de teste
- `corres_srv.ini`: configuração de teste
- `pack/U.A. Startup Demo.ydk`: deck de demonstração

## Estado e limitações

Este é um **protótipo**. O script e a integração ainda precisam ser testados no MDPro4/ocgcore. Os arquivos binários originais da base de cartas (`custom.cdb`, `test-release.cdb`) e a arte PNG não foram enviados nesta primeira publicação; portanto, este repositório ainda não é um pacote instalável completo.

A arte prevista é provisória e original, não oficial de Yu-Gi-Oh!. O setcode usado no script é `0x7a`.

## Instalação

Ainda não há um pacote completo pronto para importar. Consulte a documentação da versão do MDPro4 utilizada antes de instalar scripts ou bases personalizadas.
