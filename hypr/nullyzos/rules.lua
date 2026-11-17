-- Regras de janela e de camada.
local lib = require("nullyzos.lib")

-- Diálogos e utilitários flutuam, centralizados.
local dialogs = {
  { class = "^(pavucontrol|org.pulseaudio.pavucontrol|nm-connection-editor|org.kde.polkit-kde-authentication-agent-1)$" },
  { title = "^(Open File|Save File|Abrir arquivo|Salvar arquivo|Select a File|Choose Files).*$" },
}
for _, m in ipairs(dialogs) do
  hl.window_rule({ match = m, float = true, center = true })
end
hl.window_rule({ match = { title = "^(Picture-in-Picture|Imagem em imagem)$" }, float = true, pin = true })

-- Camadas do shell: vidro onde há fundo translúcido (fora do modo VM).
if not lib.vm then
  hl.layer_rule({
    match = { namespace = "nullyzos-(menubar|dock|launcher|notifications)" },
    blur = true,
    ignore_alpha = 0.35,
  })
end
hl.layer_rule({ match = { namespace = "nullyzos-launcher" }, animation = "popin 94%" })
hl.layer_rule({ match = { namespace = "nullyzos-wallpaper" }, no_anim = true })
