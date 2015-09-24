workflow HelloWorld
{
    param (
        [String]
        $Name
    )
    $VerbosePreference = 'Continue'

    Write-Output ("Hello " + $Name)

    $BuildServer = Get-AutomationVariable -Name BuildServer
    $BuildServer

}