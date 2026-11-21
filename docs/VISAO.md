# Visão do NullyzOS

> Um sistema baseado em Arch, com cara própria, que deixa você escolher o desktop e o visual já na instalação.

## A ideia em uma tela

```
Instalador gráfico do NullyzOS
 ├─ Hyprland
 │   ├─ Nullyz            ← padrão: o desktop do NullyzOS
 │   └─ Rices da comunidade (Serpantinum, illogical-impulse, Caelestia…)
 └─ KDE Plasma
     ├─ Nullyz            ← padrão: o mesmo visual, feito para o KDE
     └─ Rices de KDE (temas globais da comunidade)
```

- **O NullyzOS é o sistema.** Em qualquer desktop ele já vem com a cara dele: shell, tema, ícones, sons, tela de login, boas-vindas e configurações.
- **Os rices são opções por cima.** Cada desktop só mostra os rices que funcionam nele: rice de Hyprland não aparece para quem escolheu KDE, e o contrário também.
- **Trocar depois é seguro.** O rice pode ser trocado depois da instalação, pela loja de rices, e qualquer troca pode ser desfeita.

## Princípios

1. **Leve, moderno e minimalista.** Cada recurso tem custo medido (RAM, CPU, tempo de boot) e meta por versão.
2. **Seguro por padrão.**
   - Sem AUR e sem `curl | bash`.
   - Tudo vem dos repositórios oficiais do Arch ou do repositório `nullyz`, assinado.
   - O que falta nós empacotamos no repositório assinado do projeto.
3. **Crédito a quem fez.**
   - Rice de terceiro entra com autor, licença e link para o original, mostrados na instalação e na loja.
   - Avisamos o autor antes de publicar a receita.
   - Nada de terceiro entra sem licença verificada.
4. **Visual próprio.**
   - O estilo é inspirado no macOS Tahoe: vidro translúcido, cantos bem arredondados, barra de menus em cima e dock de vidro.
   - Não usamos ícones, fontes, wallpapers, sons, nomes nem logos da Apple. Tudo é desenhado do zero ou tem licença livre.
5. **Português primeiro.** Interface, documentação e commits em pt-BR; inglês como segunda língua.

## As peças

| Pasta | O que é |
|---|---|
| `iso/` | Perfil archiso: a ISO live que roda o instalador. |
| `installer/` | Assistente TUI sobre o archinstall, incluindo desktop, rice e guia de particionamento. |
| `shell/` | **Nullyz para Hyprland:** desktop novo em Quickshell (barra de menus, dock, central de controle, busca, visão de janelas, notificações, bloqueio). |
| `plasma/` | **Nullyz para KDE:** tema global (look-and-feel), cores, decoração de janela, painel e ícones. |
| `rices/` | Receitas dos rices da comunidade, uma pasta por rice, e o verificador. |
| `apps/` | Apps do sistema: Nullyz Rices (loja e troca de rice), Configurações e Boas-vindas. |
| `branding/` | Logo, wallpapers, sons, tela de boot (Plymouth) e de login (SDDM). |
| `packages/` | PKGBUILDs e o repositório pacman `nullyz`, assinado. |

## Rices da comunidade: como funciona

Rice de terceiro **nunca** roda o instalador original dele. Em vez disso, cada rice vira uma **receita** declarativa (`rices/<id>/rice.toml`):

```toml
id = "serpantinum"
nome = "Serpantinum"
autor = "ilyamiro"
licenca = "AGPL-3.0"
origem = "https://github.com/ilyamiro/serpantinum"
commit = "…"                 # versão exata, verificada; nada de "última"
desktop = "hyprland"         # hyprland | kde
pacotes = ["quickshell", "…"] # só repositórios oficiais ou o nullyz
[[arquivos]]                  # o que vai para onde, nada além disso
de = "config/hypr"
para = "~/.config/hypr"
```

- **Commit fixo:** o código é baixado do commit exato da receita e conferido. Mudança no original só entra depois de revisada.
- **Pacotes:** só de repositório oficial ou do `nullyz`. Se o rice depende de algo do AUR, empacotamos no `nullyz` ou ele não entra.
- **Arquivos:** a receita só copia arquivos para os caminhos listados. Não roda script arbitrário.
- **Snapshot:** antes de aplicar, o sistema tira uma foto (btrfs + snapper). Se algo quebrar, volta em um clique, inclusive pelo menu de boot.
- **Crédito:** a loja e o instalador mostram autor, licença e link do original.

## Base técnica

| Parte | Escolha | Por quê |
|---|---|---|
| Sistema | Arch Linux | rolling, pacotes novos, archiso pronto |
| Instalador | archinstall | oficial do Arch, com perfil próprio do NullyzOS |
| Disco | btrfs + snapper | snapshots para trocar rice e atualizar sem medo |
| Login | SDDM com tema Nullyz | serve para Hyprland e KDE |
| Hyprland | Hyprland + Quickshell | o que já dominamos; config em Lua |
| KDE | Plasma 6 | completo, Wayland, tema global |

## Etapas

| Versão | Entrega |
|---|---|
| **v0.1 — Base** | ISO dá boot, instala Arch com Hyprland e o desktop Nullyz mínimo (barra, dock, lançador, bloqueio). |
| **v0.2 — KDE** | Opção KDE no instalador com o visual Nullyz para Plasma. |
| **v0.3 — Receitas** | Formato de receita, verificador e os dois primeiros rices da comunidade, com autores avisados. |
| **v0.4 — Loja de rices** | Nullyz Rices: ver, aplicar e desfazer rices com snapshot. |
| **v0.5 — Sistema** | Configurações, Boas-vindas, atualizações e central de controle completas. |
| **v1.0 — Lançamento** | ISO estável, site, documentação e repositório pacman público. |

## Fora do escopo (por enquanto)

- Outros desktops além de Hyprland e KDE.
- Rice que dependa de AUR sem pacote nosso.
- Compositor próprio.
