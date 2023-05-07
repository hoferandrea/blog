param(
    [Parameter(Mandatory = $true)][string]$groupName,
    [Parameter(Mandatory = $true)][string]$groupDescription
)

"#############################################"
"# hoferlabs.ch                              #"
"# create AAD group (deployment script)      #"
"# Version: 0.1                              #"
"#############################################"
try {
    $DeploymentScriptOutputs = @{}

    "get access token"
    $context = Get-AzContext  
    Write-Host "Connected to Azure with subscription: $($context.Subscription) with $($context.Account.type) $($context.Account.id)"

    $token = (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com").Token

    $authHeader = @{
        'Content-Type'     = 'application/json'
        'Authorization'    = 'Bearer ' + $token
        'Resource'         = 'https://graph.microsoft.com'
        'ConsistencyLevel' = 'eventual'
    }

    "check if group exists"
    $objGroup = $null
    $uri = "https://graph.microsoft.com/beta/groups?`$filter=startswith(displayName,`'$groupName`')"
    $objGroup = Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader 
    If ($objGroup.value) {
        $result = "group with id $($objGroup.value.id) already exists."
        # create output
        $DeploymentScriptOutputs["groupId"] = $($objGroup.value.id)
        $DeploymentScriptOutputs["result"] = $result
        $result
    }
    Else {
        "create group $grouPrincipalName"
        $payload = @"
{
    "description": "$groupDescription",
    "displayName": "$groupName",
    "isAssignableToRole": true,
    "mailEnabled": false,
    "mailNickName": "NotSet",
    "securityEnabled": true
}
"@
        $uri = "https://graph.microsoft.com/beta/groups"
        $objGroup = Invoke-RestMethod -Uri $uri -Method Post -Headers $authHeader -Body $payload
        $result = "group with id $($objGroup.id) created."
        $result
        # create output
        $DeploymentScriptOutputs["groupId"] = $($objGroup.id)
        $DeploymentScriptOutputs["result"] = $result
    }

}
catch {
    "error catched:"
    Write-Output $(Get-Error)
    # create output
    $DeploymentScriptOutputs = @{}
    $DeploymentScriptOutputs["result"] = $(Get-Error).ErrorDetails.Message
}