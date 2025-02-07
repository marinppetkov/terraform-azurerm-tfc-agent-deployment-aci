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

# https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/default-outbound-access
resource "azurerm_container_group" "containers" {
  name                = var.aci_group_name
  location            = azurerm_resource_group.rg_agents.location
  resource_group_name = azurerm_resource_group.rg_agents.name
  ip_address_type     = var.private ? "Private" : "None"
  os_type             = "Linux"
  # identity {
  #   type = "SystemAssigned"
  # }
  subnet_ids = var.private ? [azurerm_subnet.aci_subnet[0].id] : null
  dynamic container {
    for_each = {for idx, suffix in random_id.suffix : idx => suffix.id}
    content  {
        name   = "${var.container_name}-${container.key}"
        image  = "hashicorp/tfc-agent:latest"
        cpu    = "1"
        memory = "1"
        # https://github.com/hashicorp/terraform-provider-azurerm/issues/1697
        # For private connection at least one port must be exposed
        # For ip address type equal to none, ports block is not needed
         ports {
          port = 443
          protocol = "TCP"

          }
  
        environment_variables =  {
            TFC_AGENT_NAME = "${var.agent_prefix_name}-${container.value}"
            TFC_AGENT_AUTO_UPDATE = "disabled"
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

### Subnets:

resource "azurerm_virtual_network" "aci_network" {
  count = var.private ? 1 : 0
  name                = "aci-vnet"
  address_space       = ["10.0.1.0/24"]
  location            = azurerm_resource_group.rg_agents.location
  resource_group_name = azurerm_resource_group.rg_agents.name
}
resource "azurerm_subnet" "aci_subnet" {
  count = var.private ? 1 : 0
  name                 = "aci-subnet"
  resource_group_name  = azurerm_resource_group.rg_agents.name
  virtual_network_name = azurerm_virtual_network.aci_network[count.index].name
  address_prefixes     = ["10.0.1.0/26"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}