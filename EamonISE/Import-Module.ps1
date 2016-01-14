param
(
    [String]
    $ModuleZipContentLink,
    [String]
    $ResourceGroup,
    [String]
    $AutomationAccount,
	[String]
	$AzureCredentialName
)

$AzureCred = Get-AutomationPSCredential -Name $AzureCredentialName
Login-AzureRMAccount -Credential $AzureCred

$ModuleFileName = Split-Path $ModuleZipContentLink -Leaf
$ModuleName = [system.io.path]::GetFileNameWithoutExtension($ModuleFileName)

$Job = New-AzureRmAutomationModule -ResourceGroupName $ResourceGroup -AutomationAccountName $AutomationAccount -Name $ModuleName -ContentLink $ModuleZipContentLink

 while( ($Job.ProvisioningState -eq "Creating") ) {

    $Job = Get-AzureRMAutomationModule -ResourceGroupName $ResourceGroup -AutomationAccountName $AutomationAccount -Name $ModuleName
    Write-Output ($Job.ProvisioningState + " " + $Job.Name)
    Sleep 10
}
