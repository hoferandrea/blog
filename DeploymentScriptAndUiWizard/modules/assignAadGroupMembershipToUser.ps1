param(
    [Parameter(Mandatory = $true)][string]$userId,
    [Parameter(Mandatory = $true)][string]$groupId
)

"#############################################"
"# hoferlabs.ch                              #"
"# assign user to group (deployment script)  #"
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

    "check if group membership already exists"
    $objGroupAssignment = $null
    $uri = "https://graph.microsoft.com/beta/users/$userId/memberOf?`$filter=id eq `'$groupId`'"
    $objGroupAssignment = Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -StatusCodeVariable "scv" -SkipHttpErrorCheck
    If ($scv -eq 200) {
        $result = "group membership already exists."
        $result
    }
    Else {
        "create group assignment..."
        $payload = @"
{
    "@odata.id": "https://graph.microsoft.com/beta/users/$userId"

}
"@
        $uri = "https://graph.microsoft.com/beta/groups/$groupId/members/`$ref"
        $objGroupAssignment = Invoke-RestMethod -Uri $uri -Method Post -Headers $authHeader -Body $payload
        $result = "group membership created."
        $result
    }

    # create output
    $DeploymentScriptOutputs["result"] = $result
}
catch {
    "error catched:"
    Write-Output $(Get-Error)
    # create output
    $DeploymentScriptOutputs["result"] = $(Get-Error).ErrorDetails.Message
}