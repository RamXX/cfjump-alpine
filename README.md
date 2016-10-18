# cfjump

Re-implementation of [cfjump](https://github.com/RamXX/cfjump) on Alpine Linux with the purpose of reduce its size. 

Jumpbox Docker image with most of the required tools to install and operate Cloud Foundry from the command line. It works with different workflows, and includes several tools to work with OpsManager and other Pivotal-specific components. It also includes some IaaS-specific CLI tools for OpenStack, AWS, GCP, and Azure.

It has been tested only on an Ubuntu Server 16.04 (Xenial) 64-bit Docker host VM. Your mileage on other systems may vary.

v0.2 includes:

##### Linux
- gliderlabs/alpine base image
- Several Linux troubleshooting tools like `iPerf`, `nmap` and `tcpdump`.
- Golang (1.6)

##### Cloud Foundry tools
- `bosh-init` (latest)
- [BOSH](http://bosh.io/) CLI (latest)
- `cf` CLI (latest)
- [uaac](https://docs.cloudfoundry.org/adminguide/uaa-user-management.html) CLI
- [Concourse](http://concourse.ci/) `fly` CLI (latest)
- [asg-creator](https://github.com/cloudfoundry-incubator/asg-creator) (latest) A cleaner way to create and manage ASGs.
- [Deployadactyl](https://github.com/compozed/deployadactyl) (latest). Go library for deploying applications to multiple Cloud Foundry instances.

##### Pivotal-specific
- [cfops](https://github.com/pivotalservices/cfops) (latest) automation based on the supported way to back up Pivotal Cloud Foundry
- [PivNet CLI](https://github.com/pivotal-cf/go-pivnet) `pivnet` (experimental, early Alpha) CLI (latest)
- [OpsMan-cli](https://github.com/datianshi/opsman) (CLI to interact with OpsManager).
- [cf-mgmt](https://github.com/pivotalservices/cf-mgmt) (latest) Go automation for managing orgs, spaces that can be driven from concourse pipeline and git-managed metadata.
- [bosh-bootloader](https://github.com/cloudfoundry/bosh-bootloader) Command line utility for standing up a CloudFoundry or Concourse installation on an IAAS of your choice.

##### IaaS tools
- [OpenStack CLI](http://docs.openstack.org/developer/python-openstackclient/man/openstack.html) (latest), both, legacy `nova`, `cinder`, `keystone`, etc commands as well as the newer `openstack` integrated CLI.
- [Terraform](https://www.terraform.io/) (0.7.4)
- [Microsoft Azure CLI](https://github.com/Azure/azure-xplat-cli) (latest)
- [Google Compute Cloud CLI](https://cloud.google.com/sdk/downloads#linux) (latest)
- [AWS CLI](https://aws.amazon.com/cli/) (latest)

##### Other useful tools
- [Vault](https://www.vaultproject.io/) (latest)
- `safe` CLI, [an alternative Vault CLI](https://github.com/starkandwayne/safe) (latest)
- [certstrap](https://github.com/square/certstrap) (latest)
- [Spiff](https://github.com/cloudfoundry-incubator/spiff) (latest)
- [Spruce](http://spruce.cf/) (latest)
- [Genesis](https://github.com/starkandwayne/genesis) (latest)
- [s3cmd](http://s3tools.org/s3cmd) (latest). Command line to work with S3 endpoints.


##### Currently **NOT** working
- [Enaml](http://enaml.pezapp.io/) (update program only). Deploy Cloud Foundry without YAML.
- [Photon Controller](https://github.com/vmware/photon-controller) CLI 

## Running
First, make sure you can run instances as a regular unprivileged user. This container will create an internal user with uid and gid of 1000, same as the default in Ubuntu, which makes easier to share folders with the host.

The included `cfj` script make the operation of virtual jumpboxes easy. Copy it to a directory in your $PATH and use it to interact with the virtual jumpboxes. The operation is:

- `cfj list` (or simply `cfj` with no arguments) to list the running containers.
- `cfj <name>` to either create or enter a container.
- `cfj kill <name>` to delete a running container. **The associated shared volume
won't be deleted**. That needs to be done manually if desired. You can also specify `cfj kill all`, which will destroy all running (or stopped) jumpbox containers.

You can use different jumpbox instances for different sessions, users, environments, etc, as long as you use different shared folders.

## Building
You can just get this image from Docker Hub by running:

```
docker pull ramxx/cfjump-alpine:latest
```

Or if you prefer to build it yourself:

```
git clone https://github.com/RamXX/cfjump-alpine
cd cfjump-alpine
docker build -t ramxx/cfjump-alpine:latest .
```

## Limitations
Every instance of a container can only be used by a single user at the time. If another user attempts to join the same container while being used, all screen I/O will be duplicated in each screen.

It may be possible to use an `sshd` daemon to support multiple sessions, but that's outside the scope of this work.

Additionally, `man` pages are not installed in this image to decrease its size. Typically, man pages can be accessed on the Docker host itself or easily found online.

## Contributing
Please submit pull requests with any correction or improvement you want to do. I hope this is useful to others.
