-- NullyzOS — configuração do Hyprland (0.55+, Lua). Instalada em /usr/share/nullyzos/hypr/.
--
-- Quem usa: o ~/.config/hypr/hyprland.lua criado pelo `nullyzos-hyprland` na primeira sessão
-- (uma linha: dofile deste arquivo). Seus ajustes vão em ~/.config/hypr/nullyzos.lua,
-- carregado no fim; este arquivo é do sistema e é atualizado pelo pacote.

local here = debug.getinfo(1, "S").source:sub(2):match("(.*/)") or "/usr/share/nullyzos/hypr/"
package.path = here .. "?.lua;" .. package.path

require("nullyzos.env")
require("nullyzos.monitors")
require("nullyzos.input")
require("nullyzos.look")
require("nullyzos.animations")
require("nullyzos.rules")
require("nullyzos.binds")
require("nullyzos.autostart")

-- Depois do sistema: o que as Configurações gravaram (teclado, mouse, monitores) e, por
-- último, os ajustes à mão do usuário (valem por cima de tudo).
local home = os.getenv("HOME") or ""
local config = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
for _, file in ipairs({ config .. "/nullyzos/hyprland.lua", home .. "/.config/hypr/nullyzos.lua" }) do
  local f = io.open(file, "r")
  if f then
    f:close()
    dofile(file)
  end
end
