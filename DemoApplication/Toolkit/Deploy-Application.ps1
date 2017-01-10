<#
    .SYNOPSIS
        This script performs the installation or uninstallation of an application(s).
    .DESCRIPTION
        The script is provided as a template to perform an install or uninstall of an application(s).
        The script either performs an "Install" deployment type or an "Uninstall" deployment type.
        The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.
        The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.
    .PARAMETER DeploymentType
        The type of deployment to perform. Default is: Install.
    .PARAMETER DeployMode
        Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.
    .PARAMETER AllowRebootPassThru
        Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.
    .PARAMETER TerminalServerMode
        Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Destkop Session Hosts/Citrix servers.
    .PARAMETER DisableLogging
        Disables logging to file for the script. Default is: $false.
    .EXAMPLE
        Deploy-Application.ps1
    .EXAMPLE
        Deploy-Application.ps1 -DeployMode 'Silent'
    .EXAMPLE
        Deploy-Application.ps1 -AllowRebootPassThru -AllowDefer
    .EXAMPLE
        Deploy-Application.ps1 -DeploymentType Uninstall
    .NOTES
        Toolkit Exit Code Ranges:
        60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
        69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
        70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
    .LINK
        http://psappdeploytoolkit.com
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    [ValidateSet('Install','Uninstall')]
    [string]$DeploymentType = 'Install',
    [Parameter(Mandatory=$false)]
    [ValidateSet('Interactive','Silent','NonInteractive')]
    [string]$DeployMode = 'Interactive',
    [Parameter(Mandatory=$false)]
    [switch]$AllowRebootPassThru = $false,
    [Parameter(Mandatory=$false)]
    [switch]$TerminalServerMode = $false,
    [Parameter(Mandatory=$false)]
    [switch]$DisableLogging = $false,
    [Parameter(Mandatory=$false)]
    [String[]]$Demo
)

Try {
    ## Set the script execution policy for this process
    Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch {}

    ##*===============================================
    ##* VARIABLE DECLARATION
    ##*===============================================
    ## Variables: Application
    [string]$appVendor = 'NashPUG'
    [string]$appName = 'DemoApplication'
    [string]$appVersion = '1.0.0'
    [string]$appArch = ''
    [string]$appLang = 'EN'
    [string]$appRevision = '01'
    [string]$appScriptVersion = '1.0.0'
    [string]$appScriptDate = '1/9/2017'
    [string]$appScriptAuthor = 'Brandon Padgett2'
    ##*===============================================
    ## Variables: Install Titles (Only set here to override defaults set by the toolkit)
	[string]$installName = ''
	[string]$installTitle = ''

    ##* Do not modify section below
    #region DoNotModify

    ## Variables: Exit Code
    [int32]$mainExitCode = 0

    ## Variables: Script
    [string]$deployAppScriptFriendlyName = 'Deploy Application'
    [version]$deployAppScriptVersion = [version]'3.6.8'
    [string]$deployAppScriptDate = '02/06/2016'
    [hashtable]$deployAppScriptParameters = $psBoundParameters

    ## Variables: Environment
    If (Test-Path -LiteralPath 'variable:HostInvocation') { $InvocationInfo = $HostInvocation } Else { $InvocationInfo = $MyInvocation }
    [string]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent

    ## Dot source the required App Deploy Toolkit Functions
    Try {
        [string]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
        If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) { Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]." }
        If ($DisableLogging) { . $moduleAppDeployToolkitMain -DisableLogging } Else { . $moduleAppDeployToolkitMain }
    }
    Catch {
        If ($mainExitCode -eq 0){ [int32]$mainExitCode = 60008 }
        Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
        ## Exit the script, returning the exit code to SCCM
        If (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } Else { Exit $mainExitCode }
    }

    #endregion
    ##* Do not modify section above
    ##*===============================================
    ##* END VARIABLE DECLARATION
    ##*===============================================

    If ($deploymentType -ine 'Uninstall') {
        ##*===============================================
        ##* PRE-INSTALLATION
        ##*===============================================
        [string]$installPhase = 'Pre-Installation'

        ## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt
        Show-InstallationWelcome

        ## Show Progress Message (with the default message)
        Show-InstallationProgress "Installing $installTitle `nPlease wait..."

        ## <Perform Pre-Installation tasks here>


        ##*===============================================
        ##* INSTALLATION
        ##*===============================================
        [string]$installPhase = 'Installation'

        ## Handle Zero-Config MSI Installations
        If ($useDefaultMsi) {
            [hashtable]$ExecuteDefaultMSISplat =  @{ Action = 'Install'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
            Execute-MSI @ExecuteDefaultMSISplat; If ($defaultMspFiles) { $defaultMspFiles | ForEach-Object { Execute-MSI -Action 'Patch' -Path $_ } }
        }

        ## <Perform Installation tasks here>

        Switch ($Demo)
        {
            'NonInteractive'
            {
                Start-Process Notepad
                Start-Sleep -Seconds 3
                Show-InstallationWelcome -CloseApps 'Notepad' -AllowDeferCloseApps -DeferTimes 1
            }

            'Silent'
            {
                Start-Process Notepad
                Start-Sleep -Seconds 3
                Show-InstallationWelcome -CloseApps 'Notepad' -AllowDeferCloseApps -DeferTimes 1
            }

            'LogOutput'
            {
                Write-Log -Message "Demo Message"
            }

            'LogSeverity1'
            {
                Write-Log -Message "Demo Message" -Severity 1 -Source $_
            }

            'LogSeverity2'
            {
                Write-Log -Message "Demo Message" -Severity 2 -Source $_
            }

            'LogSeverity3'
            {
                Write-Log -Message "Demo Message" -Severity 3 -Source $_
            }

            'LogSource'
            {
                Write-Log -Message "Demo Message" -Severity 1 -Source $deployAppScriptFriendlyName
            }

            'OSArch'
            {
                $Arch = Get-OSArchitecture
                Write-Log -Message "Architecture: $Arch" -Severity 1 -Source $_
            }

            'Error'
            {
                Write-Log -Message "Throwing Error" -Severity 3 -Source $_
                Throw "This is what an Error looks like"
            }

            'Welcome'
            {
                Show-InstallationWelcome
                Start-Sleep -Seconds 5
            }

            'WelcomeAllowDefer'
            {
                Show-InstallationWelcome -AllowDefer -DeferTimes 1
                Execute-Process -Path "$dirSupportFiles\Regjump.exe" -Parameters 'HKEY_LOCAL_MACHINE\SOFTWARE\PSAppDeployToolkit\DeferHistory' -NoWait -CreateNoWindow
            }

            'WelcomeAllowDeferCountdown'
            {
                Show-InstallationWelcome -AllowDefer -DeferTimes 1 -ForceCountdown 5
            }

            'WelcomeCloseApps'
            {
                Start-Process Notepad
                Start-Sleep -Seconds 1
                Show-InstallationWelcome -CloseApps 'Notepad' -AllowDefer -DeferTimes 3
            }

            'WelcomeCloseAppsSilent'
            {
                Start-Process Notepad
                Start-Sleep -Seconds 3
                Show-InstallationWelcome -CloseApps 'Notepad' -Silent
            }

            'WelcomeDeferCloseApps'
            {
                Start-Process Notepad
                Start-Sleep -Seconds 3
                Show-InstallationWelcome -CloseApps 'Notepad' -AllowDeferCloseApps -DeferTimes 1
            }

            'WelcomeCloseAppsCountdown'
            {
                Start-Process Notepad
                Start-Sleep -Seconds 3
                Show-InstallationWelcome -CloseApps 'Notepad' -CloseAppsCountdown 10 -AllowDefer -DeferTimes 1
            }

            'WelcomeCloseAppsCountdownForce'
            {
                Start-Process Notepad
                Start-Sleep -Seconds 3
                Show-InstallationWelcome -CloseApps 'Notepad' -AllowDeferCloseApps -DeferTimes 1 -ForceCloseAppsCountdown 10
            }

            'WelcomeCloseAppsPromptToSave'
            {
                Get-Random | Out-File -FilePath $Env:Temp\Demo.txt
                Start-Process Notepad -ArgumentList "$Env:Temp\Demo.txt"
                Start-Sleep -Seconds 10
                Show-InstallationWelcome -CloseApps 'Notepad' -PromptToSave
                Remove-Item "$Env:Temp\Demo.txt"
            }

            'WelcomeBlockExecution'
            {
                Start-Process Notepad
                Start-Sleep -Seconds 3
                Show-InstallationWelcome -CloseApps 'Notepad' -BlockExecution
                Start-Sleep -Seconds 5
                Start-Process Notepad
                Start-Sleep -Seconds 5
                Start-Process Notepad
            }

            'WelcomeDiskSpace'
            {
                Show-InstallationWelcome -CheckDiskSpace -RequiredDiskSpace 1000000
            }

            'WelcomeDeferDeadline'
            {
                Show-InstallationWelcome -AllowDefer -DeferDeadline ((Get-Date).AddDays('3'))
            }

            'Balloon'
            {
                Show-BalloonTip -BalloonTipText 'Test Balloons' -BalloonTipTitle 'Demo'
            }

            'DialogBox'
            {
                $Results = Show-DialogBox -Title 'Demo' -Text 'Installation has completed. Please click OK and restart your computer.' -Icon 'Information'
                Write-Log -Message $Results -Severity 2 -Source $_
            }

            'DialogBoxYesNo'
            {
                $Results = Show-DialogBox -Title 'Demo' -Text 'Installation has completed. Do you want to Restart your Computer?' -Icon Question -Buttons YesNo
                Write-Log -Message $Results -Severity 2 -Source $_

                if ($Results -eq 'Yes')
                {
                    Show-DialogBox -Title 'User Choice' -Text 'The User Selected "Yes"' -Icon 'Information'
                }
                elseif ($Results -eq 'No')
                {
                    Show-DialogBox -Title 'User Choice' -Text 'The User Selected "No"' -Icon 'Information'
                }
                else
                {
                    Write-Log -Message "Enexpected Choice: $Results" -Severity 3 -Source $_
                    Throw "Enexpected Choice: $Results"
                }
            }

            'DialogBoxCancelTryAgainContinue'
            {
                $Results = Show-DialogBox -Title 'Demo' -Text 'Could not finish Action. Do you want to Restart your Computer?' -Icon Question -Buttons CancelTryAgainContinue
                Write-Log -Message $Results -Severity 2 -Source $_

                if ($Results -eq 'Try Again')
                {
                    Show-DialogBox -Title 'User Choice' -Text 'The User Selected "Try Again"' -Icon 'Information'
                }
                elseif ($Results -eq 'Continue')
                {
                    Show-DialogBox -Title 'User Choice' -Text 'The User Selected "Continue"' -Icon 'Information'
                }
                elseif ($Results -eq 'Cancel')
                {
                    Show-DialogBox -Title 'User Choice' -Text 'The User Selected "Cancel"' -Icon Exclamation
                }
                else
                {
                    Write-Log -Message "Enexpected Choice: $Results" -Severity 3 -Source $_
                    Throw "Enexpected Choice: $Results"
                }
            }

            'DialogBoxTimeout'
            {
                $Results = Show-DialogBox -Title 'Demo' -Text 'Installation has completed. Do you want to Restart your Computer?' -Icon Question -Buttons YesNo -Timeout 5
                Write-Log -Message $Results -Severity 2 -Source $_

                if ($Results -eq 'Yes')
                {
                    Show-DialogBox -Title 'User Choice' -Text 'The User Selected "Yes"' -Icon 'Information'
                }
                elseif ($Results -eq 'No')
                {
                    Show-DialogBox -Title 'User Choice' -Text 'The User Selected "No"' -Icon 'Information'
                }
                elseif ($Results -eq 'Timeout')
                {
                    Show-DialogBox -Title 'User Choice' -Text 'Timeout Reached. Results: "Timeout' -Icon Exclamation
                }
                else
                {
                    Write-Log -Message "Enexpected Choice: $Results" -Severity 3 -Source $_
                    Throw "Enexpected Choice: $Results"
                }
            }

            'Progress'
            {
                Show-InstallationProgress -StatusMessage 'Installation in Progress...'
            }

            'ProgressSleep10'
            {
                Show-InstallationProgress -StatusMessage 'Installation in Progress...'
                Write-Log -Message "Sleepiing 5 Seconds" -Severity 1 -Source $_
                Start-Sleep -Seconds 10
            }

            'ProgressBottomRight'
            {
                Close-InstallationProgress
                Show-InstallationProgress -WindowLocation BottomRight
                Start-Sleep -Seconds 5
            }

            'ProgressTopMostFalse'
            {
                Close-InstallationProgress
                Show-InstallationProgress -TopMost $False -StatusMessage 'Installation in Progress...' -WindowLocation BottomRight
                Start-Sleep -Seconds 5
            }

            'TestServiceExists'
            {
                $Results = Test-ServiceExists -Name 'Fake Name'
                Write-Log -Message "Fake Name Exists Results: $Results" -Severity 2 -Source $_

                $Results = Test-ServiceExists -Name 'Dhcp'
                Write-Log -Message "Dhcp Exists Results: $Results" -Severity 2 -Source $_
            }
        }


        ##*===============================================
        ##* POST-INSTALLATION
        ##*===============================================
        [string]$installPhase = 'Post-Installation'

        ## <Perform Post-Installation tasks here>

        ## Display a message at the end of the install
        If (-not $useDefaultMsi) { Show-InstallationPrompt -Message "Installation of $installTitle has completed." -ButtonRightText 'OK' -Icon Information -NoWait }
    }
    ElseIf ($deploymentType -ieq 'Uninstall')
    {
        ##*===============================================
        ##* PRE-UNINSTALLATION
        ##*===============================================
        [string]$installPhase = 'Pre-Uninstallation'

        ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
        Show-InstallationWelcome -CloseApps 'iexplore' -CloseAppsCountdown 60

        ## Show Progress Message (with the default message)
        Show-InstallationProgress

        ## <Perform Pre-Uninstallation tasks here>


        ##*===============================================
        ##* UNINSTALLATION
        ##*===============================================
        [string]$installPhase = 'Uninstallation'

        ## Handle Zero-Config MSI Uninstallations
        If ($useDefaultMsi) {
            [hashtable]$ExecuteDefaultMSISplat =  @{ Action = 'Uninstall'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
            Execute-MSI @ExecuteDefaultMSISplat
        }

        # <Perform Uninstallation tasks here>


        ##*===============================================
        ##* POST-UNINSTALLATION
        ##*===============================================
        [string]$installPhase = 'Post-Uninstallation'

        ## <Perform Post-Uninstallation tasks here>


    }

    ##*===============================================
    ##* END SCRIPT BODY
    ##*===============================================

    ## Call the Exit-Script function to perform final cleanup operations
    Exit-Script -ExitCode $mainExitCode

}
Catch
{
    [int32]$mainExitCode = 60001
    [string]$mainErrorMessage = "$(Resolve-Error)"
    Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
    Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
    Exit-Script -ExitCode $mainExitCode
}

