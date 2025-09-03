resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

resource "mgc_ssh_keys" "key" {
  name = "factorio-generated-key"
  key  = tls_private_key.ssh.public_key_openssh
}

resource "mgc_virtual_machine_instances" "factorio_server" {
  name = "factorio"
  machine_type = "BV2-8-40"
  image = "cloud-debian-12 LTS"
  ssh_key_name = mgc_ssh_keys.key.name
}
