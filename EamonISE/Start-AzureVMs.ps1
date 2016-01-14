<#
.SYNOPSIS
    Connects to Azure and starts of all VMs in the specified Azure subscription or cloud service

.DESCRIPTION
   This runbook connects to Azure and starts all VMs in the specified Azure cloud service, 
   or if that parameter has no value, it starts all VMs in an Azure subscription.    
   You can run this runbook on a daily schedule to start your VMs each day of the week. 

.PARAMETER AzureADCredentialAssetName
   The string name of the Automation credential asset this runbook will use to authenticate to Azure.
   To learn more about getting set up to authenticate to Azure see this blog http://aka.ms/runbookauthor/authentication. 
   You can also learn more about configuring Azure Automation at http://aka.ms/getsetuptoautomate.  

   Defaults to DefaultAzureCredential. 

.PARAMETER AzureSubscriptionName
   The name of the Azure subscription that this runbook will connect to. Optional - if no value is specified the runbook will use the default
   Azure subscription for the provided AzureAdCredential.

.PARAMETER ServiceName
   An optional parameter that allows you to specify the cloud service containing the VMs to start.  
   If this parameter is included, only VMs on the specified cloud service will be started, otherwise all VMs 
   in the subscription will be started.  


.NOTES
   AUTHOR: System Center Automation Team 
   LASTEDIT: April 9, 2015
    
#>

workflow Start-AzureVMs
{   
    param (
        [parameter(Mandatory=$false)] 
        [String]  $AzureADCredentialAssetName = 'DefaultAzureCredential',
        
        [Parameter(Mandatory=$False)]
        [String] $AzureSubscriptionName = 'default',

        [parameter(Mandatory=$false)] 
        [String] 
        $ServiceName
    )

    # Returns VMs that were started
    [OutputType([PersistentVMRoleContext])]

	$Cred = Get-AutomationPSCredential -Name $AzureADCredentialAssetName
    if ($Cred -eq $null)
    {
        throw "Could not retrieve $AzureADCredentialAssetName credential asset. Check that you created this first in the Automation service."
    }

	# Connect to Azure and select the subscription to work against
	Add-AzureAccount -Credential $Cred -ErrorAction Stop| Write-Verbose

    # Select the subscription if a subscription name is provided 
    if($AzureSubscriptionName -and ($AzureSubscriptionName.Length > 0) -and ($AzureSubscriptionName -ne "default")) {
        Select-AzureSubscription -Name $AzureSubscriptionName | Write-Verbose
    }

	# If there is a specific cloud service, get all stopped VMs in the service 
    # otherwise get all stopped VMs in the subscription
    if ($ServiceName) {
        $VMs = Get-AzureVM -ServiceName $ServiceName | Where-Object -FilterScript{$_.Status -like 'Stopped*' }
    }
    else {
        $VMs = Get-AzureVM | Where-Object -FilterScript{$_.Status -like 'Stopped*' } 
    }

    # Start each of the VMs
    foreach -parallel ($VM in $VMs)
    {       
         
        $StartRtn = Start-AzureVM -Name $VM.Name -ServiceName $VM.ServiceName -ErrorAction SilentlyContinue
        $Count = 1

        if(($StartRtn.OperationStatus) -ne 'Succeeded')
        {
            do
            {
                Write-Verbose "Failed to start $($VM.Name). Retrying in 60 seconds..."
                Start-Sleep -Seconds 60
                $StartRtn = Start-AzureVM -Name $VM.Name -ServiceName $VM.ServiceName  -ErrorAction SilentlyContinue
                $Count++
            }
            while(($StartRtn.OperationStatus) -ne 'Succeeded' -and $Count -lt 5)
         
        }
           
        # Check if the VM started successfully
        if(($StartRtn.OperationStatus) -ne 'Succeeded')
        {
            Write-Error "$($VM.Name) failed to start.  VM operation status: ($StartRtn.OperationStatus)."
        }
        else 
        {
            Write-Output $VM
        }

    }
}