workflow Start-VMByName
{
    Param(
        [Parameter(Mandatory=$False)]
        [String] $MachineMatch
    )

    $VerbosePreference = 'continue'
    
    $AzureCred = Get-AutomationPSCredential -Name 'AzureCred'
    Add-AzureAccount -Credential $AzureCred | Write-Verbose
         
    Get-AzureVM | ForEach-Object {
        If (($_.Name -match $MachineMatch) -and ($_.Status -eq "StoppedDeallocated"))
        {
            Write-Output ("Starting :"  + $_.Name)
            Start-AzureVM -ServiceName $_.ServiceName -Name $_.Name | Write-Verbose
        }
    }

}