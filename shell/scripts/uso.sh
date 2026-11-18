#!/bin/sh
# Uso do sistema para Configurações → Desempenho, uma linha por item:
#   cpu <total> <ocioso>        (contadores de /proc/stat; o shell calcula a % pela diferença)
#   mem <total kB> <disponível kB>
#   disco <usado bytes> <total bytes>
#   temp <maior temperatura em °C ou ->
#   perfil <power-saver|balanced|performance|->
#   cache <bytes do cache do pacman> <arquivos>
#   orfaos <quantidade>
#   miniaturas <bytes>
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
    echo "cache $(du -sb /var/cache/pacman/pkg 2>/dev/null | cut -f1) $(find /var/cache/pacman/pkg -maxdepth 1 -name '*.pkg.tar*' ! -name '*.sig' 2>/dev/null | wc -l)"
    echo "orfaos $(pacman -Qtdq 2>/dev/null | wc -l)"
    echo "miniaturas $(du -sb "$HOME/.cache/thumbnails" 2>/dev/null | cut -f1 || echo 0)"
fi
