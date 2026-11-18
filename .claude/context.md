# Contexto do NullyzOS (para sessões futuras)

## Decisões (17/11/2026)
- Repo novo, separado do Nullyzrice. O rice foi o laboratório: o NullyzOS tem desktop **novo**, mais leve e minimalista, com a logo do Nullyz.
- Instalador gráfico (Calamares) escolhe **Hyprland ou KDE** e depois o **visual**: Nullyz padrão ou rice da comunidade compatível com aquele desktop.
- Estilo inspirado no macOS Tahoe (vidro, cantos redondos, barra de menus, dock). **Nada da Apple**: nem ícone, fonte, som, wallpaper, nome ou logo.
- Rice de terceiro = receita declarativa (`rices/<id>/rice.toml`): commit fixo, só pacotes oficiais/`nullyz`, só cópia de arquivos listados, snapshot antes. Crédito + licença visíveis; avisar o autor antes de publicar.
- Serpantinum (AGPL) e illogical-impulse (GPL) são candidatos a receita, nunca código copiado para o nosso shell.
- Nullyzrice: repositório no GitHub **apagado** pelo usuário em 17/11/2026; cópia local continua em E:\projetos\Nullyzrice (referência). A chave "Nullyz Packages" segue valendo: privada em E:\projetos\Nullyzrice-chave-gpg, pública em docs/nullyz-repo.asc. Repositório pacman do NullyzOS se chama `nullyzos`.

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

## Teste de instalação completa (17/11/2026, VM "NullyzOS-teste", UEFI, disco 30 GB)
- Funcionou: plymouth no live (N → NULL → YZ OS, pixels pulsando), Calamares sozinho em tela cheia
  (pt-BR, São Paulo, ABNT2, escolha Hyprland/KDE, btrfs), instalação até "Tudo pronto", boot do disco,
  SDDM Nullyz (relógio, cartão, "Senha incorreta" com tremida, sessão Hyprland).
- Bugs achados e corrigidos no instalador: sem DNS no chroot (shellprocess@rede, pkgrel 2);
  faltava grubcfg (GRUB "Arch Linux" e sem splash no sistema instalado, pkgrel 3) — conferir no próximo build.
- Pendentes: imagem de boas-vindas gigante/cortada; prévia do packagechooser é o ícone padrão;
  moldura branca no slideshow; "timezone para 1"/"modelo teclado para 1" no resumo; radio buttons
  quase invisíveis; Hyprland puro cai na VM sem 3D (precisa do modo VM do desktop Nullyz, #6).
- Pilotar o Calamares pelo teclado: Alt+letra sublinhada (Alt+P às vezes cai em "Problemas conhecidos";
  aí Tab Tab Espaço), lista do desktop: Shift+Tab, seta, Espaço. Live: tty2 = Ctrl+Alt+F2, login root,
  `loadkeys us` antes de digitar símbolos. Atualizar config no live sem nova ISO: curl dos arquivos do
  raw.githubusercontent.com para /etc/calamares e `pkill calamares`; reabrir com `nullyzos-instalar` no tty1.
- Repositório: nunca recompilar versão igual (CI reaproveita); mudou pacote → subir pkgrel.

## Teste limpo final — v0.1 completa (17/11/2026, ISO 2026.11.17, VM UEFI 3D, disco novo)
- Passou tudo: instalação até o fim; GRUB "NullyzOS Linux" + `splash` no kernel; Plymouth N pixelado +
  NULLYZ OS no sistema instalado; SDDM novo (sessão no topo, energia em ícones empilhados); login → desktop
  sobe sozinho; `pgrep -c qs` = 1; DNS ok; resolved, NetworkManager e sddm ativos. #5, #6, #7 fechadas.
- Detalhe estético: entrada do GRUB fica "NullyzOS Linux, with Linux linux" (texto padrão do grub-mkconfig).
- Verificar na VM sem senha: Super+Enter abre o kitty; digitar com keyboardputstring + Enter 1c 9c;
  `/` = scancode 73 f3 (ABNT2). VM fechada com "salvar estado" volta com `startvm`.
