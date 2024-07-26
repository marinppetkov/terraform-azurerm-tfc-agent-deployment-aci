provider "azurerm" {
  features{}
}

resource "random_id" "suffix" {
    count = var.instance_count
    byte_length = 4
}

resource "azurerm_resource_group" "rg_agents" {
  name     = var.rg_name
  location = "West Europe"
}

resource "azurerm_container_group" "containers" {
  name                = var.aci_group_name
  location            = azurerm_resource_group.rg_agents.location
  resource_group_name = azurerm_resource_group.rg_agents.name
  ip_address_type     = "None"
  os_type             = "Linux"

  dynamic container {
    for_each = {for idx, suffix in random_id.suffix : idx => suffix.id}
    content  {
        name   = "${var.container_name}-${container.key}"
        image  = "hashicorp/tfc-agent:latest"
        cpu    = "0.5"
        memory = "1.5"
        environment_variables =  {
            TFC_AGENT_NAME = "${var.agent_prefix_name}-${container.value}"
            } 
        secure_environment_variables =  {
            TFC_AGENT_TOKEN = var.token
            } 
    }
  }
  
  tags = {
    environment = "TFC"
  }
}

