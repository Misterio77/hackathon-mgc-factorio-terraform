module "deploy" {
  depends_on = [
    mgc_network_security_groups_attach.factorio_firewall_attach,
    mgc_network_public_ips_attach.factorio_ip_attach,
  ]
  source                 = "github.com/nix-community/nixos-anywhere//terraform/all-in-one?ref=55fc48f9677822393cd9585b6742e1194accf365" # 1.11.0
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
