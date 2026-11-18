#!/bin/sh
# Lista as imagens que as Configurações oferecem como fundo: as do sistema e as da pasta
# Imagens do usuário (até 2 níveis), sem repetir, no máximo 80.
pics=$(xdg-user-dir PICTURES 2>/dev/null)
for d in /usr/share/nullyzos/wallpapers "$HOME/Imagens" "$HOME/Pictures" "$pics"; do
    [ -n "$d" ] && [ -d "$d" ] || continue
    find "$d" -maxdepth 2 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) 2>/dev/null | sort
done | awk '!seen[$0]++' | head -n 80
