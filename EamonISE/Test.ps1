Get-Date
$foo = Get-Module -ListAvailable
Get-Date
$creds = Get-AutomationPSCredential -Name 'AzureCred'
	
#Add-AzureAccount -credential $creds

Login-AzureRMAccount -credential $creds

#Get-AzureVM

$VMs = Get-AzureRMVM
$VMs.Name