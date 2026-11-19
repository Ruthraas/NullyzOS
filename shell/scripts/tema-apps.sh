#!/bin/sh
# Aplica o visual Nullyz nos apps (chamado pelo serviço AppTheme do shell).
#   tema-apps.sh <Nullyz.colors> <escuro|claro> <#destaque> <fonte>
# Qt/KDE: copia cada grupo do .colors para o kdeglobals (kwriteconfig6, sem apagar o resto),
#         estilo Breeze, ícones Breeze, fonte. GTK: adw-gtk3, escuro/claro, cor de destaque.
colors=$1 modo=$2 acc=$3 fonte=$4
[ -f "$colors" ] || exit 0
cfg=${XDG_CONFIG_HOME:-$HOME/.config}
dados=${XDG_DATA_HOME:-$HOME/.local/share}
mkdir -p "$dados/color-schemes" && cp -f "$colors" "$dados/color-schemes/Nullyz.colors"

# ---- Qt / KDE ---------------------------------------------------------------------------
if command -v kwriteconfig6 >/dev/null 2>&1; then
    grupo=""
    while IFS= read -r linha; do
        case "$linha" in
            "#"* | "") continue ;;
            "["*"]") grupo=${linha#[}; grupo=${grupo%]} ;;
            *=*) kwriteconfig6 --file kdeglobals --group "$grupo" --key "${linha%%=*}" "${linha#*=}" ;;
        esac
    done < "$colors"
    kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Breeze
    # Ícones de app do NullyzOS (o resto vem do Breeze claro ou escuro)
    if [ "$modo" = claro ]; then icones=Nullyz-Claro; else icones=Nullyz; fi
    kwriteconfig6 --file kdeglobals --group Icons --key Theme "$icones"
    kwriteconfig6 --file kdeglobals --group General --key font "$fonte,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
    kwriteconfig6 --file kdeglobals --group General --key fixed "Geist Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
fi

# ---- GTK 3 / 4 ---------------------------------------------------------------------------
css="/* Gerado pelas Configurações do NullyzOS: cor de destaque dos apps GTK. */
@define-color accent_color $acc;
@define-color accent_bg_color $acc;
@define-color accent_fg_color #ffffff;
"
for v in gtk-3.0 gtk-4.0; do
    mkdir -p "$cfg/$v"
    printf '%s' "$css" > "$cfg/$v/gtk.css"
done
if command -v gsettings >/dev/null 2>&1; then
    if [ "$modo" = claro ]; then
        gsettings set org.gnome.desktop.interface color-scheme prefer-light
        gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3
        gsettings set org.gnome.desktop.interface icon-theme Nullyz-Claro
    else
        gsettings set org.gnome.desktop.interface color-scheme prefer-dark
        gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
        gsettings set org.gnome.desktop.interface icon-theme Nullyz
    fi
    gsettings set org.gnome.desktop.interface font-name "$fonte 11"
    gsettings set org.gnome.desktop.interface monospace-font-name "Geist Mono 11"
    gsettings set org.gnome.desktop.interface cursor-theme Adwaita
fi
exit 0
