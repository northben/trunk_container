variable "docker_image" {
  type = string
  default = "ubuntu"
}

variable "splunk_image" {
  type = string
  default = "splunk"
}

variable "splunk_password" {
  type = string
}

source "docker" "linux" {
  image  = var.linux_image
  commit = true
  pull = false
  changes = [
    "WORKDIR /opt/splunk",
    "EXPOSE 8000 8000",
    "CMD [\"-c\", \"./bin/splunk start && tail -f var/log/splunk/splunkd.log\"]",
  ]
}

build {
  name = var.splunk_image
  sources = [
    "source.docker.linux"
  ]

  provisioner "file" {
    source = "files/splunk.tgz"
    destination = "/tmp/splunk.tgz"
  }

  provisioner "file" {
    source = "files/Splunk.License"
    destination = "/tmp/Splunk.License"
  }

  provisioner "file" {
    source = "files/telemetry.conf"
    destination = "/tmp/telemetry.conf"
  }

  provisioner "shell" {
    inline = [
      "tar xz -C /opt -f /tmp/splunk.tgz",
      "cd /opt/splunk",
      "echo OPTIMISTIC_ABOUT_FILE_LOCKING=1 >> etc/splunk-launch.conf",
      "mkdir -p etc/apps/splunk_instrumentation/local/",
      "mv /tmp/telemetry.conf etc/apps/splunk_instrumentation/local/telemetry.conf",
      "chown -R root: .",
      "./bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd ${var.splunk_password};",
      "./bin/splunk add license /tmp/Splunk.License -auth admin:${var.splunk_password};",
      "./bin/splunk stop &",
    ]
  }

  provisioner "shell" {
    inline = [
      "cd /opt/splunk",
      "./bin/splunk clean eventdata -f",
      "rm -rf /tmp/splunk.tgz /tmp/Splunk.License var/lib/splunk/kvstore/mongo/",
    ]
    pause_before = "15s"
  }

  post-processor "docker-tag" {
    repository = var.splunk_image
    tags = ["latest"]
    only = ["docker.linux"]
  }

}
