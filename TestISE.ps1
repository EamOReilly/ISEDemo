Workflow TestISE
{
    $Cred = Get-AutomationPSCredential -Name 'DefaultAzureCredential'
    Write-Output ("Username is :" + $Cred.UserName)


}