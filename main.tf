terraform {
  backend "local" {
    path = ".terraform.tfstate"
  }
  required_providers {
    mgc = {
      source = "registry.terraform.io/magalucloud/mgc"
    }
  }
}

provider "mgc" {
  region = "br-se1"
}

resource "tls_private_key" "key" {
  algorithm = "ED25519"
}

resource "mgc_ssh_keys" "key" {
  name = tls_private_key.key.id
  key = tls_private_key.key.public_key_openssh
}


resource "mgc_virtual_machine_instances" "factorio_server" {
  name = "factorio-server"
  ssh_key_name = mgc_ssh_keys.key.name
  machine_type = {
    name = "BV2-8-40"
  }
  image = {
    name = "cloud-debian-12 LTS"
  }
  network = {
    associate_public_ip = true
    interface = {
      security_groups = [{
        id = "4aa1a237-2d57-439b-bf6a-177ddbace4cb" # grupo podetudo
      }]
    }
  }
}

module "deploy" {
  source = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"
  nixos_system_attr = ".#nixosConfigurations.factorio-server.config.system.build.toplevel"
  nixos_partitioner_attr = ".#nixosConfigurations.factorio-server.config.system.build.diskoScript"

  target_host = mgc_virtual_machine_instances.factorio_server.network.public_address
  instance_id = mgc_virtual_machine_instances.factorio_server.id

  install_user = "debian"
  install_ssh_key = nonsensitive(tls_private_key.key.private_key_openssh)
}
