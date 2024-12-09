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

resource "mgc_network_security_groups" "factorio_server" {
  name = "factorio"
}
resource "mgc_network_security_groups_rules" "incoming_ssh_ipv4" {
  direction = "ingress"
  port_range_min = 22
  port_range_max = 22
  protocol = "tcp"
  ethertype = "IPv4"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.factorio_server.id
}
resource "mgc_network_security_groups_rules" "incoming_ssh_ipv6" {
  direction = "ingress"
  port_range_min = 22
  port_range_max = 22
  protocol = "tcp"
  ethertype = "IPv6"
  remote_ip_prefix = "::/0"
  security_group_id = mgc_network_security_groups.factorio_server.id
}
resource "mgc_network_security_groups_rules" "incoming_factorio_ipv4" {
  direction = "ingress"
  port_range_min = 34197
  port_range_max = 34197
  protocol = "udp"
  ethertype = "IPv4"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.factorio_server.id
}
resource "mgc_network_security_groups_rules" "incoming_factorio_ipv6" {
  direction = "ingress"
  port_range_min = 34197
  port_range_max = 34197
  protocol = "udp"
  ethertype = "IPv6"
  remote_ip_prefix = "::/0"
  security_group_id = mgc_network_security_groups.factorio_server.id
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
      security_groups = [{ id = mgc_network_security_groups.factorio_server.id }]
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
