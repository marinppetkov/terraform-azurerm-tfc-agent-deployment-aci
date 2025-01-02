variable "rg_name" {
  description = "Azure resource group name"
  default = "tfc-agent-aci"
}

variable "aci_group_name" {
  default = "tfc-agent"
}

variable "container_name" {
  description = "Container name, for each instance an index id will be added as suffix"
  default = "tfc-agent"
}

variable "agent_prefix_name" {
  description = "TFC agent prefix name"
  default     = "agent"
}

variable "token" {
    description = "Agent pool token"
}

variable "instance_count" {
  description = "Number of agent instances"
  type = number
  default     = 1
}

variable "private" {
  description = "Defines if the IP address type of the container will be Private or None"
  type = bool
  default = false
}
