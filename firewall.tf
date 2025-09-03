resource "mgc_network_security_groups" "factorio_server" {
  name = "factorio-hackathon"
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

resource "mgc_network_security_groups_attach" "factorio_firewall_attach" {
  security_group_id = mgc_network_security_groups.factorio_server.id
  interface_id      = mgc_virtual_machine_instances.factorio_server.network_interfaces[0].id
}
