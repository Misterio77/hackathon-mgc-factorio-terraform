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
