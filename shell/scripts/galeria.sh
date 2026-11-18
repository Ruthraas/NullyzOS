#!/bin/sh
# Galeria online de wallpapers para Configurações → Wallpapers. Duas fontes:
#  - KDE Plasma (invent.kde.org/plasma/plasma-workspace-wallpapers): licenças livres; autor
#    e licença do metadata.json de cada um. Cache de 1 dia em ~/.cache/nullyzos/galeria.tsv.
#  - Wallhaven (wallhaven.cc, API pública): anime, natureza, espaço… Só SFW e no mínimo
#    1920x1080. Cada imagem tem a licença do artista/obra: serve de fundo, não se redistribui
#    (o sistema não traz nenhuma; a pessoa escolhe e baixa).
# Saída (TSV), um por linha: id  nome  autor  licença/fonte  url-miniatura  url-imagem
#   galeria.sh                                  KDE Plasma (do cache, se novo)
#   galeria.sh wallhaven <categoria> <página> [busca]
#        categorias: anime natureza espaco minimalista cidades escuro busca
#   galeria.sh baixar <url> <nome> <autor> <fonte>   baixa para Imagens/Wallpapers e
#                                                    imprime o caminho do arquivo
set -u
api="https://invent.kde.org/api/v4/projects/plasma%2Fplasma-workspace-wallpapers/repository"
raw="https://invent.kde.org/plasma/plasma-workspace-wallpapers/-/raw/master"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/nullyzos/galeria.tsv"

if [ "${1:-}" = baixar ]; then
    pics=$(xdg-user-dir PICTURES 2>/dev/null); [ -n "$pics" ] || pics="$HOME/Imagens"
    dir="$pics/Wallpapers"
    mkdir -p "$dir"
    ext=${2##*.}; case "$ext" in png|jpg|jpeg|webp) ;; *) ext=png ;; esac
    arq="$dir/$(printf '%s' "$3" | tr -c 'A-Za-z0-9._-' '_' | cut -c1-60).$ext"
    curl -fsSL --max-time 120 -o "$arq.part" "$2" && mv -f "$arq.part" "$arq" || { rm -f "$arq.part"; exit 1; }
    grep -qF "$3 " "$dir/CREDITOS.txt" 2>/dev/null ||
        printf '%s — %s — %s\n' "$3" "$4" "$5" >> "$dir/CREDITOS.txt"
    echo "$arq"
    exit 0
fi

if [ "${1:-}" = wallhaven ]; then
    cat=010 q=""
    case "${2:-anime}" in
        anime) cat=010 ;;
        natureza) cat=100 q="nature landscape" ;;
        espaco) cat=110 q="space" ;;
        minimalista) cat=110 q="minimalist" ;;
        cidades) cat=100 q="city" ;;
        escuro) cat=110 q="dark" ;;
        busca) cat=110 q="${4:-}" ;;
    esac
    # Autor: o site de origem da imagem (fonte informada no Wallhaven), quando houver.
    curl -fsSL --max-time 20 -G "https://wallhaven.cc/api/v1/search" \
        --data-urlencode "q=$q" --data-urlencode "categories=$cat" --data-urlencode "purity=100" \
        --data-urlencode "sorting=toplist" --data-urlencode "topRange=1y" --data-urlencode "atleast=1920x1080" \
        --data-urlencode "ratios=16x9,16x10" --data-urlencode "page=${3:-1}" |
        jq -r '.data[] | ["wh-" + .id, "Wallhaven " + .id + " · " + .resolution,
                          ((.source // "") | sub("^https?://"; "") | sub("^www[.]"; "") | split("/")[0]),
                          .url, .thumbs.small, .path] | @tsv'
    exit 0
fi

if [ -s "$cache" ] && [ -n "$(find "$cache" -mmin -1440 2>/dev/null)" ]; then
    cat "$cache"
    exit 0
fi
mkdir -p "$(dirname "$cache")"
tmp="$cache.tmp"
: > "$tmp"

# Todos os arquivos do repositório (algumas páginas de 100)
lista=""
p=1
while [ "$p" -le 10 ]; do
    # As pastas vêm primeiro: uma página só de pastas não é o fim; o fim é a página vazia.
    pg=$(curl -fsSL --max-time 20 "$api/tree?recursive=true&per_page=100&page=$p" | jq -r '.[] | .type + " " + .path') || break
    [ -n "$pg" ] || break
    lista="$lista
$(printf '%s\n' "$pg" | sed -n 's/^blob //p')"
    p=$((p + 1))
done

# Por wallpaper: miniatura = menor imagem deitada; imagem = a maior deitada até 3840 px
printf '%s\n' "$lista" | grep -E '^[^/]+/contents/images/[0-9]+x[0-9]+\.(png|jpg|jpeg)$' | awk -F/ '
{
    split($4, s, /[x.]/); w = s[1] + 0; h = s[2] + 0
    if (w <= h) next
    n = $1
    if (!(n in tw) || w < tw[n]) { tw[n] = w; tp[n] = $0 }
    if (w <= 3840 && (!(n in fw) || w > fw[n])) { fw[n] = w; fp[n] = $0 }
}
END { for (n in tp) print n "\t" tp[n] "\t" ((n in fp) ? fp[n] : tp[n]) }' > "$tmp.lista"

# Autor e licença de cada um (metadata.json), todos ao mesmo tempo: ~5 s em vez de ~45 s
pedacos="$tmp.d"
rm -rf "$pedacos"; mkdir -p "$pedacos"
while IFS="$(printf '\t')" read -r id thumb full; do
    (
        meta=$(curl -fsSL --max-time 15 "$raw/$id/metadata.json" 2>/dev/null |
            jq -r '[(.KPlugin.Name // ""), (.KPlugin.Authors[0].Name // ""), (.KPlugin.License // "")] | @tsv' 2>/dev/null)
        nome=$(printf '%s' "$meta" | cut -f1); autor=$(printf '%s' "$meta" | cut -f2); lic=$(printf '%s' "$meta" | cut -f3)
        printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$id" "${nome:-$id}" "$autor" "$lic" "$raw/$thumb" "$raw/$full" > "$pedacos/$id"
    ) &
done < "$tmp.lista"
wait
cat "$pedacos"/* 2>/dev/null | sort > "$tmp"
rm -rf "$pedacos" "$tmp.lista"
[ -s "$tmp" ] && mv -f "$tmp" "$cache"
cat "$cache" 2>/dev/null
