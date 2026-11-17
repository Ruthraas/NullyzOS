-- Movimento (docs/IDENTIDADE.md): entrada com leve overshoot, saída mais rápida que a entrada.
-- speed em decissegundos. Modo VM: tudo mais curto.
local lib = require("nullyzos.lib")
local k = lib.vm and 0.6 or 1
local function s(ds) return math.max(1, ds * k) end

hl.curve("nz_out", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("nz_in", { type = "bezier", points = { { 0.55, 0 }, { 1, 0.45 } } })
hl.curve("nz_over", { type = "bezier", points = { { 0.34, 1.3 }, { 0.64, 1 } } })
hl.curve("nz_std", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })

hl.animation({ leaf = "windowsIn", enabled = true, speed = s(4), bezier = "nz_over", style = "popin 88%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = s(2.5), bezier = "nz_in", style = "popin 92%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = s(4), bezier = "nz_std" })
hl.animation({ leaf = "border", enabled = true, speed = s(5), bezier = "nz_out" })
hl.animation({ leaf = "fade", enabled = true, speed = s(3), bezier = "nz_out" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = s(2), bezier = "nz_in" })
hl.animation({ leaf = "layersIn", enabled = true, speed = s(3), bezier = "nz_over", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = s(2), bezier = "nz_in", style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = s(4.2), bezier = "nz_std", style = "slidefade 12%" })
