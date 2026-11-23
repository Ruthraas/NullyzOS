# installer/

Assistente em terminal baseado no `archinstall` oficial. O NullyzOS seleciona desktop e rice;
o editor do Arch cuida de disco, `/boot/efi`, criptografia, usuário, rede e bootloader.

A ISO verifica o índice assinado do NullyzOS antes de abrir o particionamento. O log de
diagnóstico fica em `/root/nullyzos-instalacao.log` no sistema live.

O perfil, o assistente e o catálogo de visuais ficam no pacote [nullyzos-installer](../packages/nullyzos-installer).
