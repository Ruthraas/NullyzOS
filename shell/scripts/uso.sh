#!/bin/sh
# Uso do sistema para Configurações → Desempenho, uma linha por item:
#   cpu <total> <ocioso>        (contadores de /proc/stat; o shell calcula a % pela diferença)
#   mem <total kB> <disponível kB>
#   disco <usado bytes> <total bytes>
#   temp <maior temperatura em °C ou ->
#   perfil <power-saver|balanced|performance|->
#   cache <bytes ocupados pelos pacotes e assinaturas> <arquivos de pacote>
#   orfaos <quantidade>
#   miniaturas <bytes>
thumbnails_dir() {
    case "${XDG_CACHE_HOME:-}" in
        /*) printf '%s/thumbnails\n' "${XDG_CACHE_HOME%/}" ;;
        *) printf '%s/.cache/thumbnails\n' "$HOME" ;;
    esac
}

if [ "${1:-}" = "--limpar-miniaturas" ]; then
    thumbnails=$(thumbnails_dir)
    [ ! -L "$thumbnails" ] || exit 1
    [ -e "$thumbnails" ] || exit 0
    [ -d "$thumbnails" ] || exit 1
    exec find "$thumbnails" -xdev -mindepth 1 -delete
fi

cache_stats() {
    cache_dirs=$(pacman-conf CacheDir) || return 1
    [ -n "$cache_dirs" ] || return 1
    stats=$(printf '%s\n' "$cache_dirs" | awk '!seen[$0]++' | while IFS= read -r dir; do
        find -H "$dir" -maxdepth 1 -type f \
            \( -name '*.pkg.tar' -o -name '*.pkg.tar.*' \) ! -name '*.part' -printf '%b %f\n' || exit 1
    done) || return 1
    printf '%s\n' "$stats" | awk 'NF { bytes += $1 * 512; if ($0 !~ /[.]sig$/) files++ } END { printf "%.0f %d\n", bytes, files }'
}

awk '/^cpu / { idle = $5 + $6; t = 0; for (i = 2; i <= NF; i++) t += $i; print "cpu", t, idle; exit }' /proc/stat
awk '/^MemTotal/ { t = $2 } /^MemAvailable/ { a = $2 } END { print "mem", t, a }' /proc/meminfo
df -B1 --output=used,size / | awk 'NR == 2 { print "disco", $1, $2 }'
t=-
for f in /sys/class/thermal/thermal_zone*/temp /sys/class/hwmon/hwmon*/temp1_input; do
    [ -r "$f" ] || continue
    v=$(cat "$f" 2>/dev/null) || continue
    v=$((v / 1000))
    if [ "$t" = "-" ] || [ "$v" -gt "$t" ]; then t=$v; fi
done
echo "temp $t"
echo "perfil $(powerprofilesctl get 2>/dev/null || echo -)"
if [ "${1:-}" = "--limpeza" ]; then
    cache=$(cache_stats 2>/dev/null) || cache="-2 0"
    echo "cache $cache"
    echo "orfaos $(pacman -Qtdq 2>/dev/null | wc -l)"
    thumbnails=$(thumbnails_dir)
    if [ -L "$thumbnails" ]; then
        bytes=-2
    elif [ -d "$thumbnails" ]; then
        if blocks=$(find "$thumbnails" -xdev -mindepth 1 -printf '%b\n' 2>/dev/null); then
            bytes=$(printf '%s\n' "$blocks" | awk '{ total += $1 * 512 } END { printf "%.0f\n", total }')
        else
            bytes=-2
        fi
    elif [ -e "$thumbnails" ]; then
        bytes=-2
    else
        bytes=0
    fi
    echo "miniaturas $bytes"
fi
