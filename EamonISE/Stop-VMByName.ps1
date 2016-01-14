workflow Stop-VMByName
{
    param (
        [Parameter(Mandatory=$False)]
        [string] $MachineMatch
    )

    $VerbosePreference = 'continue'

    $AzureCred = Get-AutomationPSCredential -Name 'AzureCred'
    Add-AzureAccount -Credential $AzureCred | Write-Verbose
         

    Get-AzureVM | ForEach-Object {
        If (($_.Name -match $MachineMatch) -and ($_.Status -eq "ReadyRole"))
        {
            Write-Output ("Stopping :" +  $_.Name)
            Stop-AzureVM -ServiceName $_.ServiceName -Name $_.Name -Force | Write-Verbose
        } 
    } 
}