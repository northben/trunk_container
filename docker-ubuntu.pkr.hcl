packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

variable "base_image" {
  type = string
  default = "ubuntu"
}

variable "linux_image" {
  type = string
  default = "ubuntu-bgn"
}

source "docker" "ubuntu" {
  image  = var.base_image
  commit = true
  pull = true
}

build {
  name = var.linux_image
  sources = [
    "source.docker.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get install vim -y",
    ]
  }

  post-processor "docker-tag" {
    repository = var.linux_image
    tags = ["latest"]
    only = ["docker.ubuntu"]
  }

}
