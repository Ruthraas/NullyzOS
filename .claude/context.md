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

## Lição (17/11/2026): digitar na VM só pelo script com mapa ABNT2
- `keyboardputstring` manda `/` como `;` no ABNT2: `rm -rf .config/quickshell` virou
  `rm -rf .config;quickshell` e apagou o ~/.config do usuário de teste. Sempre usar o digitador
  com mapa (`/`=73 f3, `:`=2a 35 b5 aa, `'`=29 a9, `"`=2a 29 a9 aa, `{`=2a 1b 9b aa, `}`=2a 2b ab aa,
  `;`=35 b5, `|`=2a 56 d6 aa) e nunca `rm -rf` com caminho digitado; preferir `mv` para lixo.
- Configurações abertas (camada Overlay, foco sob demanda) recebem o teclado: Esc antes de digitar.

## Configurações e desktop (17/11/2026, desktop até 0.1.0-19)
- Configurações (Super + vírgula; IPC settings/settingsPage <id>): tópicos Personalização
  (Aparência, Tela de bloqueio, Barra e dock, Janelas, Fontes, Terminal), Sistema (Rede, Som,
  Teclado e mouse, Monitores, Energia, Desempenho) e Geral (Atalhos, Sobre).
- Arquivos do usuário em ~/.config/nullyzos/: shell.json (Prefs; regravado com chaves novas ao
  carregar), hyprland.json → hyprland.lua (HyprConf; carregado pela config do sistema antes de
  ~/.config/hypr/nullyzos.lua), terminal.json → kitty.conf + terminal.sh (Terminal), agenda.json.
- Root via pkexec + polkit: /usr/lib/nullyzos/fundo-login (sddm) e /usr/lib/nullyzos/limpeza
  (pacotes, orfaos, energia, fonte <pacote da lista>). Configurações se escondem (settingsAside)
  enquanto o pedido de senha está aberto.
- Painéis na barra: painel rápido (status), calendário + agenda (data/hora; IPC calendar,
  agendaAdd). Tok tem tema claro/escuro, 6 destaques, vidro, fonte e escala (Txt.size).
- Terminal: /etc/xdg/kitty/kitty.conf + /usr/lib/nullyzos/terminal-shell (bash com prompt e
  saudação do N pixelado; lê ~/.bashrc antes).
- Testar shell novo na VM sem pacote: baixar o tar do commit para ~/.config/quickshell/nullyzos
  (sobrepõe /etc/xdg); tirar (mv) antes do pacman -Syu. Painel aberto pega o teclado: Esc antes.

## 18/11/2026: essenciais, atualizações, apps nas cores, páginas e shell (desktop até 0.1.0-34)
- nullyzos-essenciais (Hyprland e KDE): apps KDE básicos, udisks2/gvfs, Noto (emoji/CJK),
  codecs, xdg-user-dirs, flatpak + portal GTK, bluez, cups, ufw, zram, snapper/snap-pac/
  grub-btrfs. /etc/xdg/mimeapps.list com Brave (Flathub) como navegador padrão.
- Instalador: shellprocess@finalizar (depois do packages): Flathub + Brave, ufw ligado,
  snapper no @snapshots; serviços bluetooth, cups, ufw, grub-btrfsd, power-profiles-daemon.
- Brave não existe nos repositórios oficiais (só AUR): vem do Flathub (publicado pelo Brave).
- Root via pkexec: /usr/lib/nullyzos/{fundo-login, limpeza, atualizar}.
- Apps nas cores (#16): serviço AppTheme → scripts/tema-apps.sh (kdeglobals via kwriteconfig6,
  QT_QPA_PLATFORMTHEME=kde com plasma-integration; GTK adw-gtk3 + gtk.css + gsettings).
- Terminal: logo padrão = N binário (só 0/1 formando a letra, sem fundo); buraco negro, pixel e
  blocos como opção. fastfetch como saudação.
- Shell: OSD de volume/brilho, painel rápido (luz noturna/hyprsunset, não perturbe, música
  MPRIS, histórico de notificações), Alt+Tab, Super+Tab (visão geral), Super+Shift+V
  (cliphist), Super+ponto (emoji, shell/data/emoji.txt), boas-vindas no 1º login.
- Configurações: 25 páginas (Personalização, Sistema, Geral). IPC: settingsPage <id>, quick,
  calendar, agendaAdd, osdBrightness, welcome, switcher, overview, clipboard, emoji.
- Digitador da VM: primeira letra às vezes some; começar as linhas com espaço.

## 18/11/2026 — wallpapers, rices e teste limpo
- Configurações → Wallpapers: os seus + galeria online (Wallhaven por categoria/busca, só SFW
  1920x1080+; KDE Plasma com licença livre). shell/scripts/galeria.sh. KDE: vários tamanhos são
  symlinks (modo 120000, texto de 13 bytes): usar só blob 100644.
- Cor de destaque "Do wallpaper" (accent "auto"): Canvas em modules/Wallpaper.qml → Tok.autoAccent.
- Foto de perfil: shell/scripts/avatar.sh (~/.face + AccountsService SetIconFile); SDDM e bloqueio mostram.
- Rices (#9/#10/#11): rices/<id>/rice.toml (preset | arquivos), scripts/check-rices.py gera
  rices/catalogo.json + packagechooser-visual.conf + contextualprocess-rice.conf (CI: --verificar).
  apps/nullyzos-rice (aplicar/desfazer/inicial) + apps/rice-root (pkexec: snapshot, pacotes da receita).
  IPC `rice(prefs, hypr)` usa Prefs.setMany/HyprConf.setMany: set() em sequência perdia chaves
  (releitura do watchChanges voltava gravação anterior).
- LIÇÃO instalador: o packages tirava o nullyzos-installer ANTES do shellprocess@finalizar, e o
  "-" escondia a falha (sem firewall, snapper, Brave). Agora sai no fim (shellprocess@limpar).
  Rice do Visual via contextualprocess (chave packagechooser_visual).
- LIÇÃO polkit: hyprpolkitagent dá core dump na VM ao desenhar (wl_surface.attach inválido) →
  "Not authorized" sem janela. Modo VM usa polkit-gnome. Esc cancela sem contar falha; OK com
  senha vazia conta e o faillock trava a conta 10 min — nunca apertar OK no pedido de senha.
- VM "NullyzOS-limpa" (UEFI, 3D, disco 30 GB): instalação da ISO 18/11 + correções à mão.
  snap-pac funcionando (root 1/2 no pacman). Pendente: ISO nova com o instalador corrigido
  (pkgrel 14) e o botão Concluído; testar o passo Visual do zero.

## 18/11/2026 (tarde) — KDE v0.2, paletas e pacotes novos
- Pacotes novos: nullyzos-terminal (prompt + N no fastfetch, kitty e Konsole), nullyzos-shell
  (Quickshell, ajudantes pkexec, rices, fundos; usado pelos dois desktops), nullyzos-desktop-kde.
- KDE: tema global org.nullyzos.desktop, Plasma Nullyz Vidro, Aurorae Nullyz (plugin é
  org.kde.kwin.aurorae.v2 no Plasma 6.8 — com o nome antigo cai no Breeze sem avisar),
  esquemas Nullyz*.colors gerados de branding/tokens.json (paletas), kde-primeiro/kde-sessao.
- Configurações como app: NULLYZ_APP=configuracoes (nullyzos-configuracoes); páginas KDE
  próprias (SettingsKde*.qml + services/Kde.qml via evaluateScript do plasmashell).
- Rices por desktop: shell.json/rice (Hyprland) e kde.json/rice-kde (KDE); kdeglobals é
  dividido, cada desktop reaplica as cores ao entrar.
- Barra: estilos classica/flutuante/ilhas/semfundo (Prefs.barStyle, barSpace).
- Pendente: testar na VM as páginas KDE (Aparência/Barra/Dock) e "cores do wallpaper";
  ISO nova + instalação limpa (Hyprland e KDE); medir RAM.
