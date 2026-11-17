-- NullyzOS — configuração do Hyprland (0.55+, Lua). Instalada em /usr/share/nullyzos/hypr/.
--
-- Quem usa: o ~/.config/hypr/hyprland.lua criado pelo `nullyzos-hyprland` na primeira sessão
-- (uma linha: dofile deste arquivo). Seus ajustes vão em ~/.config/hypr/nullyzos.lua,
-- carregado no fim; este arquivo é do sistema e é atualizado pelo pacote.

local here = debug.getinfo(1, "S").source:sub(2):match("(.*/)") or "/usr/share/nullyzos/hypr/"
package.path = here .. "?.lua;" .. package.path

require("nullyzos.env")
require("nullyzos.input")
require("nullyzos.look")
require("nullyzos.animations")
require("nullyzos.rules")
require("nullyzos.binds")
require("nullyzos.autostart")

local home = os.getenv("HOME") or ""
local user = home .. "/.config/hypr/nullyzos.lua"
local f = io.open(user, "r")
if f then
  f:close()
  dofile(user)
end
