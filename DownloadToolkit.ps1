<#
    .SYNOPSIS
        This script downloads the latest version of the Toolkit.
    .DESCRIPTION
        This script downloads the latest version of the PowerShell App Deployment Toolkit.
        It downloads the toolkit using the latest release from the Github Api.
    .PARAMETER Destination
        The Destination Folder to Download the Toolkit to.
    .LINK
        http://psappdeploytoolkit.com
#>
[CmdletBinding()]
param
(
    [ValidateScript({Test-Path -Path $_ -PathType Container})]
    [String]$Destination = $PSScriptRoot
)

Try
{
    $Rest = Invoke-RestMEthod 'https://api.github.com/repos/PSAppDeployToolkit/PSAppDeployToolkit/releases/latest'

    [ValidateNotNullOrEmpty()]$Uri = $Rest.assets.browser_download_url
    [ValidateNotNullOrEmpty()]$FileName = $Uri.split('/')[-1]

    Invoke-RestMethod -Method Get -Uri $Uri -OutFile "$Env:Temp\$FileName"

    Microsoft.PowerShell.Archive\Expand-Archive -Path "$Env:Temp\$FileName" -DestinationPath $Destination

    Remove-Item -Path "$Env:Temp\$FileName" -Recurse -Force
}
Catch
{
    Throw
}
