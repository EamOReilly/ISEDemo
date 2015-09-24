Workflow Get-VMList
{
    $Cred = Get-AutomationPSCredential -Name AzureCred
    Add-AzureAccount -Credential $Cred | Write-Verbose
    Get-AzureVM
}