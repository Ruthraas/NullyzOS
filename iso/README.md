# iso/

Perfil da ISO do NullyzOS, montado por cima do `releng` oficial do archiso.

```sh
sudo pacman -S archiso
sudo iso/build.sh          # → out/nullyzos-AAAA.MM.DD-x86_64.iso
```

| Arquivo | O que é |
|---|---|
| `build.sh` | copia o releng, sobrepõe o que é nosso e roda o `mkarchiso` (trabalho em `/var/tmp`, ~8 GB) |
| `packages.x86_64` | pacotes somados aos do releng (só repositórios oficiais) |
| `airootfs/` | arquivos do sistema live: os-release, issue com o N pixelado, motd, pt-BR e ABNT2 |
| `branding/` | cores do menu de boot e o splash (gerado por `gerar-splash.py`, só biblioteca padrão) |

Testar no VirtualBox: VM nova "Arch Linux (64-bit)", 4 GB de RAM, EFI ligado e desligado (os dois modos precisam dar boot).
