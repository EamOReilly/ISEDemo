Workflow QueryOMS
{
    $User = "eamon@eamonoreillyhotmail.onmicrosoft.com"
    $Password = Get-AutomationVariable -Name 'Password'
    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

    $credentials = Get-AutomationPSCredential -Name AzureCred


    # Azure AD domain to authenticate against
    $AzureADDomain = "eamonoreillyhotmail.onmicrosoft.com"

    
    # Generate a JWT token that can manage Azure resources. 
    # Use management.core.windows.net for service management API & ARM. Use mangement.azure.com for ARM only API
    $AppIdURI = "https://management.core.windows.net/"

    # Set up connection object to pass into Invoke-AzureADMethod
    $ADConnection = @{"Username"=$User;"AzureADDomain"=$AzureADDomain;"Password"=$Password;"APPIdURI"=$AppIdURI;}


    $Token = Get-AzureADToken -Connection $ADConnection

    $SubID = "a0968138-bb95-4d6e-8e83-ddb706025359"

    $WorkSpace = "eamondemo"
    $Region = "East-US"
    $APIVersion = "2014-10-10"

    $Query = 'Type:Alert AlertSeverity:Error AlertState!=Closed AlertName="Run As Account does not exist on the target system or does not have enough permissions"'

    $WorkspaceInfo = Get-OMSWorkspace -Token $Token -SubscriptionID $SubID -Region $Region -APIVersion $APIVersion
    $WorkSpaceInfo.Name

    $Results = Search-OMSWorkspace -Token $Token -Query $Query -SubscriptionID $SubID -WorkSpace $WorkSpace -Region $Region
    $Results.AlertName

    # Set username to blank since it is not used when using a secret key for an application
    # Secret key is put into the password
    $Secret = "94kOr/JQr6KBfWAg6LDkf56ZVGPde8QbuYaPWagxWlY="
    
    # Change this to what you need. Refer to https://msdn.microsoft.com/en-us/library/azure/gg592580.aspx
    # and https://msdn.microsoft.com/en-us/library/azure/8d088ecc-26eb-42e9-8acc-fe929ed33563#bk_common for ARM version information
    # 2015-01-01 is the latest at the moment for ARM resources
    $APIVersion = "2015-01-01"

    # Client ID for the application
    $ClientID = "a1660f72-503d-4337-bcc0-5e521a3e8586"

    $ADConnection = @{"AzureADDomain"=$AzureADDomain;"Secret"=$Secret;"APPIdURI"=$AppIdURI;"ClientID"=$ClientId;}

    $Token = Get-AzureADToken -Connection $ADConnection

    $SubID = "a0968138-bb95-4d6e-8e83-ddb706025359"

    $WorkSpace = "contosoeamon"

    $Query = 'Type:Alert AlertSeverity:Error AlertState!=Closed AlertName="Run As Account does not exist on the target system or does not have enough permissions"'

    $APIVersion = "2014-10-10"
    $OMSConnection = @{"WorkSpace"=$WorkSpace;"SubscriptionID"=$SubID;"Region"=$Region;"APIVersion"=$APIVersion}

    $WorkspaceInfo = Get-OMSWorkspace -Token $Token -Connection $OMSConnection

    $Results = Search-OMSWorkspace -Token $Token -Query $Query -Connection $OMSConnection
    $Results.AlertName
}

