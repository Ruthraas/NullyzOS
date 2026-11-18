-- Programas que sobem com a sessão.
hl.on("hyprland.start", function()
  -- Shell do NullyzOS (barra de menus, dock, busca, notificações, bloqueio); -n impede duas
  -- cópias (cada cópia desenha outra barra e outro dock por cima). Espera o PipeWire
  -- até 5 s: o Quickshell não reconecta se subir antes (lição do Nullyzrice, #38).
  hl.exec_cmd('for i in $(seq 50); do [ -S "$XDG_RUNTIME_DIR/pipewire-0" ] && break; sleep 0.1; done; qs -n -c nullyzos -d')
  -- Agente polkit: pede a senha quando algum app precisa de permissão de administrador.
  hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
  hl.exec_cmd("hyprctl setcursor Adwaita ${XCURSOR_SIZE:-24}")
  -- Pastas do usuário (Imagens, Downloads, Documentos...) na língua do sistema
  hl.exec_cmd("xdg-user-dirs-update")
  -- Histórico da área de transferência (texto e imagens), lido pela busca do shell
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)
