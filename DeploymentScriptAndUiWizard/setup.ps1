
"#################################################"
"# hoferlabs.ch                                  #"
"# implement requirements for deployment script  #"
"# Version: 0.1                                  #"
"#################################################"

# edit here
$strDeploymentResourceGroupName = "rg-deploymentScript-10"
$strUserAssignedManagedIdentityName = "mi-deploymentScript-10"
$strLocation = "Switzerlandnorth"
$arrPermissions = "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All", "GroupMember.ReadWrite.All", "RoleManagement.ReadWrite.Directory" 

# "RoleManagement.ReadWrite.Directory" is needed if we create a group which can be assigne Azure roles

# do not edit
$strGraphAppId = "00000003-0000-0000-c000-000000000000"

Connect-MgGraph -Scopes Application.Read.All, AppRoleAssignment.ReadWrite.All, RoleManagement.ReadWrite.Directory
$objContext = Get-AzContext

"connected to subscription $($objContext.Subscription.Name) ($($objContext.Subscription.Id)) with account $($objContext.Account)"

"create deployment resource group $strDeploymentResourceGroupName..."
$objResourceGroup = New-AzResourceGroup -Name $strDeploymentResourceGroupName -Location $strLocation

"create user-assigned managed identity $strUserAssignedManagedIdentityName..."
$objUserAssignedManagedIdentity = New-AzUserAssignedIdentity -ResourceGroupName $strDeploymentResourceGroupName -Name $strUserAssignedManagedIdentityName -Location $strLocation
"waiting for user-assigned managed identity to be created..."
start-sleep 50

"get graph app..."
$objGraphApp = Get-MgServicePrincipal -Filter "AppId eq '$strGraphAppId'"

"assign permissions..."
ForEach ($strPermission in $arrPermissions) {
  " assign permission $strPermission..."
  $objRole = $objGraphApp.AppRoles | Where-Object { $_.Value -eq $strPermission }
  $objResult = New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $($objUserAssignedManagedIdentity.PrincipalId) -PrincipalId $($objUserAssignedManagedIdentity.PrincipalId) -ResourceId $objGraphApp.Id -AppRoleId $objRole.Id
}

"verify permissions..."
$arrRoleAssignment = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $($objUserAssignedManagedIdentity.PrincipalId)
ForEach ($objRoleAssignment in $arrRoleAssignment) {
  $objRole = $objGraphApp.AppRoles | Where-Object { $_.Id -eq $objRoleAssignment.AppRoleId }
  " assignment for app role $($objRole.Value) was created on $($objRoleAssignment.CreatedDateTime) (ID: $($objRoleAssignment.AppRoleId))"
}

"remove the resource group (and all its resources) with the following command after the deployment: Remove-AzResourceGroup $strDeploymentResourceGroupName -Force"





