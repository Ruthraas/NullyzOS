-- Utilitários e tokens visuais (branding/tokens.json, papéis do tema escuro).
local M = {}

M.vm = os.getenv("NULLYZ_VM") == "1"          -- exportado pelo nullyzos-hyprland

M.apps = {
  terminal = "kitty",
  files = "dolphin",
}

-- Cores no formato do Hyprland (rgba(rrggbbaa)).
M.colors = {
  bg = "rgba(0e0e13ff)",
  border = "rgba(2b2b37ff)",
  accent = "rgba(9d8cffff)",
  accent_soft = "rgba(9d8cff66)",
  shadow = "rgba(00000077)",
}

-- Chama uma função do shell (Quickshell, config "nullyzos") por IPC.
function M.shell(fn)
  return "qs -c nullyzos ipc call nullyzos " .. fn
end

-- Teclado escolhido no instalador (o Calamares grava no formato do X11).
function M.keyboard()
  local layout, variant = "br", ""
  local f = io.open("/etc/X11/xorg.conf.d/00-keyboard.conf", "r")
  if f then
    local text = f:read("*a")
    f:close()
    layout = text:match('XkbLayout"%s+"([^"]+)"') or layout
    variant = text:match('XkbVariant"%s+"([^"]*)"') or variant
  end
  return layout, variant
end

return M
