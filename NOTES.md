# NullyzOS — notas do projeto

- Stack: Arch Linux/archiso, Calamares, Hyprland, KDE Plasma, Quickshell/QML, Bash, Python e JavaScript.
- Estrutura: `iso/` imagem; `installer/` instalação; `shell/` desktop Hyprland; `plasma/` KDE; `rices/` temas; `apps/` utilitários; `packages/` PKGBUILDs; `branding/`; `site/`; `scripts/` verificadores.
- Convenções: sem AUR ou `curl | bash`; pacotes assinados; receitas de rice com versão/licença fixas; snapshots antes de mudanças visuais; preservar suporte Hyprland e KDE.
- Validação: preferir `scripts/check-hypr.py`, `scripts/check-qml.py`, `scripts/check-rices.py` e workflows de `.github/workflows/`; executar apenas verificações relacionadas ao arquivo alterado.
- Status: base, KDE, receitas, loja de rices e apps do sistema implementados; pendentes rices comunitários, ícones próprios, Secure Boot e testes em hardware real.
- Último estado observado: commit `a1f260b` (2026-11-20), correções de vídeo NVIDIA/AMD/Intel no boot e sistema instalado.
- Instalador: pré-checagem de rede deve ocorrer antes do particionamento; logs detalhados ficam em `/root/nullyzos-instalacao.log`.
