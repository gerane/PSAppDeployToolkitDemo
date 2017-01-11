<#
    .SYNOPSIS
        This script executes Plaster and uses the PSATPlasterTemplate
    .DESCRIPTION
        Example usage of using a Plaster Template with the PowerShell App Deploy Toolkit.
        Will Install Plaster if it is not Installed.
    .PARAMETER TemplatePath
        The path to the Plaster Template Folder
    .PARAMETER DestinationPath
        The Destination path for the new Toolkit Project
    .LINK
        http://psappdeploytoolkit.com
#>
[CmdletBinding()]
param
(
    [ValidateScript({Test-Path -Path $_})]
    [String]$TemplatePath = "$PSScriptRoot\PSATPlasterTemplate",

    [String]$DestinationPath = "$PSScriptRoot\DemoTemplateTest"
)

Try
{
    # If (! (Get-Module -Name "Plaster" -ListAvailable))
    # {
    #     Install-Module Plaster
    # }

    Invoke-Plaster -TemplatePath $TemplatePath -DestinationPath $DestinationPath
}
Catch
{
    Throw
}