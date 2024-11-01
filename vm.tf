resource "mgc_ssh_keys" "key" {
  name = "chave-do-gabriel"
  key  = file("${path.module}/ssh.pub")
}

resource "mgc_virtual_machine_instances" "factorio_server" {
  name           = "factorio"
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
