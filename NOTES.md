# NullyzOS — notas do projeto

- Stack: Arch Linux/archiso, archinstall, Hyprland, KDE Plasma, Quickshell/QML, Bash, Python e JavaScript.
- Estrutura: `iso/` imagem; `installer/` instalação; `shell/` desktop Hyprland; `plasma/` KDE; `rices/` temas; `apps/` utilitários; `packages/` PKGBUILDs; `branding/`; `site/`; `scripts/` verificadores.
- Convenções: sem AUR ou `curl | bash`; pacotes assinados; receitas de rice com versão/licença fixas; snapshots antes de mudanças visuais; preservar suporte Hyprland e KDE.
- Validação: preferir `scripts/check-hypr.py`, `scripts/check-qml.py`, `scripts/check-rices.py` e workflows de `.github/workflows/`; executar apenas verificações relacionadas ao arquivo alterado.
- Status: base, KDE, receitas, loja de rices e apps do sistema implementados; pendentes rices comunitários, ícones próprios, Secure Boot e testes em hardware real.
- Último estado observado: commit `a1f260b` (2026-11-20), correções de vídeo NVIDIA/AMD/Intel no boot e sistema instalado.
- Instalador: TUI baseado no `archinstall`; ESP em `/boot/efi`; logs em `/root/nullyzos-instalacao.log`.
- Pacotes NullyzOS no perfil devem ser instalados por `pacman` no chroot após chave e repositório; não usar o resolvedor oficial do archinstall.
