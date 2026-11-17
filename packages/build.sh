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
for pkgbuild in "$ROOT"/*/PKGBUILD; do
  dir="$(dirname "$pkgbuild")"
  echo ":: construindo $(basename "$dir")"
  (cd "$dir" && PKGDEST="$OUT" makepkg --clean --cleanbuild --force --syncdeps --noconfirm "${sign_args[@]}")
done

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
