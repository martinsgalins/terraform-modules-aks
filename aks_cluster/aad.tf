# Create Service Principal for AKS cluster
resource "azuread_application" "aks_sp_application" {
  count        = local.use_aks_sp ? 1 : 0
  display_name = "${var.cluster_name}-aks"
}

resource "azuread_service_principal" "aks_sp" {
  count          = local.use_aks_sp ? 1 : 0
  client_id = azuread_application.aks_sp_application[0].client_id
}

resource "azuread_service_principal_password" "aks_sp_password" {
  count = local.use_aks_sp ? 1 : 0
  lifecycle {
    ignore_changes = [end_date]
  }
  service_principal_id = azuread_service_principal.aks_sp[0].id
}

resource "azurerm_role_assignment" "aks_sp_role_assignment" {
  count                = local.use_aks_sp ? 1 : 0
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.aks_sp[0].id

  depends_on = [
    azuread_service_principal_password.aks_sp_password
  ]
}

# Create a cluster admin group
resource "azuread_group" "aks-aad-clusteradmins" {
  count            = var.enable_aad_auth ? 1 : 0
  display_name     = "${var.cluster_name}-clusteradmin"
  security_enabled = true
}
