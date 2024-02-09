terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.89.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "StorageRG"
    storage_account_name = "taskboardmilastorage"
    container_name       = "taskboardcontainer"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Generate a random integer for unique resource name
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Creates a resource group
resource "azurerm_resource_group" "milarg" {
  name     = "${var.resource_group_name}-${random_integer.ri.result}"
  location = var.resource_group_location
}

# Creates a Linux App service plan
resource "azurerm_service_plan" "azureappsp" {
  name                = "${var.app_service_plan_name}-${random_integer.ri.result}-serviceplan"
  resource_group_name = azurerm_resource_group.milarg.name
  location            = azurerm_resource_group.milarg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

# Creates a Web app and pass in the App service plan
resource "azurerm_linux_web_app" "azurelwebapp" {
  name                = "${var.app_service_name}-${random_integer.ri.result}-webbapp"
  resource_group_name = azurerm_resource_group.milarg.name
  location            = azurerm_service_plan.azureappsp.location
  service_plan_id     = azurerm_service_plan.azureappsp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.mssqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.azureDB.name};User ID=${azurerm_mssql_server.mssqlserver.administrator_login};Password=${azurerm_mssql_server.mssqlserver.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }
}

# Creates server
resource "azurerm_mssql_server" "mssqlserver" {
  name                         = "${var.sql_server_name}-${random_integer.ri.result}-sqlserver"
  resource_group_name          = azurerm_resource_group.milarg.name
  location                     = azurerm_resource_group.milarg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

# Creates database
resource "azurerm_mssql_database" "azureDB" {
  name           = "${var.sql_database_name}-${random_integer.ri.result}"
  server_id      = azurerm_mssql_server.mssqlserver.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "S0"
  zone_redundant = false
}

# Creates a firewall rule for the mssql server
resource "azurerm_mssql_firewall_rule" "firewallrule" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.mssqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Deploys code from a public GitHub repo
resource "azurerm_app_service_source_control" "azureappsc" {
  app_id                 = azurerm_linux_web_app.azurelwebapp.id
  repo_url               = var.repo_URL
  branch                 = "main"
  use_manual_integration = true
}
