-- Aparência (docs/IDENTIDADE.md): cantos de janela 14, borda de destaque fina, vidro leve.
-- Modo VM: sem desfoque e sem sombra (por software os dois custam caro).
local lib = require("nullyzos.lib")
local c = lib.colors

hl.config({
  general = {
    layout = "dwindle",
    gaps_in = 5,
    gaps_out = 10,
    border_size = 2,
    col = {
      active_border = { colors = { c.accent, c.accent_soft }, angle = 45 },
      inactive_border = c.border,
    },
    resize_on_border = true,
  },
  decoration = {
    rounding = 14,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    blur = {
      enabled = not lib.vm,
      size = 8,
      passes = 2,
      new_optimizations = true,
      ignore_opacity = true,
      popups = true,
      vibrancy = 0.15,
    },
    shadow = {
      enabled = not lib.vm,
      range = 24,
      render_power = 3,
      color = c.shadow,
    },
  },
  cursor = {
    no_hardware_cursors = lib.vm,
  },
  dwindle = {
    preserve_split = true,
  },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
    background_color = c.bg,
    -- Se o shell morrer com a tela bloqueada, um shell novo pode reassumir o bloqueio.
    allow_session_lock_restore = true,
    -- Sem recarregar sozinho: no meio de uma atualização o pacman troca os arquivos e o
    -- Hyprland lia a config pela metade (modo de emergência). Recarregar: hyprctl reload.
    disable_autoreload = true,
  },
})
