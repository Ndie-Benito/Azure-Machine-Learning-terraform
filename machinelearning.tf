

#  Récupère l'ID du locataire Azure
data "azurerm_client_config" "current" {}

#  Création du groupe de ressources
resource "azurerm_resource_group" "benito_rg" {
  name     = "benito-ml-rg"
  location = "West Europe"

  tags = {
    Owner       = "Benito"
    Environment = "Development"
  }
}

#  Création d'Application Insights pour la surveillance
resource "azurerm_application_insights" "benito_app_insights" {
  name                = "benito-workspace-ai"
  location            = azurerm_resource_group.benito_rg.location
  resource_group_name = azurerm_resource_group.benito_rg.name
  application_type    = "web"

  tags = {
    Owner       = "Benito"
    Environment = "Development"
  }
}

#  Création d'un Key Vault pour stocker les secrets
resource "azurerm_key_vault" "benito_keyvault" {
  name                = "benitoworkspacekeyvault"
  location            = azurerm_resource_group.benito_rg.location
  resource_group_name = azurerm_resource_group.benito_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"

  tags = {
    Owner       = "Benito"
    Security    = "High"
  }
}

#  Création d'un compte de stockage pour stocker les datasets et modèles ML
resource "azurerm_storage_account" "benito_storage" {
  name                     = "benitomlstorage"
  location                 = azurerm_resource_group.benito_rg.location
  resource_group_name      = azurerm_resource_group.benito_rg.name
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    Owner       = "Benito"
    Environment = "Development"
  }
}

#  Création de l'Azure Machine Learning Workspace
resource "azurerm_machine_learning_workspace" "benito_ml_workspace" {
  name                    = "benito-ml-workspace"
  location                = azurerm_resource_group.benito_rg.location
  resource_group_name     = azurerm_resource_group.benito_rg.name
  application_insights_id = azurerm_application_insights.benito_app_insights.id
  key_vault_id            = azurerm_key_vault.benito_keyvault.id
  storage_account_id      = azurerm_storage_account.benito_storage.id

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Owner       = "Benito"
    Project     = "Machine Learning"
  }
}
