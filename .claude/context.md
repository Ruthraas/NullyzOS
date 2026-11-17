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

## ISO (#2, fechada 17/11/2026)
- Build na VM "Nullyz" (Arch do rice), no TTY: `cd ~/NullyzOS && git pull && sudo iso/build.sh 2>&1 | tee ~/iso-build.log` (~11 min, 1,3 GB). No TTY o teclado é US: `/` e `:` digitam certo.
- Trazer para o Windows: `VBoxManage controlvm Nullyz natpf1 "isohttp,tcp,127.0.0.1,18080,,8000"` + na VM `python -m http.server 8000 --bind 0.0.0.0 -d ~/NullyzOS/out` + `curl` para E:\VMs\. Depois Ctrl+C e `natpf1 delete isohttp`.
- VM de teste "NullyzOS-teste" (sem disco, DVD = E:\VMs\nullyzos-*.iso): `modifyvm --firmware bios|efi`. BIOS e UEFI testados e dando boot no live.
- Console do Linux não tem cor 24-bit: /etc/issue redefine as cores 5 e 13 da paleta (`ESC ] P n rrggbb`) para #9d8cff.
- Pendente de conferir no próximo build: "YZ OS" (negrito, cor 13) em violeta.
