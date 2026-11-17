#!/usr/bin/env bash
# Gera a ISO do NullyzOS a partir do perfil oficial "releng" do archiso (#2).
#
#   sudo iso/build.sh            → out/nullyzos-<data>-x86_64.iso
#
# Estratégia (herdada do Nullyzrice): copiar /usr/share/archiso/configs/releng, que o Arch
# mantém e já dá boot em BIOS e UEFI, e sobrepor só o que é nosso: nome, pacotes, airootfs e
# branding. Assim os carregadores de boot acompanham cada versão do archiso sem cópia nossa.
#
# Precisa (repositórios oficiais): archiso.
set -euo pipefail

ISO_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$ISO_SRC/.." && pwd)"
WORK="${NULLYZ_ISO_WORK:-/var/tmp/nullyzos-iso}"   # disco, não RAM: o /tmp (tmpfs) enche no meio
OUT="${NULLYZ_ISO_OUT:-$REPO/out}"
RELENG=/usr/share/archiso/configs/releng
PROFILE="$WORK/profile"

[ "$(id -u)" -eq 0 ] || { echo "o mkarchiso precisa de root: sudo $0" >&2; exit 1; }
[ -d "$RELENG" ] || { echo "instale o archiso: sudo pacman -S archiso" >&2; exit 1; }
FREE_KB=$(df --output=avail -k "$(dirname "$WORK")" | tail -1)
[ "$FREE_KB" -gt $((8 * 1024 * 1024)) ] || { echo "pouco espaço em $(dirname "$WORK"): precisa de ~8 GB livres" >&2; exit 1; }

echo ":: preparando o perfil em $PROFILE"
rm -rf "$WORK"
mkdir -p "$WORK" "$OUT"
cp -a "$RELENG" "$PROFILE"

# 1. Identidade da ISO ----------------------------------------------------------------
sed -i \
  -e 's/^iso_name=.*/iso_name="nullyzos"/' \
  -e 's/^iso_label=.*/iso_label="NULLYZOS_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"/' \
  -e 's/^iso_publisher=.*/iso_publisher="NullyzOS <https:\/\/github.com\/Ruthraas\/NullyzOS>"/' \
  -e 's/^iso_application=.*/iso_application="NullyzOS live"/' \
  "$PROFILE/profiledef.sh"

# 2. Pacotes: os do releng + os nossos ------------------------------------------------
{
  cat "$PROFILE/packages.x86_64"
  grep -vE '^\s*(#|$)' "$ISO_SRC/packages.x86_64"
} | sort -u > "$PROFILE/packages.x86_64.new"
mv "$PROFILE/packages.x86_64.new" "$PROFILE/packages.x86_64"

# Repositório nullyzos (instalador, temas, fontes): assinatura exigida. A chave do projeto
# entra no chaveiro de quem gera a ISO (o pacstrap do mkarchiso usa o chaveiro do host).
FPR=C43C292B0901FB84D4A1A17436828706C86FB94A
if ! pacman-key --list-keys "$FPR" >/dev/null 2>&1; then
  pacman-key --add "$REPO/docs/nullyz-repo.asc"
  pacman-key --lsign-key "$FPR"
fi
# Cópias antigas dos nossos pacotes no cache do pacman do host travam o build ("corrupted"):
# o nome é o mesmo e o conteúdo pode não bater com o banco atual. Sempre baixa de novo.
rm -f /var/cache/pacman/pkg/nullyzos-* /var/cache/pacman/pkg/ttf-geist-* /var/cache/pacman/pkg/calamares-*
cat >> "$PROFILE/pacman.conf" <<'EOF'

[nullyzos]
SigLevel = Required DatabaseRequired
Server = https://github.com/Ruthraas/NullyzOS/releases/download/repo
EOF

# 3. airootfs do NullyzOS (os-release, issue, motd, idioma e teclado) -----------------
# O releng traz um motd do Arch; o nosso substitui.
cp -a "$ISO_SRC/airootfs/." "$PROFILE/airootfs/"

# O live abre o instalador gráfico sozinho no tty1 (Ctrl+Alt+F2 dá um terminal).
cat >> "$PROFILE/airootfs/root/.zlogin" <<'EOF'

# NullyzOS: instalador gráfico no tty1. Para reabrir: nullyzos-instalar
if [[ "$(tty)" == /dev/tty1 ]] && [[ -z "${NULLYZ_SEM_INSTALADOR:-}" ]]; then
  nullyzos-instalar
fi
EOF

# Animação de boot também no live: plymouth no initramfs do archiso e "quiet splash".
# O releng atual não tem "kms" (o vídeo cedo, que o plymouth precisa): entra junto, depois do modconf.
ARCHISO_CONF="$PROFILE/airootfs/etc/mkinitcpio.conf.d/archiso.conf"
if grep -q '\bkms\b' "$ARCHISO_CONF"; then
  sed -i 's/\bkms\b/kms plymouth/' "$ARCHISO_CONF"
else
  sed -i 's/\bmodconf\b/modconf kms plymouth/' "$ARCHISO_CONF"
fi
grep -q plymouth "$PROFILE/airootfs/etc/mkinitcpio.conf.d/archiso.conf" \
  || { echo "não achei onde pôr o hook plymouth em archiso.conf" >&2; exit 1; }
for f in "$PROFILE"/efiboot/loader/entries/*.conf; do
  [ -f "$f" ] && sed -i '/^options / s/$/ quiet splash/' "$f"
done
for f in "$PROFILE"/syslinux/*.cfg; do
  [ -f "$f" ] && sed -i '/^\s*APPEND .*archisobasedir/ s/$/ quiet splash/' "$f"
done
for f in "$PROFILE"/grub/*.cfg; do
  [ -f "$f" ] && sed -i '/^\s*linux .*archisobasedir/ s/$/ quiet splash/' "$f"
done

# 4. Branding do boot: nome nos três carregadores, cores e splash do syslinux ---------
echo ":: branding do boot"
for f in "$PROFILE"/efiboot/loader/entries/*.conf "$PROFILE"/syslinux/*.cfg "$PROFILE"/grub/*.cfg; do
  [ -f "$f" ] || continue
  sed -i -e 's/Arch Linux install medium/NullyzOS live/g' -e 's/Arch Linux/NullyzOS/g' "$f"
done
if [ -f "$PROFILE/syslinux/archiso_head.cfg" ]; then
  # O nome já está desenhado no splash; o título do menu caía em cima dele.
  sed -i '/^MENU TITLE/d' "$PROFILE/syslinux/archiso_head.cfg"
  cat "$ISO_SRC/branding/syslinux-colors.cfg" >> "$PROFILE/syslinux/archiso_head.cfg"
fi
cp "$ISO_SRC/branding/splash.png" "$PROFILE/syslinux/splash.png"

# 5. Build -----------------------------------------------------------------------------
echo ":: mkarchiso"
mkarchiso -v -w "$WORK/work" -o "$OUT" "$PROFILE"
if [ -n "${SUDO_USER:-}" ]; then chown "$SUDO_USER" "$OUT"/*.iso; fi
rm -rf "$WORK"
echo ":: pronto:"
ls -lh "$OUT"/*.iso
