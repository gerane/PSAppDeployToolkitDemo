$command = "& `"$PSScriptRoot\PSAppDeployToolkit_v3.6.8\Toolkit\AppDeployToolkit\AppDeployToolkitHelp.ps1`""
start-process powershell -ArgumentList "-windowstyle hidden -NoProfile -command $command"