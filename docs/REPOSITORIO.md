# Repositório pacman do NullyzOS (#3)

Tudo o que não existe nos repositórios oficiais do Arch é empacotado aqui e **assinado**. É o que substitui o AUR no NullyzOS. O primeiro pacote é a identidade visual (`nullyzos-branding`); depois vêm o Calamares (#4), o desktop Nullyz e os rices revisados.

## Estrutura

```
packages/
  <pacote>/PKGBUILD     um pacote por pasta (dependências só de repositórios oficiais ou deste)
  build.sh              constrói todos, assina e gera o banco "nullyzos"
  out/                  saída (não versionada)
.github/workflows/repo.yml  CI: constrói num contêiner Arch e publica na release "repo"
```

O CI roda sozinho a cada push na `main` que mexe em `packages/` ou `branding/`, e também à mão (Actions → "repositório pacman" → Run workflow).

## Hospedagem

**GitHub Releases** deste repositório, release com a tag `repo`:
`https://github.com/Ruthraas/NullyzOS/releases/download/repo/`

- Grátis, com HTTPS e sem servidor para manter.
- O GitHub não guarda symlinks em assets: o `build.sh` troca `nullyzos.db`/`nullyzos.files` por cópias reais.
- Cada pacote e o banco têm o `.sig` ao lado.

## Chave

A mesma do projeto Nullyz: **`Nullyz Packages`**, ed25519, válida até 2031-11-15.
**Fingerprint:** `C43C 292B 0901 FB84 D4A1  A174 3682 8706 C86F B94A`
Chave pública: [`docs/nullyz-repo.asc`](nullyz-repo.asc). Confira o fingerprint antes de confiar nela.

### Secrets do GitHub (feito uma vez pelo mantenedor)

Em Settings → Secrets and variables → Actions deste repositório:
- `NULLYZ_GPG_PRIVATE_KEY`: a chave privada armorada (`gpg --armor --export-secret-keys <FINGERPRINT>`). **Nunca** vai para o git.
- `NULLYZ_GPG_KEY`: o fingerprint, sem espaços.

Construir local: `NULLYZ_GPG_KEY=<FINGERPRINT> packages/build.sh`, ou `packages/build.sh --no-sign` só para teste (nunca publicar).

## Usar no seu Arch

```sh
# 1. Confiar na chave (confira o fingerprint acima antes de assinar!)
curl -LO https://raw.githubusercontent.com/Ruthraas/NullyzOS/main/docs/nullyz-repo.asc
sudo pacman-key --add nullyz-repo.asc
sudo pacman-key --finger C43C292B0901FB84D4A1A17436828706C86FB94A
sudo pacman-key --lsign-key C43C292B0901FB84D4A1A17436828706C86FB94A
```

```ini
# 2. /etc/pacman.conf
[nullyzos]
SigLevel = Required DatabaseRequired
Server = https://github.com/Ruthraas/NullyzOS/releases/download/repo
```

```sh
# 3. Instalar
sudo pacman -Sy nullyzos-branding
```

Na ISO e no sistema instalado isso já vem configurado: a chave entra no chaveiro do pacman e o repositório no `pacman.conf`.
