#!/bin/sh
# Estado do Bluetooth para Configurações → Bluetooth, uma linha por item:
#   power yes|no|none          (none = sem adaptador ou serviço desligado)
#   dev <MAC> <pareado 0/1> <conectado 0/1> <nome>
#   bluetooth.sh acao <power-on|power-off|scan|connect MAC|disconnect MAC|remove MAC>
if [ "${1:-}" = acao ]; then
    case "${2:-}" in
        power-on) bluetoothctl power on ;;
        power-off) bluetoothctl power off ;;
        scan) bluetoothctl --timeout 12 scan on >/dev/null ;;
        connect) bluetoothctl pair "$3"; bluetoothctl trust "$3"; bluetoothctl connect "$3" ;;
        disconnect) bluetoothctl disconnect "$3" ;;
        remove) bluetoothctl remove "$3" ;;
    esac
    exit 0
fi
command -v bluetoothctl >/dev/null 2>&1 || { echo "power none"; exit 0; }
p=$(timeout 3 bluetoothctl show 2>/dev/null | awk '/Powered:/ { print $2 }')
echo "power ${p:-none}"
[ -n "$p" ] || exit 0
timeout 3 bluetoothctl devices 2>/dev/null | while read -r _ mac nome; do
    info=$(timeout 2 bluetoothctl info "$mac" 2>/dev/null)
    par=0; con=0
    echo "$info" | grep -q "Paired: yes" && par=1
    echo "$info" | grep -q "Connected: yes" && con=1
    echo "dev $mac $par $con $nome"
done
