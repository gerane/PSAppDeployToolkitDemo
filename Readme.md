# PowerShell App Deployment Toolkit

URL to Demo Files [https://github.com/gerane/PSAppDeployToolkitDemo](https://github.com/gerane/PSAppDeployToolkitDemo)

The PowerShell App Deployment Toolkit is a wrapper Toolkit for deploying applications in an Enterprise. For more information see the link below:

[PSAppDeployToolkit](http://psappdeploytoolkit.com/)


## Demo Scripts

* To Download the latest Toolkit you can use the **DownloadToolkit.ps1** Script included in the Repository.
* To Test out the Plaster Template use the **InvokePlasterExample.ps1** Script that uses the Plaster Template in **PSATPlasterTemplate**. This Template is complete except for any environment specific changes you may need.
* To view the external Help console Application you can use the **OpenHelpExternal.ps1** Script.
* The **Examples.ps1** Script contains most of the examples covered. Invoke-Demo in the script` is a wrapper that executes the **DemoApplication** with a Custom Param for the Demo Name. Example Below:

```powershell
Invoke-Demo -DeployMode Interactive -Demo WelcomeAllowDefer

Invoke-Demo -DeployMode NonInteractive -Demo NonInteractive
```




## Features

* Block Application execution while running installers
* Customizable Prompts for Users to accept or defer
* Set list of Applications to prompt user to close if they need to be closed during the installation with customizable settings
* Integration with SCCM with support for the fast Retry feature and Supports SCCM exit codes. Can Block Reboot ExitCodes from being passed back
* Offers Install and Uninstall sections that can be invoked from the same Toolkit.
* Extensible with **AppDeployToolkitExtensions.ps1**
* A number of customizable prompts for User interaction and Information.
* Baloon Tooltip Notifications.

## Help

The Toolkit offers a couple different forms of Help for the user. There is an Administration guide called **PSAppDeploymentToolkitAdminGuide.docx** and the toolkit itself has a PowerShell script **AppDeployToolkitHelp.ps1** inside the AppDeployToolkit folder that opens a PowerShell GUI with Help for all of the commands inside of the Toolkit.


## Configuration

* Icons for the Banner and Application icons can be customized by making new Icons.
* Log Directory can be set in config
* Default MSI Options for Installs, Uninstalls, Silent etc can be set in config
* MutexWaitTime: Length of time to wait for the Msi service to free up.
* UI Options like Baloon Tooltips
* Customize what all of the text in the Message Prompts


## Logging

* CMTrace and Legacy Formats
* Can log output to logs and console at same time.
* Can be logged to Central Location with custom log directory in config.


## Deploy-Application

* Toolkit Sections for organization. Pre-Installation, Installation, Post-Installation, and UnInstallation.
* DeployMode
    * Interactive = Shows dialogs
    * Silent = No dialogs (progress and balloon tip notifications are supressed)
    * NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.
* Offers a very large number of built in Variables that can save some time.


## Development

* Extensions can be added in the **AppDeployToolkitExtensions.ps1** Script
    * I use a similar approach to Modules and have the **AppDeployToolkitExtensions.ps1** act as my psm1.
    * It dot sources all of the Extensions Stored in Public/Private Folders
    * Example Included with **DemoApplication**
* Dot Source the **AppDeployToolkitMain.ps1** Script
    * I disable console output logging by default
    * I also pass -disablelogging to the **AppDeployToolkitMain.ps1** Script when I dot source it
    * Example Below

```powershell
. "C:\Path\To\AppDeployToolkitMain.ps1" -DisableLogging
```


## Examples

```powershell
# Deploy an application for uninstallation in silent mode
Deploy-Application.exe -DeploymentType "Uninstall" -DeployMode "Silent"

# Deploy an application for Installation and supress All dialogs in Non Interactive Mode
Deploy-Application.exe -DeploymentType "Install" -DeployMode "NonInteractive"

# Deploy an application for installation, supressing the PowerShell console window and allowing reboot codes to be returned to the parent process.
Deploy-Application.exe -DeploymentType "Install" -AllowRebootPassThru

# Deploy an application for uninstallation using PowerShell x86, supressing the PowerShell console window and deploying in silent mode.
Deploy-Application.exe /32 -DeploymentType "Uninstall" -DeployMode "Silent"
```


## Tips

* When working with the xml Config files, ensure you do not change the file format.
* Use Plaster to easily Scaffold new Toolkit projects.
* Dot Source the **AppDeployToolkitMain.ps1** file to get the variables and commands while writing your scripts.
* Set Debug/Development dirSupportfiles and dirFiles variables to match the ones in the Toolkit you are writing coding.
* When Dot Sourcing you may want to disable Logging to terminal.
* If Execution of an Application does not get killed, Unblock-AppExecution can remove it, but this sets a Debugger registry key here `HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options` for the processes you want to block. Instead of assigning a Debugger it is running PowerShell to display the Blocked App Message. Normally, Unblock-AppExecution is called at the end with Exit-Script and there is a scheduled task that is also set to attempt to remove the Blocked App in case the script was terminated unexpectedly.


