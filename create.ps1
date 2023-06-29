###########################################################
# HelloID-Conn-Prov-Target-OutSystems-RoleManagement-Create
#
# Version: 1.0.0
###########################################################
# Initialize default values
$p = $person | ConvertFrom-Json
$success = $false
$auditLogs = [System.Collections.Generic.List[PSCustomObject]]::new()

$account = [PSCustomObject]@{
    UserName = $p.Accounts.MicrosoftActiveDirectory.mail
}

try {
    if (-not($dryRun -eq $true)) {
        Write-Verbose 'Correlating OutSystems account'
        $accountReference = $($account.UserName)
        $success = $true
        $auditLogs.Add([PSCustomObject]@{
                Message = "Correlate account was successful. AccountReference is: [$accountReference]"
                IsError = $false
            })
    }
} catch {
    $success = $false
    $ex = $PSItem
    $auditMessage = "Could not correlate OutSystems-RoleManagement account. Error: $($ex.Exception.Message)"
    Write-Verbose "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"
    $auditLogs.Add([PSCustomObject]@{
            Message = $auditMessage
            IsError = $true
        })
} finally {
    $result = [PSCustomObject]@{
        Success          = $success
        AccountReference = $accountReference
        Auditlogs        = $auditLogs
        Account          = $account
    }
    Write-Output $result | ConvertTo-Json -Depth 10
}
