-- Variáveis de ambiente da sessão.
local lib = require("nullyzos.lib")

-- Apps Qt/KDE seguem o esquema de cores Nullyz do kdeglobals (plasma-integration, #16)
hl.env("QT_QPA_PLATFORMTHEME", "kde")
-- Apps Qt Quick (pedido de senha, partições…) no mesmo esquema, em vez do estilo claro padrão
hl.env("QT_QUICK_CONTROLS_STYLE", "org.kde.desktop")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Adwaita")
hl.env("HYPRCURSOR_SIZE", "24")

-- Modo VM: os apps não conseguem criar superfície EGL no VirtualBox, então desenham por
-- software; o Qt Quick usa o rasterizador próprio (bem mais leve que emular OpenGL).
-- Lição do Nullyzrice (#62/#28): shell de ~600 para ~200 MiB na VM.
if lib.vm then
  hl.env("LIBGL_ALWAYS_SOFTWARE", "1")
  hl.env("QT_QUICK_BACKEND", "software")
end
