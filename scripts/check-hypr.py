#!/usr/bin/env python3
"""Executa a config Lua do Hyprland do NullyzOS contra uma API `hl` simulada.

Não substitui o Hyprland de verdade, mas pega: erro de sintaxe, require quebrado, atalho
duplicado, folha de animação inexistente, curva não declarada e falta de autostart.
Roda duas vezes: máquina normal e modo VM (NULLYZ_VM=1).

Uso: python scripts/check-hypr.py   (precisa de `pip install lupa`). Veio do Nullyzrice.
"""
from __future__ import annotations

import sys
from pathlib import Path

try:
    import lupa  # type: ignore
except ImportError:
    print("instale o lupa: pip install lupa", file=sys.stderr)
    sys.exit(2)

REPO = Path(__file__).resolve().parents[1]

ANIM_LEAVES = {
    "global", "windows", "windowsIn", "windowsOut", "windowsMove", "layers", "layersIn", "layersOut",
    "fade", "fadeIn", "fadeOut", "fadeSwitch", "fadeShadow", "fadeDim", "fadeLayers", "fadeLayersIn",
    "fadeLayersOut", "fadePopups", "fadeDpms", "border", "borderangle", "workspaces", "workspacesIn",
    "workspacesOut", "specialWorkspace", "specialWorkspaceIn", "specialWorkspaceOut", "zoomFactor",
    "monitorAdded",
}

MOCK = r"""
calls = { binds = {}, curves = {}, anims = {}, config = {}, rules = {}, layer_rules = {}, env = {}, on = {} }
local function dsp(name) return function(arg) return { dsp = name, arg = arg } end end
local function ns(prefix)
  return setmetatable({}, { __index = function(_, k) return dsp(prefix .. k) end })
end
hl = { dsp = setmetatable({ window = ns("window."), workspace = ns("workspace.") },
  { __index = function(_, k) return dsp(k) end }) }
function hl.bind(keys, action, flags)
  assert(type(keys) == "string", "bind: tecla precisa ser string")
  assert(type(action) == "table" or type(action) == "function", "bind " .. keys .. ": ação inválida")
  table.insert(calls.binds, keys)
end
function hl.curve(name, def) assert(def.type == "bezier" or def.type == "spring"); calls.curves[name] = true end
function hl.animation(a) table.insert(calls.anims, a) end
local function merge(dst, src)
  for k, v in pairs(src) do
    if type(v) == "table" and type(dst[k]) == "table" and not v.colors then merge(dst[k], v) else dst[k] = v end
  end
end
function hl.config(t) merge(calls.config, t) end
function hl.window_rule(r) assert(r.match, "window_rule sem match"); table.insert(calls.rules, r) end
function hl.layer_rule(r) assert(r.match and r.match.namespace, "layer_rule sem namespace"); table.insert(calls.layer_rules, r) end
function hl.env(k, v) calls.env[k] = v end
function hl.on(ev, fn) calls.on[ev] = fn end
function hl.exec_cmd(c) end
"""


def run(vm: bool) -> list[str]:
    tag = "vm" if vm else "normal"
    lua = lupa.LuaRuntime(unpack_returned_tuples=True)
    env_vm = '"1"' if vm else "nil"
    lua.execute('os.getenv = function(k) if k == "HOME" then return "/nao/existe" end '
                f'if k == "NULLYZ_VM" then return {env_vm} end return nil end')
    lua.execute(MOCK)
    try:
        lua.execute(f"dofile([[{(REPO / 'hypr' / 'hyprland.lua').as_posix()}]])")
    except lupa.LuaError as e:
        return [f"[{tag}] erro Lua: {e}"]
    calls = lua.globals().calls
    errors: list[str] = []
    binds = list(calls.binds.values())
    dup = {b for b in binds if binds.count(b) > 1}
    if dup:
        errors.append(f"[{tag}] atalhos duplicados: {sorted(dup)}")
    for a in calls.anims.values():
        if a.leaf not in ANIM_LEAVES:
            errors.append(f"[{tag}] folha de animação desconhecida: {a.leaf}")
        if a.bezier and not calls.curves[a.bezier]:
            errors.append(f"[{tag}] curva não declarada: {a.bezier}")
    cfg = calls.config
    if not cfg.general or not cfg.decoration:
        errors.append(f"[{tag}] general/decoration não configurados")
    if not calls.on["hyprland.start"]:
        errors.append(f"[{tag}] sem autostart")
    sw = calls.env["LIBGL_ALWAYS_SOFTWARE"]
    if vm != (sw == "1"):
        errors.append(f"[{tag}] desenho por software no modo errado")
    if cfg.decoration and bool(cfg.decoration.blur.enabled) == vm:
        errors.append(f"[{tag}] desfoque deveria estar {'desligado' if vm else 'ligado'}")
    print(f"[{tag}] {len(binds)} atalhos, {len(list(calls.anims.values()))} animações, "
          f"{len(list(calls.rules.values()))} regras de janela, {len(list(calls.layer_rules.values()))} de camada")
    return errors


def main() -> int:
    errs = run(False) + run(True)
    for e in errs:
        print("ERRO:", e)
    print("ok" if not errs else f"{len(errs)} problema(s)")
    return 1 if errs else 0


if __name__ == "__main__":
    sys.exit(main())
