resource "mgc_network_public_ips" "factorio_ip" {
  vpc_id = mgc_virtual_machine_instances.factorio_server.vpc_id
}

resource "mgc_network_public_ips_attach" "factorio_ip_attach" {
  public_ip_id = mgc_network_public_ips.factorio_ip.id
  interface_id = mgc_virtual_machine_instances.factorio_server.network_interfaces[0].id
}

output "ip" {
  value = mgc_network_public_ips.factorio_ip.public_ip
}
