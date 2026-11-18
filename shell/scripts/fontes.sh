#!/bin/sh
# Fontes para Configurações → Fontes.
#   fontes.sh mono          famílias monoespaçadas instaladas (uma por linha)
#   fontes.sh busca TEXTO   pacotes de fonte dos repositórios oficiais que batem com TEXTO:
#                           "nome<TAB>instalado(0/1)<TAB>descrição", no máximo 30
#   fontes.sh atualizar     refaz o cache de fontes do usuário (~/.local/share/fonts)
case "${1:-}" in
    mono)
        fc-list :spacing=mono family | cut -d, -f1 | sort -u
        ;;
    busca)
        q=${2:-}
        pacman -Ss "$q" 2>/dev/null | awk -v OFS='\t' '
            /^[^ ]/ {
                split($1, a, "/"); name = a[2]
                inst = ($0 ~ /\[instalado|\[installed/) ? 1 : 0
                getline desc; sub(/^ +/, "", desc)
                if (name ~ /^(ttf|otf)-/ || name ~ /-fonts?$/ || name ~ /^(noto-fonts|inter-font)/) print name, inst, desc
            }' | head -n 30
        ;;
    atualizar)
        mkdir -p "$HOME/.local/share/fonts"
        fc-cache -f "$HOME/.local/share/fonts"
        ;;
esac
