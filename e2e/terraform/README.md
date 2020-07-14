# Terraform Infrastructure

This folder contains terraform resources for provisioning EC2 instances on AWS
to use as the target of end-to-end tests.

Terraform provisions the AWS infrastructure only, whereas the Consul
cluster is deployed to that infrastructure by the e2e
framework. Terraform's output will include a `provisioning` stanza
that can be written to a JSON file used by the e2e framework's
provisioning step.

You can use Terraform to output the provisioning parameter JSON file the e2e
framework uses.

## Setup

You'll need Terraform 0.12+, as well as AWS credentials (`AWS_ACCESS_KEY_ID`
and `AWS_SECRET_ACCESS_KEY`) to create the Consul cluster. Use
[envchain](https://github.com/sorah/envchain) to store your AWS credentials.

Optionally, create a `vars.tfvars` file and instantiate the variables with the values you'd like!

```
allowed_inbound_cidrs = ["0.0.0.0/0"]
consul_version = "1.7.3"
name_prefix = "schristoff"  
owner = "schristoff"
public_ip = true
```

Run Terraform apply to deploy the infrastructure:

```sh
cd e2e/terraform/
envchain consulaws terraform apply
```

## Outputs

After deploying the infrastructure, you can get connection information
about the cluster:

- `$(terraform output environment)` will set your current shell's
  `NOMAD_ADDR` and `CONSUL_HTTP_ADDR` to point to one of the cluster's
  server nodes, and set the `NOMAD_E2E` variable.
- `terraform output servers` will output the list of server node IPs.
- `terraform output linux_clients` will output the list of Linux
  client node IPs.
- `terraform output windows_clients` will output the list of Windows
  client node IPs.
- `terraform output provisioning | jq .` will output the JSON used by
  the e2e framework for provisioning.

## SSH

You can use Terraform outputs above to access nodes via ssh:

```sh
ssh -i keys/consul-e2e-*.pem ubuntu@${EC2_IP_ADDR}
```

The Windows client runs OpenSSH for convenience, but has a different
user and will drop you into a Powershell shell instead of bash:

```sh
ssh -i keys/consul-e2e-*.pem Administrator@${EC2_IP_ADDR}
```

## Teardown

The terraform state file stores all the info.

```sh
cd e2e/terraform/
envchain nomadaws terraform destroy
```
