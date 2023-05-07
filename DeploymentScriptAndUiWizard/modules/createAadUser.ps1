param(
    [Parameter(Mandatory = $true)][string]$userPrincipalName,
    [Parameter(Mandatory = $true)][string]$userDisplayName
)

"#############################################"
"# hoferlabs.ch                              #"
"# create AAD user (deployment script)       #"
"# Version: 0.1                              #"
"#############################################"
try {
    $DeploymentScriptOutputs = @{}

    "get access token"
    $context = Get-AzContext  
    Write-Host "Connected to Azure with subscription: $($context.Subscription) with $($context.Account.type) $($context.Account.id)"

    $token = (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com").Token

    $authHeader = @{
        'Content-Type'  = 'application/json'
        'Authorization' = 'Bearer ' + $token
        'Resource'      = 'https://graph.microsoft.com'
    }

    "check if user exists"
    $objUser = $null
    $uri = "https://graph.microsoft.com/beta/users/$userPrincipalName"
    $objUser = Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -StatusCodeVariable "scv" -SkipHttpErrorCheck
    If ($scv -eq 200) {
        $result = "user with id $($objUser.id) already exists."
        $result
    }
    Else {
        "create user $userPrincipalName"
        $payload = @"
{
    "accountEnabled": false,
    "displayName": "$userDisplayName",
    "mailNickname": "notSet",
    "userPrincipalName": "$userPrincipalName",
    "passwordProfile" : {
        "forceChangePasswordNextSignIn": true,
        "password": "xWwvJ]6NMw+bWH-d"
    }
}
"@
        $uri = "https://graph.microsoft.com/beta/users"
        $objUser = Invoke-RestMethod -Uri $uri -Method Post -Headers $authHeader -Body $payload
        $result = "user with id $($objUser.id) created."
        $result
    }

    # create output
    $DeploymentScriptOutputs["userId"] = $($objUser.id)
    $DeploymentScriptOutputs["result"] = $result
}
catch {
    "error catched:"
    Write-Output $(Get-Error)
    # create output
    $DeploymentScriptOutputs["result"] = $(Get-Error).ErrorDetails.Message
}


