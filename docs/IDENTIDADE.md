# Identidade visual do NullyzOS

Aprovada em 17/11/2026 (issue #1). Valores exatos em [`branding/tokens.json`](../branding/tokens.json): shell, tema do KDE, SDDM, GTK/Qt e terminal geram a partir dele, nunca com cor escrita à mão.

## Símbolo

Um **N de 7×7 pixels**: hastes de 2 pixels e a diagonal em degraus. Por ser feito de quadrados, escala do boot ao terminal sem perder a forma.

```
████      ████
██████    ████
████████  ████
████  ████████
████    ██████
████      ████
████      ████
```

| Arquivo | Uso |
|---|---|
| `branding/logo/nullyz-escuro.svg` | fundo escuro (padrão), pixels com canto leve |
| `branding/logo/nullyz-claro.svg` | fundo claro |
| `branding/logo/nullyz-mono.svg` | uma cor (`currentColor`): ícone simbólico |
| `branding/logo/nullyz-pixel.svg` | pixel exato 7×7 (`crispEdges`): tamanhos pequenos, Plymouth |
| `branding/logo/nullyz-terminal.txt` | o N em blocos █ para o fetch (cada pixel = 2 blocos) |

Nome: **NULLYZ OS** em letras de pixel 5×7 quando acompanha o símbolo, com **YZ OS** no destaque.

## Boot e boas-vindas

**Boot (Plymouth), toda vez, uns 4 s:**
1. Os pixels do N acendem em diagonal, cada um com overshoot. No fim o N dá uma leve amassada e volta (squash and stretch).
2. **NULL** se escreve letra a letra, linha a linha, como um scanline.
3. **YZ** e depois **OS** entram girando (um giro e meio), passam um pouco do ponto e assentam.
4. Três pixels pulsam enquanto carrega.

**Primeiro boot (boas-vindas), uma vez, uns 12 s:**
1. **"Seja bem-vindo(a) ao NullyzOS"** em mono. Cada letra passa por um símbolo de código (`0 1 # { } < >`) e assenta saindo do desfoque; NullyzOS em destaque. Depois o cursor pisca.
2. Embaixo, com fade e desfoque, entrando e saindo: *"É preciso ter o caos dentro de si para dar à luz uma estrela dançante."* (Friedrich Nietzsche, *Assim falou Zaratustra*; tradução nossa de obra em domínio público).
3. Botão **Começar**, que abre as boas-vindas.

Com "reduzir movimento" ligado, tudo aparece pronto, sem animação.

## Cores por papéis

Quase tudo é cinza; o destaque marca só foco, seleção e o que está ativo. Todo texto passa 4,5:1 no fundo onde aparece. Destaques oferecidos: violeta (padrão), azul, ciano e coral.

## Vidro (cinco camadas)

1. **Desfoque** de 24 px com saturação 1,6, só nos painéis do sistema, nunca nas janelas de app.
2. **Tinta** do papel `vidro` (55% no escuro, 62% no claro), que segura o contraste do texto.
3. **Borda de luz** de 1 px, branca a 22%.
4. **Brilho no topo**: um fio de luz interno na borda de cima.
5. **Sombra macia**, larga e fraca.

**Modo leve** (VM, modo jogo): sem desfoque e sem sombra; o vidro vira superfície sólida a 94% com a mesma borda.

## Formas, tipo e movimento

- **Cantos:**

  | Elemento | Raio |
  |---|---|
  | botão | 8 |
  | campo | 14 |
  | cartão | 20 |
  | painel | 28 |
  | ícone de app | 38 |

- **Fonte:** Geist e Geist Mono (SIL OFL 1.1). Escala de 34/22/15/13 px.
- **Movimento:**
  - Durações: 160 ms (hover, botões), 260 ms (painéis, mola curta), 420 ms (janelas e workspaces).
  - Entrada com antecipação e overshoot leve. A saída é mais rápida que a entrada e nada pisca.

## O desktop Nullyz

- Barra de menus de vidro em cima: símbolo, nome do app, menus, status e relógio. No Hyprland mostra também os workspaces e o modo (tiling/flutuante); no KDE é o menu global do Plasma.
- Dock de vidro embaixo. No tiling do Hyprland ele se esconde e aparece ao encostar na borda.
- Botões de janela próprios: monocromáticos e redondos. Nada de bolinhas coloridas.
- Busca (Super+Espaço): apps, ações, ajustes e rices no mesmo lugar.
- Central de controle: botões de rede, Bluetooth, não perturbe e modo; brilho e volume; cartão do visual atual com atalho para a loja de rices.

## Tipos de costumização

| Vale em | Opções |
|---|---|
| os dois | modo (claro/escuro/auto), cor de destaque, vidro (leve/normal/forte), cantos, animações, fonte e ícones, barra de menus, dock |
| só Hyprland | modo de janela (tiling/flutuante), espaço entre janelas |
| só KDE | decoração das janelas (Nullyz/Breeze), efeitos do KWin |

Os ajustes valem para o visual Nullyz; um rice da comunidade traz os dele. Cada desktop mostra só as opções que valem nele.

## Limites

Estilo inspirado no macOS Tahoe, **sem nada da Apple**: nenhum ícone, fonte, som, wallpaper, nome ou logo. Ícones de app do dock na prancha são esboço; o pacote de ícones próprio tem issue separada.

Pranchas de referência: artifact privado do dono do projeto (Identidade visual do NullyzOS).
