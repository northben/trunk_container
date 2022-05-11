variable "trunk_image" {
  type = string
  default = "trunk"
}

variable "aws_profile" {
  type = string
}

variable "aws_ecr_repository" {
  type = string
}

variable "trunk_callback_address" {
  type = string
}

variable "trello_key" {
  type = string
}

variable "trello_token" {
  type = string
}

source "docker" "trunk" {
  image  = var.splunk_image
  commit = true
  pull   = false
  changes = [
    "WORKDIR /opt/splunk",
    "EXPOSE 8000 8000",
    "CMD [\"-c\", \"./bin/splunk start && tail -f var/log/splunk/splunkd.log\"]",
  ]
}

build {
  name = var.trunk_image
  sources = [
    "source.docker.trunk"
  ]

  provisioner "file" {
    source      = "files/webhooks_input.tar.gz"
    destination = "/tmp/"
  }

  provisioner "file" {
    source      = "files/trello_webhook_input.conf"
    destination = "/tmp/trello_webhook_input.conf"
  }

  provisioner "file" {
    source      = "${path.root}/../TA-trello-webhook/TA-trello-webhook/"
    destination = "/tmp/TA-trello-webhook/"
  }

  provisioner "file" {
    content      = templatefile("files/northben_ta_trello_webhook_input.pkrtpl.hcl",
    {
      callback_address = var.trunk_callback_address,
      trello_key = var.trello_key,
      trello_token = var.trello_token,
    })
    destination = "/tmp/northben_ta_trello_webhook_input.conf"
  }

  provisioner "shell" {
    inline = [
      "cd /opt/splunk/",
      "mv /tmp/TA-trello-webhook etc/apps/",
      "tar xzf /tmp/webhooks_input.tar.gz -C etc/apps/",
      "mkdir -p etc/apps/webhooks_input/local/",
      "mv /tmp/trello_webhook_input.conf etc/apps/webhooks_input/local/inputs.conf",
      "mv /tmp/northben_ta_trello_webhook_input.conf etc/apps/TA-trello-webhook/local/inputs.conf",
      "chown -R root: etc/apps/TA-trello-webhook",
    ]
  }

  post-processors {
    post-processor "docker-tag" {
      repository = var.trunk_image
      tags       = ["latest"]
      only       = ["docker.trunk"]
    }
  }

  post-processors {
    post-processor "docker-tag" {
      repository = "${var.aws_ecr_repository}/trunk"
      tags       = ["latest"]
      only       = ["docker.trunk"]
    }

    post-processor "docker-push" {
      ecr_login    = true
      aws_profile  = var.aws_profile
      login_server = "${var.aws_ecr_repository}"
    }
  }

}
