Function Get-IdleTime
{
<#
    .SYNOPSIS
        Gets the time information on how long a User has had input.

    .DESCRIPTION
        Collects user input information and idle times.


    .EXAMPLE
        Get-IdleTime
        
        Days              : 0
        Hours             : 0
        Minutes           : 0
        Seconds           : 0
        Milliseconds      : 16
        Ticks             : 160000
        TotalDays         : 1.85185185185185E-07
        TotalHours        : 4.44444444444444E-06
        TotalMinutes      : 0.000266666666666667
        TotalSeconds      : 0.016
        TotalMilliseconds : 16
        
        This command Returns a [TimeSpan] object 


    .INPUTS
        None

    .OUTPUTS
        System.TimeSpan

    .NOTES
        This function is an Extension that can be used with PSAppDeployToolkit. These Extensions can be used in two ways.
        
        1. Using Extensions with PSAppDeployToolkit (Release\Toolkit\PSADTExtensions)
            
            When used with the Toolkit, take the specially made AppDeployToolkitExtensions.ps1 and add it to your toolkits.
            If you already have custom Extensions, you can copy the contents of the 'PSADT Extensions' region in the 
            AppDeployToolkitExtensions.ps1 and add it to your existing files. You can then add the PSADTExtensions folder 
            to the AppDeployToolkit folder where the AppDeployToolkitExtensions.ps1 resides. The custom Extensions will then 
            be dot sourced during the loading of any Custom Extensions.
            
            Using the Extensions in this way allows for integrated logging with the Toolkit. If using CMTrace output type, 
            the logs will look similar to the example CMTrace output below. In the example you can see how the Extension
            Write-PSADTEventLog's output is also added directly into the log as if it were built in to PSAppDeployToolkit.
             
            
            Log Text                                                   Component              Date/Time                    Thread
            --------                                                   ---------              ---------                    -------
            [Initialization] :: Deployment type is [Installation].	   PSAppDeployToolkit	  4/13/2016 10:09:59 AM	4012   (0x0FAC)
            [Initialization] :: TestEvent Message	                   Write-PSADTEventLog	  4/13/2016 10:18:15 AM	4012   (0x0FAC)
            
                            
        2. Using Extensions as a Module. (Release\NoToolkit\PSADTExtensions)
           
           This can be used with the Toolkit, but it will replace the Built in Logging and Toolkit functions with external
           equivalents. As an example, Write-Log now functions in the following way:
           
           Write-Log -Message $Message -Severity $Severity -Source ${CmdletName}
           
           $Severity = '1' - Write-Verbose is used.
               Input:   Write-Log -Message $Message -Severity 1 -Source ${CmdletName}
               Output:  Write-Verbose -Message "$($Message) `nSource: $($Source)"
           
           $Severity = '2' - Write-Warning is used.
               Input:   Write-Log -Message $Message -Severity 2 -Source ${CmdletName}
               Output:  Write-Warning -Message "$($Message) `nSource: $($Source)"
               
           $Severity = '3' - Write-Error is used.
               Input:   Write-Log -Message $Message -Severity 2 -Source ${CmdletName}
               Output:  Write-Error -Message "$($Message) `nSource: $($Source)"
               
           $DebugMessage = $true - Write-Debug is used.
               Input:   Write-Log -Message $Message -Source ${CmdletName} -DebugMessage
               Output:  Write-Debug -Message "$($Message) `nSource: $($Source)"
           
           This module can be imported and used just like any other module.
           
           I might add some options for the logging to replicate the Toolkit logging output so it can be used outside of the toolkit.
           You could write scripts or other modules with the same logging capabilities as the Toolkit. I have done this in the past 
           with a few specific modules, but I think it might be useful as an option in this module as well.

    .LINK
        http://psappdeploytoolkit.com
#>

    [CmdletBinding()]
    [OutPutType([System.TimeSpan])]
    Param
    (

    )

    Begin
    {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
    }

    Process
    {
        Add-Type @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace PInvoke.Win32 {

    public static class UserInput {

        [DllImport("user32.dll", SetLastError=false)]
        private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

        [StructLayout(LayoutKind.Sequential)]
        private struct LASTINPUTINFO {
            public uint cbSize;
            public int dwTime;
        }

        public static DateTime LastInput {
            get {
                DateTime bootTime = DateTime.UtcNow.AddMilliseconds(-Environment.TickCount);
                DateTime lastInput = bootTime.AddMilliseconds(LastInputTicks);
                return lastInput;
            }
        }

        public static TimeSpan IdleTime {
            get {
                return DateTime.UtcNow.Subtract(LastInput);
            }
        }

        public static int LastInputTicks {
            get {
                LASTINPUTINFO lii = new LASTINPUTINFO();
                lii.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));
                GetLastInputInfo(ref lii);
                return lii.dwTime;
            }
        }
    }
}
'@                        
        Try
        {
            Write-Log -Message "Gathering IdleTime using PInvoke" -Severity 1 -Source ${CmdletName}
            
            $IdleTime = [PInvoke.Win32.UserInput]::IdleTime
            
            Write-Log -Message "[$($Env:COMPUTERNAME)] has been idle for [$($IdleTime)]" -Severity 1 -Source ${CmdletName}
        }
        catch
        {
            $ErrVar = $_
            Write-Log -Message "Failed to Gather IdleTime. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
            Throw "Failed to Gather IdleTime. `n$($ErrVar)"
        }
        Return $IdleTime
    }

    End
    {
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    }
}