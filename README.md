# Deploy HCP Terraform agents with Azure Container Instances 

This code deploys HCP Terraform agents with Azure Container Instances.

All variables are predefined with default values with the exception of the [agent pool token](https://developer.hashicorp.com/terraform/tutorials/cloud/cloud-agents#create-an-agent-pool) which has to be generated and passed to the `token` variable.
