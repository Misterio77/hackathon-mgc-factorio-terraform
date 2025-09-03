terraform {
  backend "local" {
    path = ".terraform.tfstate"
  }
  required_providers {
    mgc = {
      source  = "registry.terraform.io/magalucloud/mgc"
      version = "0.36.1"
    }
  }
}

variable "mgc_api_key" {
  description = "A MGC API key to use with the provider."
  sensitive = true
  type = string
}

provider "mgc" {
  region = "br-se1"
  api_key = var.mgc_api_key
}
