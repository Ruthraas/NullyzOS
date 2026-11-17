#!/usr/bin/env bash
# Constrói e assina o repositório pacman "nullyzos" (#3).
#
#   packages/build.sh             constrói packages/*/PKGBUILD e o banco em packages/out/
#   packages/build.sh --no-sign   sem assinatura (só teste local; nunca publique assim)
#
# Precisa (repositórios oficiais): base-devel (makepkg, repo-add).
# Assinatura: a chave "Nullyz Packages" no chaveiro e NULLYZ_GPG_KEY com o fingerprint.
# Procedimento completo em docs/REPOSITORIO.md.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$ROOT/out"
REPO_NAME=nullyzos
SIGN=1
[ "${1:-}" = "--no-sign" ] && SIGN=0

[ "$(id -u)" -ne 0 ] || { echo "o makepkg não roda como root; use seu usuário" >&2; exit 1; }
command -v makepkg >/dev/null || { echo "instale base-devel" >&2; exit 1; }

sign_args=()
if [ "$SIGN" -eq 1 ]; then
  : "${NULLYZ_GPG_KEY:?defina NULLYZ_GPG_KEY com o fingerprint da chave (ou use --no-sign)}"
  export GPGKEY="$NULLYZ_GPG_KEY"
  sign_args=(--sign)
fi

rm -rf "$OUT"
mkdir -p "$OUT"

# Ordem: primeiro quem só depende de pacotes oficiais; os nossos que dependem de outros nossos
# depois. Cada pacote pronto entra num repositório local temporário ("nullyzos-local", que o
# pacman.conf precisa listar com Server = file://<esta pasta>/out) para o próximo achar.
ORDER=(ttf-geist calamares nullyzos-branding nullyzos-plymouth nullyzos-sddm nullyzos-installer)
dirs=()
for name in "${ORDER[@]}"; do [ -f "$ROOT/$name/PKGBUILD" ] && dirs+=("$ROOT/$name"); done
for pkgbuild in "$ROOT"/*/PKGBUILD; do
  d="$(dirname "$pkgbuild")"
  [[ " ${ORDER[*]} " == *" $(basename "$d") "* ]] || dirs+=("$d")
done
LOCAL_DB="$OUT/nullyzos-local.db.tar.zst"
have_local=0
grep -q '^\[nullyzos-local\]' /etc/pacman.conf && have_local=1

shopt -s nullglob
for dir in "${dirs[@]}"; do
  echo ":: construindo $(basename "$dir")"
  (cd "$dir" && PKGDEST="$OUT" makepkg --clean --cleanbuild --force --syncdeps --noconfirm "${sign_args[@]}")
  built=("$OUT"/*.pkg.tar.zst)
  if [ "$have_local" -eq 1 ] && [ ${#built[@]} -gt 0 ]; then
    repo-add -q "$LOCAL_DB" "${built[@]}"
    sudo pacman -Sy --noconfirm >/dev/null
  fi
done
rm -f "$OUT"/nullyzos-local.*

echo ":: banco $REPO_NAME"
cd "$OUT"
shopt -s nullglob
pkgs=(*.pkg.tar.zst)
[ ${#pkgs[@]} -gt 0 ] || { echo "nenhum pacote gerado" >&2; exit 1; }
repo_args=(--new --remove)
[ "$SIGN" -eq 1 ] && repo_args+=(--sign --verify --key "$NULLYZ_GPG_KEY")
repo-add "${repo_args[@]}" "$REPO_NAME.db.tar.zst" "${pkgs[@]}"

# O GitHub Releases não guarda symlinks: nullyzos.db/.files viram cópias reais.
for f in "$REPO_NAME.db" "$REPO_NAME.files" "$REPO_NAME.db.sig" "$REPO_NAME.files.sig"; do
  if [ -L "$f" ]; then
    target="$(readlink "$f")"
    rm "$f"
    cp "$target" "$f"
  fi
done
echo ":: pronto em $OUT"
ls -1 "$OUT"
