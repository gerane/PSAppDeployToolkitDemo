Remove-Module PSADTExtensions
. .\DemoApplication\Toolkit\AppDeployToolkit\AppDeployToolkitMain.ps1 -DisableLogging

# Download Toolkit
.\DownloadToolkit.ps1


Function Invoke-Demo {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [ValidateSet(
            'NonInteractive',
            'Silent',
            'LogOutput',
            'LogSeverity1',
            'LogSeverity2',
            'LogSeverity3',
            'LogSource',
            'OSArch',
            'Error',
            'Welcome',
            'WelcomeAllowDefer',
            'WelcomeAllowDeferCountdown',
            'WelcomeCloseApps',
            'WelcomeCloseAppsSilent',
            'WelcomeCloseAppsCountdown',
            'WelcomeCloseAppsCountdownForce',
            'WelcomeCloseAppsPromptToSave',
            'WelcomeBlockExecution',
            'WelcomeDiskSpace',
            'WelcomeDeferDeadline',
            'Balloon',
            'DialogBox',
            'DialogBoxYesNo',
            'DialogBoxTimeout',
            'DialogBoxCancelTryAgainContinue',
            'Progress',
            'ProgressSleep10',
            'ProgressBottomRight',
            'ProgressTopMostFalse',
            'ExitScript',
            'TestServiceExists'
        )]
        [String[]]$Demo,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Install','Uninstall')]
        [string]$DeploymentType = 'Install',

        [Parameter(Mandatory=$false)]
        [ValidateSet('Interactive','Silent','NonInteractive')]
        [string]$DeployMode = 'Interactive'
    )

    Start-Process -FilePath "C:\Github\PSAppDeployToolkitDemo\DemoApplication\Toolkit\Deploy-Application.exe" `
                  -ArgumentList "-Demo $Demo -DeploymentType $DeploymentType -DeployMode $DeployMode" `
                  -WindowStyle Hidden
}


# Example DeployMode NonInteractive, will force CloseApps even if Defer is set.
Invoke-Demo -Demo NonInteractive -DeployMode NonInteractive

# Example DeployMode Silent, will force CloseApps even if Defer is set.
Invoke-Demo -Demo Silent -DeployMode Silent

# Example Log Output
Invoke-Demo -Demo LogOutput

# Example Log with Information Severity
Invoke-Demo -Demo Severity1

# Example Log with Warning Severity
Invoke-Demo -Demo Severity2

# Example Log with Error Severity
Invoke-Demo -Demo Severity3

# Example with deployAppScriptFriendlyName Source
Invoke-Demo -Demo LogSource

# Example with Thrown Error
Invoke-Demo -Demo Error

# Example with Installation Welcome
Invoke-Demo -Demo Welcome

# Example with Installation Welcome with Allowing user to Defer 3 times
Invoke-Demo -Demo WelcomeAllowDefer

# Example with Installation Welcome with Allowing user to Defer 3 times
Invoke-Demo -Demo WelcomeAllowDeferCountdown

# Example with Installation Welcome that prompts to CloseApps if Running.
Invoke-Demo -Demo WelcomeCloseApps

# Example with Installation Welcome that silently Closes listed apps if running.
Invoke-Demo -Demo WelcomeCloseAppsSilent

# Example with Installation Welcome that allows user to defer app close
Invoke-Demo -Demo WelcomeDeferCloseApps

# Example with Installation Welcome that gives a countdown before apps are closed.
Invoke-Demo -Demo WelcomeCloseAppsCountdown

# Example with Installation Welcome that gives a countdown before apps are closed regardless of Defer.
Invoke-Demo -Demo WelcomeCloseAppsCountdownForce

# Example with Installation Welcome will prompt to save Documents before closing. Cannot be ran as SYSTEM.
Invoke-Demo -Demo WelcomeCloseAppsPromptToSave

# Example with Installation Welcome that blocks Execution of specified Apps.
Invoke-Demo -Demo WelcomeBlockExecution

# Example with Installation Welcome that checks for Required Disk Space
Invoke-Demo -Demo WelcomeDiskSpace

# Example with Installation Welcome that Allows Defer until a Deadline
Invoke-Demo -Demo WelcomeDeferDeadline

# Example with Balloon Tooltip
Invoke-Demo -Demo Balloon

# Example with Dialog Box
Invoke-Demo -Demo DialogBox

# Example prompting Yes or No and Acting on Response
Invoke-Demo -Demo DialogBoxYesNo

# Example with Dialog Box with Timeout
Invoke-Demo -Demo DialogBoxTimeout

# Example prompting
Invoke-Demo -Demo DialogBoxCancelTryAgainContinue

# Example with Progress Dialog
Invoke-Demo -Demo Progress

# Example with Progress Dialog that Sleeps 10 Seconds to simulate executiion.
Invoke-Demo -Demo ProgressSleep10

# Example with Progress Dialog in Bottom Right Corner
Invoke-Demo -Demo ProgressBottomRight

# Example with Progress Dialog that doesn't force itself to the top
Invoke-Demo -Demo ProgressTopMostFalse

# Example with Exit-Script to exit the script early.
Invoke-Demo -Demo ExitScript

# Example with Test-ServiceExists
Invoke-Demo -Demo TestServiceExists

# Example using Custom Extension with Logging
Invoke-Demo -Demo OSArch

