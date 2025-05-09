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

resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

resource "mgc_ssh_keys" "key" {
  name = "factorio-generated-key"
  key  = tls_private_key.ssh.public_key_openssh
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
  machine_type = "BV2-8-40"
  image = "cloud-debian-12 LTS"
  ssh_key_name = mgc_ssh_keys.key.name
  user_data = base64encode(<<-EOF
    #cloud-config
    ssh_authorized_keys:
      - ${tls_private_key.ssh.public_key_openssh}
  EOF
  )
}

resource "mgc_network_public_ips" "factorio_ip" {
  vpc_id = mgc_virtual_machine_instances.factorio_server.vpc_id
}

resource "mgc_network_security_groups_attach" "factorio_firewall_attach" {
  security_group_id = mgc_network_security_groups.factorio_server.id
  interface_id      = mgc_virtual_machine_instances.factorio_server.network_interfaces[0].id
}

resource "mgc_network_public_ips_attach" "factorio_ip_attach" {
  public_ip_id = mgc_network_public_ips.factorio_ip.id
  interface_id = mgc_virtual_machine_instances.factorio_server.network_interfaces[0].id
}

output "ip" {
  value = mgc_network_public_ips.factorio_ip.public_ip
}

module "deploy" {
  depends_on = [
    mgc_network_security_groups_attach.factorio_firewall_attach,
    mgc_network_public_ips_attach.factorio_ip_attach,
  ]
  source                 = "github.com/nix-community/nixos-anywhere//terraform/all-in-one?ref=77e6a4e14baa93a29952ea9f0e4a59a29cca09e9" # 1.8.0
  nixos_system_attr      = ".#nixosConfigurations.factorio-server.config.system.build.toplevel"
  nixos_partitioner_attr = ".#nixosConfigurations.factorio-server.config.system.build.diskoScript"
  debug_logging          = true
  special_args = {
    terraform_ssh_key = tls_private_key.ssh.public_key_openssh
  }

  instance_id  = mgc_virtual_machine_instances.factorio_server.id
  target_host  = mgc_network_public_ips.factorio_ip.public_ip
  install_ssh_key = nonsensitive(tls_private_key.ssh.private_key_openssh)
  deployment_ssh_key = nonsensitive(tls_private_key.ssh.private_key_openssh)
  install_user = "debian"
}
