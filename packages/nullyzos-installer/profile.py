"""Perfil do NullyzOS para o instalador oficial archinstall."""

import os
import shutil
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import TYPE_CHECKING, override

from archinstall.default_profiles.profile import Profile, ProfileType

if TYPE_CHECKING:
    from archinstall.lib.installer import Installer

FINGERPRINT = "C43C292B0901FB84D4A1A17436828706C86FB94A"
VALID_DESKTOPS = {"hyprland", "kde"}
VALID_RICES = {
    "nullyz", "nullyz-areia", "nullyz-brasa", "nullyz-cru", "nullyz-mono",
    "nullyz-musgo", "nullyz-ouro", "nullyz-papel", "nullyz-sol", "graphite", "layan",
}


class NullyzOSProfile(Profile):
    def __init__(self) -> None:
        super().__init__("NullyzOS", ProfileType.Custom)

    @override
    def preview_text(self) -> str:
        desktop = os.environ.get("NULLYZ_DESKTOP", "hyprland")
        rice = os.environ.get("NULLYZ_RICE", "nullyz")
        return f"Desktop NullyzOS: {desktop}\nVisual inicial: {rice}"

    @override
    def install(self, install_session: "Installer") -> None:
        desktop = os.environ.get("NULLYZ_DESKTOP", "hyprland")
        rice = os.environ.get("NULLYZ_RICE", "nullyz")
        if desktop not in VALID_DESKTOPS or rice not in VALID_RICES:
            raise ValueError("Seleção inválida do perfil NullyzOS")

        target = install_session.target
        key_dir = target / "usr/share/nullyzos"
        key_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2("/usr/share/nullyzos-installer/nullyz-repo.asc", key_dir / "nullyz-repo.asc")

        pacman_conf = target / "etc/pacman.conf"
        text = pacman_conf.read_text()
        if "[nullyzos]" not in text:
            pacman_conf.write_text(
                text + "\n[nullyzos]\nSigLevel = Required DatabaseRequired\n"
                + "Server = https://github.com/Ruthraas/NullyzOS/releases/download/repo\n"
            )

        install_session.arch_chroot("pacman-key --add /usr/share/nullyzos/nullyz-repo.asc")
        install_session.arch_chroot(f"pacman-key --lsign-key {FINGERPRINT}")
        install_session.arch_chroot("pacman -Sy --noconfirm")
        # O resolvedor do archinstall só conhece os repositórios oficiais carregados no início.
        # Neste ponto o repositório NullyzOS já está assinado, confiado e sincronizado no alvo.
        install_session.arch_chroot(
            f"pacman -S --needed --noconfirm nullyzos-desktop-{desktop} grub efibootmgr"
        )
        install_session.enable_service([
            "NetworkManager", "sddm", "bluetooth", "cups", "ufw",
            "power-profiles-daemon", "fstrim.timer",
        ])

        rice_dir = target / "etc/nullyzos"
        rice_dir.mkdir(parents=True, exist_ok=True)
        (rice_dir / "rice-inicial").write_text(rice + "\n")

        # arch-chroot -S usa um /tmp privado. Um caminho no disco do alvo fica
        # disponível no chroot e é limpo mesmo quando o finalizador falha.
        with TemporaryDirectory(prefix="nullyzos-", dir=target / "var/lib") as work:
            finalizer = Path(work) / "finalizar"
            shutil.copy2("/usr/lib/nullyzos-installer/finalizar-destino", finalizer)
            finalizer.chmod(0o755)
            install_session.arch_chroot(f"/{finalizer.relative_to(target)}")
