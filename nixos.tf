module "deploy" {
  source = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"
  nixos_system_attr = ".#nixosConfigurations.factorio-server.config.system.build.toplevel"
  nixos_partitioner_attr = ".#nixosConfigurations.factorio-server.config.system.build.diskoScript"
  debug_logging = true

  instance_id = mgc_virtual_machine_instances.factorio_server.id
  target_host = mgc_virtual_machine_instances.factorio_server.network.public_address
  install_user = "debian"
}
