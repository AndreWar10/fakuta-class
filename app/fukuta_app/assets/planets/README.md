# Imagens dos Planetas

Esta pasta deve conter as imagens dos planetas do sistema solar.

## Arquivos Necessários:

- `sun.png` - Imagem do Sol
- `mercury.png` - Imagem de Mercúrio  
- `venus.png` - Imagem de Vênus
- `earth.png` - Imagem da Terra
- `mars.png` - Imagem de Marte
- `jupiter.png` - Imagem de Júpiter
- `saturn.png` - Imagem de Saturno
- `uranus.png` - Imagem de Urano
- `neptune.png` - Imagem de Netuno
- `pluto.png` - Imagem de Plutão

## Como Adicionar:

1. Baixe as imagens do repositório: https://github.com/AndreWar10/tg-solar-system-app/tree/master/space_app/assets/planets
2. Coloque as imagens nesta pasta (`assets/planets/`)
3. Certifique-se que os nomes dos arquivos estão exatamente como listados acima
4. Execute `flutter pub get` para atualizar os assets

## Formato Recomendado:

- **Resolução**: 200x200 pixels ou maior
- **Formato**: PNG com fundo transparente
- **Qualidade**: Alta resolução para melhor visualização

## Fallback:

Se uma imagem não for encontrada, o app usará:
1. Primeiro: Imagem local do asset
2. Segundo: Imagem da API (URL)
3. Terceiro: Ícone padrão (fallback)
