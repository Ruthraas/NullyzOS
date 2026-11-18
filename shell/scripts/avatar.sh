#!/bin/sh
# Foto de perfil (Configurações → Usuário):
#   avatar.sh escolher        abre o seletor de arquivo (kdialog) e usa a imagem escolhida
#   avatar.sh usar <imagem>   usa a imagem
#   avatar.sh tirar           volta para a inicial do nome
# Grava em ~/.face (shell, bloqueio) e no AccountsService (tela de login), sem senha: o
# AccountsService deixa cada um trocar a própria foto.
set -u
usuario="/org/freedesktop/Accounts/User$(id -u)"
case "${1:-}" in
    escolher)
        img=$(kdialog --title "Foto de perfil" --getopenfilename "$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME")" \
            "image/png image/jpeg image/webp" 2>/dev/null) || exit 1
        [ -n "$img" ] || exit 1
        exec "$0" usar "$img"
        ;;
    usar)
        img=$2
        [ -f "$img" ] || exit 1
        cp -f "$img" "$HOME/.face" && cp -f "$img" "$HOME/.face.icon"
        busctl call org.freedesktop.Accounts "$usuario" org.freedesktop.Accounts.User SetIconFile s "$HOME/.face" >/dev/null 2>&1 || true
        ;;
    tirar)
        rm -f "$HOME/.face" "$HOME/.face.icon"
        busctl call org.freedesktop.Accounts "$usuario" org.freedesktop.Accounts.User SetIconFile s "" >/dev/null 2>&1 || true
        ;;
esac
