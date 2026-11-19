# Segurança do NullyzOS

## Avisar uma falha

**Não abra issue pública.** Use o aviso privado do GitHub:
[Security → Report a vulnerability](https://github.com/Ruthraas/NullyzOS/security/advisories/new).
Respondemos em até 7 dias e combinamos com você quando publicar a correção.

Vale para o sistema (pacotes, instalador, scripts com root, configurações), o repositório pacman
assinado, a ISO e o site.

## Versões com correção

Recebe correções: a ISO publicada mais recente e os pacotes do repositório (`sudo pacman -Syu`).

## Como o projeto se protege

- Pacotes, banco do repositório e ISO assinados com a chave **Nullyz Packages**
  (`C43C 292B 0901 FB84 D4A1  A174 3682 8706 C86F B94A`, [docs/nullyz-repo.asc](docs/nullyz-repo.asc)).
- Sem AUR e sem `curl | bash`: só repositórios oficiais do Arch e o nosso.
- Código de terceiros fixado por sha256 conferido em duas fontes (ver cada PKGBUILD).
- Ações do GitHub fixadas por commit; a chave privada só existe como secret do CI.
- Ajudantes com root (pkexec) aceitam só argumentos validados e pedem a senha a cada uso.
- Sistema instalado: firewall ligado, root bloqueado, senha de 8+ caracteres, kernel e rede
  endurecidos (`/usr/lib/sysctl.d/50-nullyzos-seguranca.conf`), Wi-Fi com MAC por rede,
  criptografia de disco opcional no instalador e snapshots antes de cada atualização.
- Site: estático, sem cookies, sem rastreamento e sem nada carregado de fora (cabeçalhos em
  `site/_headers`).
