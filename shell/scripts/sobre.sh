#!/bin/sh
# Dados da página Sobre, um por linha: versão, computador, processador, memória, vídeo, kernel.
pacman -Q nullyzos-desktop-hyprland 2>/dev/null | cut -d' ' -f2 | sed 's/-[0-9]*$//'
cat /etc/hostname 2>/dev/null || uname -n
grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ *//; s/([RT]M)//g; s/  */ /g'
awk '/MemTotal/ { printf "%.0f GB\n", $2 / 1048576 }' /proc/meminfo
gpu=""
for f in /sys/class/drm/card*/device/vendor; do
    [ -r "$f" ] || continue
    case $(cat "$f") in
        0x8086) gpu="Intel" ;; 0x10de) gpu="NVIDIA" ;; 0x1002) gpu="AMD" ;;
        0x15ad) gpu="VMware (máquina virtual)" ;; 0x80ee) gpu="VirtualBox (máquina virtual)" ;;
        0x1af4|0x1234) gpu="Virtual (QEMU)" ;;
    esac
    [ -n "$gpu" ] && break
done
echo "${gpu:-—}"
uname -r
