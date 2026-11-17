-- Monitores: resolução preferida, posição automática. Na VM a escala fica em 1: sem regra o
-- Hyprland calcula pelo tamanho físico que o VirtualBox informa e ampliava tudo ~2x.
-- Ajuste o seu em ~/.config/hypr/nullyzos.lua, por exemplo:
--   hl.monitor({ output = "DP-1", mode = "2560x1440@165", position = "0x0", scale = 1.25 })
local lib = require("nullyzos.lib")

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = lib.vm and 1 or "auto" })
