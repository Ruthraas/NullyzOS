-- Atalhos. O Super é a tecla do sistema.
local lib = require("nullyzos.lib")
local exec = hl.dsp.exec_cmd
local sh = lib.shell

-- Nomes de tecla como no XKB ("space", "Return"): "Space" não casa com a tecla.
-- Sistema e apps
local launcher = exec(sh("toggleLauncher"))
hl.bind("SUPER + space", launcher, { description = "Buscar apps" })
for _, key in ipairs({ "Super_L", "Super_R" }) do
  hl.bind(key, launcher, { release = true, description = "Buscar apps ao soltar Super" })
end
hl.bind("SUPER + L", exec(sh("lock")), { description = "Bloquear a tela" })
hl.bind("SUPER + comma", exec(sh("settings")), { description = "Configurações" })
local function cycleWindow(next)
  local active = hl.get_active_window()
  local special = hl.get_active_special_workspace()
  local windows, current = {}, nil
  for _, window in ipairs(hl.get_windows()) do
    local workspace = window.workspace
    if window.mapped and not window.hidden and workspace
        and (not workspace.special or (special and workspace.id == special.id)) then
      windows[#windows + 1] = window
      if active and window.address == active.address then current = #windows end
    end
  end
  if #windows == 0 then return end
  local step = next and 1 or -1
  local index = current and ((current - 1 + step) % #windows + 1) or (next and 1 or #windows)
  local target = windows[index]
  hl.dispatch(hl.dsp.focus({ window = target }))
  hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top", window = target }))
end
hl.bind("ALT + Tab", function() cycleWindow(true) end, { description = "Próxima janela" })
hl.bind("ALT + SHIFT + Tab", function() cycleWindow(false) end, { description = "Janela anterior" })
hl.bind("SUPER + Tab", exec(sh("overview")), { description = "Visão geral dos workspaces" })
hl.bind("SUPER + SHIFT + V", exec(sh("clipboard")), { description = "Histórico da área de transferência" })
hl.bind("SUPER + period", exec(sh("emoji")), { description = "Emoji" })
hl.bind("SUPER + Return", exec(lib.apps.terminal), { description = "Terminal" })
hl.bind("SUPER + E", exec(lib.apps.files), { description = "Arquivos" })

-- Janelas
hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Fechar janela" })
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Tela cheia" })
hl.bind("SUPER + M", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Maximizar" })
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }), { description = "Soltar/encaixar janela" })
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

local names = { l = "esquerda", r = "direita", u = "cima", d = "baixo" }
for key, dir in pairs({ Left = "l", Right = "r", Up = "u", Down = "d" }) do
  hl.bind("SUPER + " .. key, hl.dsp.focus({ direction = dir }), { description = "Foco para " .. names[dir] })
  hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }), { description = "Mover para " .. names[dir] })
end

-- Workspaces 1–10
for i = 1, 10 do
  local key = tostring(i % 10)
  local ws = tostring(i)
  hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = ws }), { description = "Workspace " .. ws })
  hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws, follow = false }),
    { description = "Mandar janela ao workspace " .. ws })
end
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Próximo workspace" })
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "Workspace anterior" })

-- Volume e brilho (também com a tela bloqueada)
local lr = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", exec("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), lr)
hl.bind("XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), lr)
hl.bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", exec("brightnessctl set 5%+ && " .. sh("osdBrightness")), lr)
hl.bind("XF86MonBrightnessDown", exec("brightnessctl set 5%- && " .. sh("osdBrightness")), lr)

-- Captura de tela (grim + slurp + wl-clipboard)
hl.bind("Print", exec("grim - | wl-copy"), { description = "Capturar a tela" })
hl.bind("SUPER + SHIFT + S", exec('grim -g "$(slurp)" - | satty --filename - --early-exit --copy-command wl-copy --output-filename "$(xdg-user-dir PICTURES)/captura-$(date +%Y%m%d-%H%M%S).png"'),
  { description = "Capturar uma área (e editar)" })

-- Sessão
hl.bind("SUPER + SHIFT + Escape", hl.dsp.exit(), { description = "Sair da sessão" })
