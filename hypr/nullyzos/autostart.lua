-- Programas que sobem com a sessão.
hl.on("hyprland.start", function()
  -- Shell do NullyzOS (barra de menus, dock, busca, notificações, bloqueio). Espera o PipeWire
  -- até 5 s: o Quickshell não reconecta se subir antes (lição do Nullyzrice, #38).
  hl.exec_cmd('for i in $(seq 50); do [ -S "$XDG_RUNTIME_DIR/pipewire-0" ] && break; sleep 0.1; done; qs -c nullyzos -d')
  -- Agente polkit: pede a senha quando algum app precisa de permissão de administrador.
  hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
  hl.exec_cmd("hyprctl setcursor Adwaita 24")
end)
