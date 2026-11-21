#!/bin/sh
# Atualizações pendentes, uma por linha, para Configurações → Atualizações e o aviso na barra:
#   pac <nome> <versão atual> <versão nova>
#   flat <app> <nome>
#   snap <número> <data> <descrição>      (com --snapshots: os snapshots do snapper)
# checkupdates (pacman-contrib) usa uma cópia do banco: não mexe no sistema nem pede senha.
checkupdates 2>/dev/null | awk '{ print "pac", $1, $2, $4 }'
if command -v flatpak >/dev/null 2>&1; then
    flatpak remote-ls --system --updates --columns=application,name 2>/dev/null | awk -F'\t' 'NF { print "flat", $1, $2 }'
fi
if [ "${1:-}" = "--snapshots" ] && command -v snapper >/dev/null 2>&1; then
    snapper --csvout -c root list --columns number,date,description 2>/dev/null \
        | awk -F, 'NR > 1 && $1 != "0" { print "snap", $1, $2 "|" $3 }' | tail -n 12
fi
