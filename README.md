# NullyzOS

> Sistema baseado em Arch, leve, moderno e minimalista. Na instalação você escolhe o desktop (Hyprland ou KDE) e o visual: o Nullyz padrão ou um rice pronto da comunidade.

**[Baixar o NullyzOS 0.2.0](https://github.com/Ruthraas/NullyzOS/releases/latest)** · [Site](https://nullyzos.vercel.app) · [Passo a passo de instalação](https://nullyzos.vercel.app/instalar.html) · [Guia de segurança](https://nullyzos.vercel.app/seguranca.html)

Primeira versão pública: testada em máquina virtual (Hyprland e KDE, com e sem criptografia). Tenha backup antes de instalar. A visão completa está em [`docs/VISAO.md`](docs/VISAO.md).

## Como é

```
NullyzOS
 ├─ Hyprland ─┬─ Nullyz (padrão)
 │            └─ rices da comunidade
 └─ KDE ──────┬─ Nullyz (padrão)
              └─ rices de KDE
```

- **Visual próprio** inspirado no macOS Tahoe: vidro, cantos redondos, barra de menus e dock. É desenhado do zero, sem nada da Apple.
- **Rices da comunidade** entram como receitas revisadas: versão fixa, só pacotes oficiais, com crédito e licença do autor.
- **Troca segura:** snapshot antes de cada mudança, volta em um clique.
- **Seguro:** sem AUR, sem `curl | bash`, pacotes assinados.

## Roadmap

| Versão | Entrega |
|---|---|
| ✅ v0.1 — Base | ISO instala Arch + Hyprland + desktop Nullyz |
| ✅ v0.2 — KDE | Opção KDE com o visual Nullyz |
| ✅ Receitas | Formato de receita, verificador e 9 rices do Nullyz |
| ✅ Loja de rices | Aplicar e desfazer rices com snapshot |
| ✅ Sistema | Configurações, boas-vindas e atualizações |
| ⏳ Próximos | Rices da comunidade, ícones próprios, Secure Boot, testes em hardware real |
| v1.0 — Lançamento | ISO estável |

## Estrutura

| Pasta | Conteúdo |
|---|---|
| `iso/` | perfil archiso |
| `installer/` | Calamares com telas próprias |
| `shell/` | desktop Nullyz para Hyprland (Quickshell) |
| `plasma/` | visual Nullyz para KDE |
| `rices/` | receitas dos rices da comunidade |
| `apps/` | Nullyz Rices, Configurações, Boas-vindas |
| `branding/` | logo, wallpapers, sons, boot e login |
| `packages/` | PKGBUILDs e repositório pacman assinado |

## Contribuir

Leia o [`CONTRIBUTING.md`](CONTRIBUTING.md). Quer ver seu rice no NullyzOS? Abra uma issue com o modelo "Propor um rice".

## Licença

[GPL-3.0](LICENSE). Rices da comunidade mantêm a licença dos seus autores, listada em cada receita e em [`CREDITS.md`](CREDITS.md).
