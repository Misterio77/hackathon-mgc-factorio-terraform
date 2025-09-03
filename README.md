# Factorio declarativo via Terraform + NixOS

Leia o write-up completo em TODO

## Requisitos

- [OpenTofu](https://opentofu.org/docs/intro/install/)
- [Nix](https://nixos.org/download) 
- Uma conta na [Magalu Cloud](https://magalu.cloud/)
- (Opcional) [MGC CLI](https://docs.magalu.cloud/docs/devops-tools/cli-mgc/overview/)

## Como funciona

Esse repositório contém uma configuração de NixOS (`configuration.nix`, `hardware-configuration.nix`) exportada num flake (`flake.nix`), e um código terraform (`main.tf`, `vm.tf`, `ip.tf`, `firewall.tf`, `nixos.tf`) para subir uma VM rodando essa configuração. Isso é feito utilizando [nixos-anywhere](https://github.com/nix-community/nixos-anywhere).

A chave SSH usada para aplicar a configuração é gerada pelo próprio terraform e passada para o nixos-anywhere. Você também pode incluir sua própria chave em `configuration.nix`.

## Como usar

Obtenha uma chave de API do magalu:
```
mgc auth api-key create --name terraform-factorio
```

E disponibilize ela para o terraform:
```
export TF_VAR_mgc_api_key=$(mgc auth api-key get --id $(mgc auth api-key list -o json -r | jq 'map(select(.name == "terraform-factorio"))[0].id' -r) -o json -r | jq '.api_key' -r)
```

Aí aplique a configuração:
```
tofu init
tofu apply
```

Pronto! Quando finalizar, você receberá o IP do servidor, basta se conectar e jogar.

Caso queira fazer alguma mudança, basta editar a configuração do NixOS e aplicar novamente.
