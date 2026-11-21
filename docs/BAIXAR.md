# Baixar e instalar o NullyzOS

Sistema baseado em Arch Linux, com Hyprland ou KDE Plasma e o visual Nullyz. **Primeira versão pública:** tenha backup dos seus arquivos antes de instalar.

## O que vem nesta página

| Arquivo | Para que serve |
|---|---|
| `NullyzOS.iso` | a imagem do sistema (grave num pendrive) |
| `NullyzOS.iso.sig` | assinatura GPG da ISO |
| `SHA256SUMS` e `SHA256SUMS.asc` | soma de conferência e a mesma lista assinada |

Baixe **só** do GitHub do projeto (`github.com/Ruthraas/NullyzOS/releases`) ou dos espelhos listados no site oficial. Cópia de outro lugar pode ter sido alterada: confira sempre (abaixo).

## Requisitos

- PC 64 bits (x86_64), **UEFI** (recomendado) ou BIOS antigo
- 4 GB de RAM (8 GB recomendado), 30 GB de disco
- Internet durante a instalação (baixa o navegador e as últimas atualizações)
- Máquina virtual: com o **Hyprland**, ligue a aceleração 3D (VirtualBox: Tela → Habilitar aceleração 3D). Sem 3D, escolha o KDE.

## 1. Confira o download (importante)

A conta da ISO tem de bater com a do `SHA256SUMS`. Isso garante que o arquivo chegou inteiro e é o mesmo publicado.

**Linux / macOS**
```
sha256sum -c SHA256SUMS
```
**Windows (PowerShell)**
```
Get-FileHash .\NullyzOS.iso -Algorithm SHA256
```
e compare com o número dentro de `SHA256SUMS`.

**Assinatura (opcional, mais forte):** prova que a ISO foi publicada pelo projeto.
```
gpg --import nullyz-repo.asc          # chave em docs/nullyz-repo.asc
gpg --verify NullyzOS.iso.sig NullyzOS.iso
```
Tem de aparecer **Good signature** da chave `Nullyz Packages`, fingerprint
`C43C 292B 0901 FB84 D4A1  A174 3682 8706 C86F B94A`.

## 2. Grave num pendrive (8 GB ou mais)

Apaga tudo o que estiver no pendrive.
- **Windows:** [Rufus](https://rufus.ie) (modo "DD" se ele perguntar) ou [Ventoy](https://www.ventoy.net)
- **Linux / macOS:** [Fedora Media Writer](https://github.com/FedoraQt/MediaWriter), Ventoy ou
  `sudo dd if=NullyzOS.iso of=/dev/sdX bs=4M status=progress oflag=sync`

## 3. Instale

1. Ligue o PC pelo pendrive (tecla do menu de boot: F12, F8, F11 ou Esc, depende da marca).
2. O instalador abre sozinho. Escolha idioma, teclado, o **desktop** (Hyprland ou KDE) e o **visual** (Nullyz ou um rice).
3. Disco: "Apagar disco" faz tudo sozinho. Marque **Criptografar o sistema** para proteger seus arquivos se o PC for roubado ou perdido (vai pedir a senha ao ligar). A caixa fica embaixo, acima das barras do disco. Na frase use só letras, números e hífen: a tela que pede essa senha ao ligar usa o teclado americano, e ç, acentos e alguns símbolos saem em outras teclas.
4. Crie seu usuário (senha com 8 caracteres ou mais) e confirme.

Secure Boot: desligue na BIOS por enquanto (o NullyzOS ainda não é assinado para ele).

## Segurança que já vem ligada

- Firewall ligado (bloqueia conexões de fora)
- Pacotes e ISO assinados; sem AUR e sem scripts da internet
- Kernel e rede endurecidos; Wi-Fi sem rastrear o aparelho entre redes
- Snapshot antes de cada atualização e de cada troca de rice (dá para voltar pelo menu do boot)
- Conta root bloqueada: administração pela sua senha (sudo)

## Problemas?

Abra uma issue em `github.com/Ruthraas/NullyzOS/issues` com o modelo do PC e o que aconteceu.
