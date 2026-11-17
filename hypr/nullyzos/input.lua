-- Teclado (o que foi escolhido no instalador), mouse e touchpad.
local lib = require("nullyzos.lib")
local layout, variant = lib.keyboard()

hl.config({
  input = {
    kb_layout = layout,
    kb_variant = variant,
    numlock_by_default = true,
    repeat_delay = 300,
    repeat_rate = 35,
    follow_mouse = 1,
    touchpad = {
      natural_scroll = true,
      disable_while_typing = true,
    },
  },
})
