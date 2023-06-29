################################################################
# HelloID-Conn-Prov-Target-OutSystems-RoleManagement-Permissions
#
# Version: 1.0.0
################################################################
# Initialize default values
$config = $configuration | ConvertFrom-Json

# Enable TLS1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# Set debug logging
switch ($($config.IsDebug)) {
    $true { $VerbosePreference = 'Continue' }
    $false { $VerbosePreference = 'SilentlyContinue' }
}

#region functions
function Resolve-OutSystemsRoleManagementError {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]
        $ErrorObject
    )
    process {
        $httpErrorObj = [PSCustomObject]@{
            ScriptLineNumber = $ErrorObject.InvocationInfo.ScriptLineNumber
            Line             = $ErrorObject.InvocationInfo.Line
            ErrorDetails     = $ErrorObject.Exception.Message
            FriendlyMessage  = $ErrorObject.Exception.Message
        }

        try {
            $errorDetails = $ErrorObject.ErrorDetails | ConvertFrom-Json
            $httpErrorObj.ErrorDetails = "Exception: $($ErrorObject.Exception.Message), Error: $($errorDetails.Errors), code: $($errorDetails.StatusCode)"
            $httpErrorObj.FriendlyMessage = "Error: $($errorDetails.Errors), code: $($errorDetails.StatusCode)"
        } catch {
            $httpErrorObj.FriendlyMessage = "Received an unexpected response. The JSON could not be converted, error: [$($_.Exception.Message)]. Original error from web service: [$($ErrorObject.Exception.Message)]"
        }
        Write-Output $httpErrorObj
    }
}
#endregion

try {
    $headers = [System.Collections.Generic.Dictionary[string, string]]::new()
    $headers.Add("Authorization", "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($config.UserName):$($config.Password)")))")
    $permissions = [System.Collections.Generic.List[object]]::new()
    $environments = $($config.Environments).Split(',')
    $splatParams = @{
        Method = 'GET'
        Headers = $headers
        Verbose = $false
    }
    foreach ($environment in $environments){
        $splatParams['Uri'] = ("$($config.BaseUrl)/$($config.API)/rest/usermanagement/groups").Replace("{environment}", $environment)
        $responseGroups = Invoke-RestMethod @splatParams
        foreach ($group in $responseGroups.Groups){
            $permission = @{
                DisplayName = "$($group.GroupName)-$environment"
                Identification = @{
                    Reference = $($group.GroupName)
                    Environment = $environment
                    DisplayName = "$($group.GroupName)-$environment"
                }
            }
            $permissions.Add($permission)
        }
    }
    Write-Output $permissions | ConvertTo-Json -Depth 10
} catch {
    $ex = $PSItem
    if ($($ex.Exception.GetType().FullName -eq 'Microsoft.PowerShell.Commands.HttpResponseException') -or
        $($ex.Exception.GetType().FullName -eq 'System.Net.WebException')) {
        $errorObj = Resolve-OutSystemsRoleManagementError -ErrorObject $ex
        $auditMessage = "Could not retrieve OutSystems permissions. Error: $($errorObj.FriendlyMessage)"
        Write-Verbose "Error at Line '$($errorObj.ScriptLineNumber)': $($errorObj.Line). Error: $($errorObj.ErrorDetails)"
    }
    else {
        $auditMessage = "Could not retrieve OutSystems permissions. Error: $($ex.Exception.Message)"
        Write-Verbose "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"
    }
    $auditLogs.Add([PSCustomObject]@{
        Message = $auditMessage
        IsError = $true
    })
}
