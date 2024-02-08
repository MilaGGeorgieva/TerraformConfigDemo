variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "resource_group_location" {
  type        = string
  description = "Resource group location"
}

variable "app_service_plan_name" {
  type        = string
  description = "App service plan name"
}

variable "app_service_name" {
  type        = string
  description = "Web app service name"
}

variable "sql_server_name" {
  type        = string
  description = "Server name"
}

variable "sql_database_name" {
  type        = string
  description = "Database name"
}

variable "sql_admin_login" {
  type        = string
  description = "Server admin username"
}

variable "sql_admin_password" {
  type        = string
  description = "Server admin password"
}

variable "firewall_rule_name" {
  type        = string
  description = "Firewall rule name"
}

variable "repo_URL" {
  type        = string
  description = "GitHub repo URL"
}