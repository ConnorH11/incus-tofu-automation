terraform {
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "0.2.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "incus" {
  remote {
    name    = "local"
    scheme  = "unix"
    address = "/var/lib/incus/unix.socket"
    default = true
  }
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key"
  type        = string
  sensitive   = true
}

variable "hostname" {
  description = "Hostname for container and Tailscale"
  type        = string
  }

data "template_file" "cloudinit" {
  template = file("${path.module}/cloud-init.yaml.tmpl")
  vars = {
    tailscale_auth_key = var.tailscale_auth_key
    hostname           = var.hostname
  }
}

resource "incus_instance" "noble" {
  name    = var.hostname
  type    = "container"
  image   = "ubuntu-noble-cloud"
  profiles = ["default"]
  wait_for_network = true

  config = {
    "user.user-data" = data.template_file.cloudinit.rendered
  }
}
