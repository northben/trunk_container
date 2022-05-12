README
===

This repo contains packer templates that create a docker container with [Trunk](https://github.com/northben/trunk) and [TA-trello-webhook](https://github.com/northben/ta-trello-webhook) preconfigured to index Trello Webhooks. You can customize and run this container on your own Docker host, or run in [AWS Fargate](https://github.com/northben/trunk_aws_fargate).

Prerequisites
---
* You need to have a Trello account, and a Trello key and API token. 
    1. Get your Trello key [here](https://trello.com/app-key)
    1. Get your Trello token. Replace __YOURKEY__ with the value of your key from the first step.
    > https://trello.com/1/authorize?expiration=never&scope=read,write,account&response_type=token&name=TA-trello-webhook&key=YOURKEY
    
* [Install packer](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli)

Create container
---

1. Rename __variables.auto.pkrvars.hcl_default__ to __variables.auto.pkrvars.hcl__
1. Provide values for empty variables
1. Add your __Splunk.license__ file to the __files__ directory. To create a container without a license, remove the __provisioner__ stanza and `add license` command from __docker-splunk.pkr.hcl__.
1. Run `packer build .`

Additional info
---

The `packer build` command is provided for VS Code. Use keyboard shortcut: `⌘ ⇧ B` and select __packer build all__.
