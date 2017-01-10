# Download the Toolkit
    * The **DownloadToolkit.ps1** script will download the latest Toolkit from Github and extract it to specified Directory.


# Features
    * Block Application execution while running installers
    * Customizable Prompts for Users to accept or defer
    * Set list of Applications to prompt user to close if they need to be closed during the installation with customizable settings
    * Integration with SCCM with support for the fast Retry feature and Supports SCCM exit codes. Can Block Reboot ExitCodes from being passed back
    * Offers Install and Uninstall sections that can be invoked from the same Toolkit.
    * Extensible with **AppDeployToolkitExtensions.ps1**
    * A number of customizable prompts for User interaction and Information.
    * Baloon Tooltip Notifications.


# Help
    * Docx Help
    * PowerShell GUI Help


# Icons
    * The Banner and Application icons can be customized.


# Logging
    * CMTrace Format
    * Can be logged to Central Location


# Configuration
    * Log Directory
    * Default MSI Options for Installs, Uninstalls, Silent etc.
    * MutexWaitTime: Length of time to wait for the Msi service to free up.
    * UI Options like Baloon Tooltips
    * Customize what all of the text in the Message Prompts


# Variables
    * Offers a very large number of built in Variables that can save some time.

# Deploy-Application.ps1
    * Toolkit Sections for organization. Pre-Installation, Installation, Post-Installation, and UnInstallation.
    * DeployMode
        * Interactive = Shows dialogs
        * Silent = No dialogs (progress and balloon tip notifications are supressed)
        * NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.


# Development
    * Dot Source the AppDeployToolkitMain.ps1 Script
        * EX: **ImportToolkitDev.ps1**
        * I disable logging by default


# Extensions
    * **AppDeployToolkitExtensions.ps1**
    * I use a similar approach to Modules and have the **AppDeployToolkitExtensions.ps1** act as my psm1.
        * It dot sources all of the Extensions Stored in Public/Private Folders

# Plaster
    * Not needed, but wanted to show how Plaster and the Toolkit can be used together


# Examples

```PowerShell
Deploy-Application.exe -DeploymentType "Uninstall" -DeployMode "Silent"
```