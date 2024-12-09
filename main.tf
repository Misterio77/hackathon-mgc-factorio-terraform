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

resource "mgc_ssh_keys" "key" {
  name = "chave-do-gabriel"
  key  = file("${path.module}/ssh.pub")
}

resource "mgc_virtual_machine_instances" "factorio_server" {
  name = "factorio"
  name_is_prefix = true
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
        id = "4aa1a237-2d57-439b-bf6a-177ddbace4cb" # grupo criado previamente pelo gabriel
      }]
    }
  }
  ssh_key_name = mgc_ssh_keys.key.name
}

output "ip" {
  value = mgc_virtual_machine_instances.factorio_server.network.public_address
}

module "deploy" {
  source                 = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"
  nixos_system_attr      = ".#nixosConfigurations.factorio-server.config.system.build.toplevel"
  nixos_partitioner_attr = ".#nixosConfigurations.factorio-server.config.system.build.diskoScript"
  debug_logging          = true

  instance_id  = mgc_virtual_machine_instances.factorio_server.id
  target_host  = mgc_virtual_machine_instances.factorio_server.network.public_address
  install_user = "debian"
}
