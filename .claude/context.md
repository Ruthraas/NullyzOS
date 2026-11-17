# Contexto do NullyzOS (para sessões futuras)

## Decisões (17/11/2026)
- Repo novo, separado do Nullyzrice. O rice foi o laboratório: o NullyzOS tem desktop **novo**, mais leve e minimalista, com a logo do Nullyz.
- Instalador gráfico (Calamares) escolhe **Hyprland ou KDE** e depois o **visual**: Nullyz padrão ou rice da comunidade compatível com aquele desktop.
- Estilo inspirado no macOS Tahoe (vidro, cantos redondos, barra de menus, dock). **Nada da Apple**: nem ícone, fonte, som, wallpaper, nome ou logo.
- Rice de terceiro = receita declarativa (`rices/<id>/rice.toml`): commit fixo, só pacotes oficiais/`nullyz`, só cópia de arquivos listados, snapshot antes. Crédito + licença visíveis; avisar o autor antes de publicar.
- Serpantinum (AGPL) e illogical-impulse (GPL) são candidatos a receita, nunca código copiado para o nosso shell.
- Nullyzrice: o usuário pensa em apagar; recomendado arquivar (tem repo pacman assinado e chave pública publicados). Não mexer sem pedido explícito.

## Regras herdadas
- Sem AUR, sem `curl | bash`. Calamares não está nos repos oficiais: empacotar em `packages/`.
- Conventional Commits pt-BR + `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Git: Ruthraas / 101161738+Ruthraas@users.noreply.github.com. E-mail do usuário é privado.
- Chave GPG privada fica em E:\projetos\Nullyzrice-chave-gpg, nunca no repo.
- Cores sempre por tokens do tema; 12 princípios da animação.
- Perguntas ao usuário em texto com opções numeradas.

## Lições do Nullyzrice que valem aqui
- Hyprland 0.57 com config em **Lua**; API simulada em `scripts/check-hypr.py` do rice (reaproveitar).
- VirtualBox sem 3D: Quickshell precisa de `QT_QUICK_BACKEND=software`; nesse modo uma janela que nasce pequena e cresce **não é redesenhada** → janelas de tamanho fixo + `mask`.
- Digitar na VM: `keyboardputstring` + scancode `1c 9c` (Enter); evitar `/ ; : " | { } \ '` e acentos (ABNT2). Sempre screenshot antes de digitar. Nunca chutar a senha (faillock).
- ISO: build fora do tmpfs (`/var/tmp`), instalar a home live como o usuário, checar base-devel.
- Resolução da VM: `nullyz monitor set 1920x1080@60` no rice; janela do VirtualBox em tela cheia (Right Ctrl+F) para não ter barras de rolagem.
