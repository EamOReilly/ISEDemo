# Get the list of blobs from storage
$AzureCredential = Get-AutomationPSCredential -Name 'AzureCred'
Login-AzureRMAccount -credential $AzureCredential| Write-Verbose

$StorageAccountName = "modulearm"
$ResourceGroup = "armmodules"
$ModuleContainer = "armmodules"
$AutomationResourceGroup = "EamonISE"
$AutomationAccount = "EamonISE"
$AzureCred = "AzureCred"

$StorageKey = Get-AzureRMStorageAccountKey -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroup
$StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageKey.Key1
$ModuleBlobs = Get-AzureStorageBlob -Name $ModuleContainer -Context $StorageContext

# Upload the modules from storage except for the profile one since we already uploaded it.
foreach ($ModuleBlob in $ModuleBlobs)
{
    if ($ModuleBlob.Name -notmatch "azurerm.profile.zip")
    {
		$Params = @{"ModuleZipContentLink"=$ModuleBlob.ICloudBlob.Uri.AbsoluteUri;`
			"ResourceGroup"=$AutomationResourceGroup;"AutomationAccount"=$AutomationAccount;"AzureCredentialName"=$AzureCred}
		Start-AzureRmAutomationRunbook -Name Import-Module -Parameters $Params `
				-ResourceGroupName $AutomationResourceGroup -AutomationAccountName $AutomationAccount
    }
}