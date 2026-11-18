#!/usr/bin/env python3
"""Verificador das receitas de rice (rices/<id>/rice.toml) e gerador do catálogo.

Regras (docs/VISAO.md, #9):
  - campos obrigatórios; id = nome da pasta; desktop hyprland|kde; licença conhecida;
  - tipo "preset": só muda preferências do Nullyz (chaves e valores conferidos);
  - tipo "arquivos" (rice de terceiro): commit fixo (40 hex) e sha256 do pacote do commit,
    link do aviso ao autor, pacotes só dos repositórios oficiais do Arch ou do nullyz, e
    arquivos copiados só para dentro de ~/.config ou ~/.local/share. Nada de script.

Gera:
  rices/catalogo.json                                      (lido pelo shell e pelo aplicador)
  packages/nullyzos-installer/modules/packagechooser-visual.conf   (passo "Visual" do instalador)

Uso: check-rices.py             confere e (re)gera os arquivos
     check-rices.py --verificar confere e falha se os gerados estiverem desatualizados (CI)
     --offline                  não consulta archlinux.org para os pacotes
"""
import json
import re
import sys
import tomllib
import urllib.request
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
RICES = RAIZ / "rices"
CATALOGO = RICES / "catalogo.json"
VISUAL = RAIZ / "packages/nullyzos-installer/modules/packagechooser-visual.conf"
CONTEXTO = RAIZ / "packages/nullyzos-installer/modules/contextualprocess-rice.conf"

LICENCAS = re.compile(r"^(MIT|ISC|Unlicense|CC0-1\.0|0BSD|BSD-[23]-Clause|Apache-2\.0|MPL-2\.0|"
                      r"(L|A)?GPL-[23]\.0(-only|-or-later)?|CC-BY(-SA)?-4\.0)$")
ID = re.compile(r"^[a-z0-9][a-z0-9-]{1,40}$")
PACOTE = re.compile(r"^[a-z0-9@._+-]+$")

# Preferências que um preset pode mudar, com os valores aceitos (lista) ou o tipo e a faixa.
PREFS = {
    "theme": ["escuro", "claro", "auto"],
    "accent": ["violeta", "azul", "ciano", "verde", "coral", "rosa", "auto", "tema"],
    "palette": ["", "nulo", "papel", "ouro", "brasa", "cru", "areia", "musgo", "sol"],
    "glassOpacity": (float, 0.2, 1),
    "roundness": (float, 0, 1.6),
    "motion": (float, 0, 1.6),
    "barSize": ["compacta", "normal", "alta"],
    "barStyle": ["classica", "flutuante", "ilhas", "semfundo"],
    "dockStyle": ["vidro", "solido", "transparente"],
    "dockIndicator": ["ponto", "traco", "nenhum"],
    "dockMagnify": (float, 0, 1),
    "dockPosition": ["esquerda", "baixo", "direita"],
    "dockIcon": (int, 32, 72),
    "uiFont": ["Geist", "Geist Mono", "Noto Sans", "Inter"],
    "wallpaper": [""],
    "showLogo": (bool,), "showWorkspaces": (bool,), "showDate": (bool,), "clockSeconds": (bool,),
}
# KDE: esquema de cores do Plasma (plasma/gerar.py faz um por paleta)
KDE = {
    "colorscheme": ["NullyzEscuro", "NullyzClaro", "NullyzNulo", "NullyzPapel", "NullyzOuro", "NullyzBrasa",
                    "NullyzCru", "NullyzAreia", "NullyzMusgo", "NullyzSol"],
}
HYPR = {
    "gaps": ["", "compacto", "normal", "amplo"],
    "rounding": (int, -1, 30),
    "animations": (bool,), "blur": (bool,), "shadow": (bool,),
}

erros = []


def erro(rid, msg):
    erros.append(f"{rid}: {msg}")


def confere_valor(rid, tabela, regras, dados):
    for k, v in dados.items():
        if k not in regras:
            erro(rid, f"[{tabela}] chave não permitida: {k}")
            continue
        r = regras[k]
        if isinstance(r, list):
            if v not in r:
                erro(rid, f"[{tabela}] {k} = {v!r} (aceitos: {r})")
        elif r[0] is bool:
            if not isinstance(v, bool):
                erro(rid, f"[{tabela}] {k} precisa ser true/false")
        else:
            tipo, lo, hi = r
            if isinstance(v, bool) or not isinstance(v, (int, float)) or (tipo is int and not isinstance(v, int)):
                erro(rid, f"[{tabela}] {k} precisa ser {tipo.__name__}")
            elif not lo <= v <= hi:
                erro(rid, f"[{tabela}] {k} = {v} fora de {lo}..{hi}")


def pacote_existe(nome, offline):
    if (RAIZ / "packages" / nome).is_dir():
        return True
    if offline:
        return True
    url = f"https://archlinux.org/packages/search/json/?name={nome}"
    with urllib.request.urlopen(url, timeout=20) as r:
        dados = json.load(r)
    return any(p["repo"] in ("core", "extra", "multilib") for p in dados.get("results", []))


def caminho_destino_ok(p):
    return (p.startswith("~/.config/") or p.startswith("~/.local/share/")) and ".." not in p.split("/")


def le(pasta, offline):
    rid = pasta.name
    try:
        r = tomllib.loads((pasta / "rice.toml").read_text(encoding="utf-8"))
    except Exception as e:  # noqa: BLE001
        erro(rid, f"rice.toml inválido: {e}")
        return None
    for campo in ("id", "nome", "descricao", "autor", "licenca", "origem", "desktop", "tipo"):
        if not isinstance(r.get(campo), str) or not r[campo].strip():
            erro(rid, f"falta o campo {campo}")
    if erros and erros[-1].startswith(rid + ": falta"):
        return None
    if r["id"] != rid or not ID.match(rid):
        erro(rid, "id precisa ser igual ao nome da pasta (minúsculas, números e -)")
    if r["desktop"] not in ("hyprland", "kde", "ambos"):
        erro(rid, "desktop precisa ser hyprland, kde ou ambos")
    if r["desktop"] in ("kde", "ambos") and r.get("tipo") == "preset" and "colorscheme" not in r.get("kde", {}):
        erro(rid, "rice de KDE precisa de [kde] colorscheme")
    if not LICENCAS.match(r["licenca"]):
        erro(rid, f"licença não aceita: {r['licenca']} (precisa permitir redistribuir)")
    if not r["origem"].startswith("https://"):
        erro(rid, "origem precisa ser um link https")
    terceiro = r["autor"] != "NullyzOS"
    if terceiro and not str(r.get("aviso", "")).startswith("https://"):
        erro(rid, "rice de terceiro precisa do link do aviso ao autor (campo aviso)")

    if r["tipo"] == "preset":
        confere_valor(rid, "preferencias", PREFS, r.get("preferencias", {}))
        confere_valor(rid, "hyprland", HYPR, r.get("hyprland", {}))
        confere_valor(rid, "kde", KDE, r.get("kde", {}))
        for proibido in ("pacotes", "arquivos", "commit"):
            if proibido in r:
                erro(rid, f"preset não usa {proibido}")
    elif r["tipo"] == "arquivos":
        if not re.fullmatch(r"[0-9a-f]{40}", str(r.get("commit", ""))):
            erro(rid, "commit precisa ser o hash completo (40 caracteres)")
        if not re.fullmatch(r"[0-9a-f]{64}", str(r.get("sha256", ""))):
            erro(rid, "sha256 do pacote do commit é obrigatório")
        if not r["origem"].startswith("https://github.com/"):
            erro(rid, "por enquanto só repositórios do GitHub (baixa o commit exato)")
        for p in r.get("pacotes", []):
            if not PACOTE.match(p):
                erro(rid, f"nome de pacote estranho: {p}")
            elif not pacote_existe(p, offline):
                erro(rid, f"pacote fora dos repositórios oficiais e do nullyz: {p}")
        arqs = r.get("arquivos", [])
        if not arqs:
            erro(rid, "lista [[arquivos]] vazia")
        for a in arqs:
            de, para = str(a.get("de", "")), str(a.get("para", ""))
            if not de or de.startswith("/") or ".." in de.split("/"):
                erro(rid, f"origem de arquivo inválida: {de!r}")
            if not caminho_destino_ok(para):
                erro(rid, f"destino só dentro de ~/.config ou ~/.local/share: {para!r}")
    else:
        erro(rid, "tipo precisa ser preset ou arquivos")
    return r


def visual_conf(cat):
    linhas = [
        "# GERADO por scripts/check-rices.py a partir de rices/*/rice.toml. Não edite à mão.",
        "# Passo \"Visual\" do instalador: o rice que entra no primeiro login (só o do desktop",
        "# escolhido é aplicado; os outros ficam para a página Rices das Configurações).",
        "---",
        "mode: required",
        "method: legacy",
        "id: visual",
        "labels:",
        "    step: \"Visual\"",
        "default: nullyz",
        "items:",
    ]
    for r in cat:
        quem = "" if r["autor"] == "NullyzOS" else f" Por {r['autor']} ({r['licenca']})."
        so = {"hyprland": " Só Hyprland.", "kde": " Só KDE."}.get(r["desktop"], "") if r["id"] != "nullyz" else ""
        desc = (r["descricao"] + so + quem).replace('"', "'")
        linhas += [
            f"    - id: {r['id']}",
            f"      name: \"{r['nome']}\"",
            f"      description: \"{desc}\"",
            f"      screenshot: \"/etc/calamares/branding/nullyzos/rice-{r['id']}.png\"",
        ]
    return "\n".join(linhas) + "\n"


def contexto_conf(cat):
    linhas = [
        "# GERADO por scripts/check-rices.py a partir de rices/*/rice.toml. Não edite à mão.",
        "# Um comando por rice do passo Visual (chave packagechooser_visual do Calamares):",
        "# anota o escolhido para o primeiro login. O Nullyz padrão não precisa de nada.",
        "---",
        "dontChroot: false",
        "timeout: 60",
        "packagechooser_visual:",
    ]
    for r in cat:
        if r["id"] != "nullyz":
            linhas.append(f"    {r['id']}: \"-/usr/lib/nullyzos-installer/rice-inicial {r['id']}\"")
    return "\n".join(linhas) + "\n"


def main():
    offline = "--offline" in sys.argv
    verificar = "--verificar" in sys.argv
    cat = []
    for pasta in sorted(p for p in RICES.iterdir() if p.is_dir()):
        r = le(pasta, offline)
        if r:
            cat.append(r)
    # Nullyz sempre primeiro
    cat.sort(key=lambda r: (r["id"] != "nullyz", r["autor"] != "NullyzOS", r["nome"]))
    if erros:
        print("\n".join("ERRO: " + e for e in erros))
        print(f"{len(cat)} receita(s), {len(erros)} problema(s)")
        sys.exit(1)

    gerados = {
        CATALOGO: json.dumps(cat, ensure_ascii=False, indent=2) + "\n",
        VISUAL: visual_conf(cat),
        CONTEXTO: contexto_conf(cat),
    }
    velhos = [p for p, t in gerados.items() if not p.exists() or p.read_text(encoding="utf-8") != t]
    if verificar and velhos:
        print("ERRO: arquivos gerados desatualizados (rode scripts/check-rices.py):",
              ", ".join(str(p.relative_to(RAIZ)) for p in velhos))
        sys.exit(1)
    for p in velhos:
        p.write_text(gerados[p], encoding="utf-8", newline="\n")
    print(f"{len(cat)} receita(s) ok" + (f"; gerado: {len(velhos)} arquivo(s)" if velhos else ""))


if __name__ == "__main__":
    main()
