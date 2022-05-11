source "null" "download" {
  communicator = "none"
}

variable "splunk_download_url" {
  type = string
}

variable "webhooks_download_url" {
  type = string
}

build {
  name = "roles"

  sources = ["source.null.download"]
  provisioner "shell-local" {
    inline = [
      "if [ ! -e files/splunk.tgz ]; then wget -O files/splunk.tgz ${var.splunk_download_url}; fi",
      "if [ ! -e files/webhooks_input.tar.gz ]; then wget -O files/webhooks_input.tar.gz ${var.webhooks_download_url}; fi",
    ]
  }
}
