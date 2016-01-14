# Get credential to perform actions against Azure resources and login with this credential
$Cred = Get-AutomationPSCredential -Name "AzureCred"
Login-AzureRmAccount -Credential $Cred | Write-Verbose

# Set up the resource group and automation account that we are working against
$ResourceGroupName = "EamonISE"
$AutomationAccountName = "EamonISE"

# Specify the runbook and parameters that we will are creating a schedule for
$RunbookName = "Stop-TestVM"

# Create a hashtable of the parameters for this runbook
$Params = @{"MachineMatch"="TestVM";
            "Tag"="Test"}

# The time that this schedule should trigger
$StartTime = (Get-Date).AddMinutes(10) 

# Create a new one time schedule for the above time with a unique name
$OneTimeSchedule = New-AzureRMAutomationSchedule -Name ("NewDeployment" + [System.Guid]::NewGuid()) -StartTime $StartTime -OneTime -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName 

# Associate this new schedule with the runbook
$RunbookSchedule = Register-AzureRmAutomationScheduledRunbook -RunbookName $RunbookName -ScheduleName $OneTimeSchedule.Name -Parameters $Params -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName

# Clean up schedule if not used anymore
#Remove-AzureRmAutomationSchedule -Name $OneTimeSchedule.Name -Force -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName