<#
.Synopsis
   Icinga PowerShell Module - Powerfull PowerShell Framework for monitoring Windows Systems
.DESCRIPTION
   More Information on https://github.com/LordHepipud/icinga-module-windows
.EXAMPLE
   Install-Icinga
 .NOTES
    
#>

$global:IncludeDir = "$PSScriptRoot\lib";

function Install-Icinga()
{
    [string]$command = Get-Icinga-Command('setup');
    return &$command;
}

function Get-Icinga-Setup()
{
    [string]$command = Get-Icinga-Command('setup');
    return &$command -IsAgentIntalled $TRUE;
}

function Get-Icinga-Service()
{
    $Icinga2.Service.Status();
}

function Start-Icinga-Service()
{
    $Icinga2.Service.Start();
}

function Stop-Icinga-Service()
{
    $Icinga2.Service.Stop();
}

function Restart-Icinga-Service()
{
    $Icinga2.Service.Restart();
}

function Install-Icinga-Service()
{
    [CmdletBinding()]
    param(
        [string]$IcingaServicePath = ''
    )
    $Icinga2.Service.Install($IcingaServicePath);
}

function Uninstall-Icinga-Service()
{
    $Icinga2.Service.Uninstall();
}

function Start-Icinga-Daemon
{
    [CmdletBinding()]
    param(
        [Switch]$NoConsole = $FALSE
    );

    if ((Get-Icinga-Setup) -eq $FALSE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Warning,
            'The agent seems to be not configured on this system. Please run "Install-Icinga" and try again.'
        );
        return;
    }

    if ($NoConsole) {
        $Icinga2.Log.DisableConsole();
    }

    $Icinga2.TCPDaemon.Start();
}

function Stop-Icinga-Daemon()
{
    if ((Get-Icinga-Setup) -eq $FALSE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Warning,
            'The agent seems to be not configured on this system. Please run "Install-Icinga" and try again.'
        );
        return;
    }

    $Icinga2.TCPDaemon.Stop();
}

function Start-Icinga-Checker
{
    [CmdletBinding()]
    param(
        [Switch]$NoConsole = $FALSE
    );

    if ((Get-Icinga-Setup) -eq $FALSE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Warning,
            'The agent seems to be not configured on this system. Please run "Install-Icinga" and try again.'
        );
        return;
    }

    if ($NoConsole) {
        $Icinga2.Log.DisableConsole();
    }

    $Icinga2.Checker.Start();
}

function Stop-Icinga-Checker
{
    if ((Get-Icinga-Setup) -eq $FALSE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Warning,
            'The agent seems to be not configured on this system. Please run "Install-Icinga" and try again.'
        );
        return;
    }

    $Icinga2.Checker.Stop();
}

<#
 # This function allows us to easily call core modules by simply
 # providing the name of the module we want to load
 #>
function Get-Icinga-Command()
{
    [CmdletBinding()]
    param(
        [string]$command = ''
    );

    [string]$command = [string]::Format('core\{0}.ps1', $command);

    return (Join-Path $PSScriptRoot -ChildPath $command);
}

<#
 # Execute checks based on a filter or execute all of them
 #>
function New-Icinga-Monitoring()
{
    param(
        [array]$Include                     = @(),
        [array]$Exclude                     = @(),
        [switch]$ListModules                = $FALSE,
        $Config                             = $null
    );

    if ((Get-Icinga-Setup) -eq $FALSE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Warning,
            'The agent seems to be not configured on this system. Please run "Install-Icinga" and try again.'
        );
        return;
    }

    [string]$command = Get-Icinga-Command('monitoring');
    return &$command -Include $Include -Exclude $Exclude -ListModules $ListModules -Config $Config -AgentRoot $Icinga2.App.RootPath;
}

<#
 # Retreive Performance Counter from our Windows System
 #>
function Get-Icinga-Counter()
{
    param(
        # Allows to specify the full path of a counter to fetch data. Example '\Processor(*)\% Processor Time'
        [string]$Counter                           = '',
        # Allows to fetch all counters of a specific category, like 'Processor'
        [string]$ListCounter                       = '',
        # Provide an array of counters we check in a bulk '\Processor(*)\% Processor Time', '\Processor(*)\% c1 time'"
        [array]$CounterArray                       = @(),
        # List all available Performance Counter Categories on a system
        [switch]$ListCategories                    = $FALSE,
        # By default counters will wait globally for 500 milliseconds. With this we can skip it. Use with caution!
        [switch]$SkipWait                          = $FALSE,
        # These arguments apply to CreateStructuredPerformanceCounterTable
        # This is the category name we want to create a structured output
        # Example: 'Network Interface'
        [string]$CreateStructuredOutputForCategory = '',
        # This is the hashtable of Performance Counters, created by
        # PerformanceCounterArray
        [hashtable]$StructuredCounterInput         = @{},
        # This argument is just a helper to replace certain strings within
        # a instance name with simply nothing.
        # Example: 'HarddiskVolume1' => '1'
        [array]$StructuredCounterInstanceCleanup   = @()
    );

    if ((Get-Icinga-Setup) -eq $FALSE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Warning,
            'The agent seems to be not configured on this system. Please run "Install-Icinga" and try again.'
        );
        return;
    }

    [string]$command = Get-Icinga-Command('perfcounter');
    return (&$command `
            -Counter $Counter `
            -ListCounter $ListCounter `
            -CounterArray $CounterArray `
            -ListCategories $ListCategories `
            -SkipWait $SkipWait `
            -CreateStructuredOutputForCategory $CreateStructuredOutputForCategory `
            -StructuredCounterInput $StructuredCounterInput `
            -StructuredCounterInstanceCleanup $StructuredCounterInstanceCleanup
            );
}

<#
 # Get a single config key of Icinga 2 or the entire configuration
 #>
function Get-Icinga-Config()
{
    param(
        [string]$Key        = '',
        [switch]$ListConfig = $FALSE
    );

     [string]$command = Get-Icinga-Command('config');
     return &$command -GetConfig $Key -ListConfig $ListConfig;
}

function Set-Icinga-Config()
{
    param(
        [string]$Key   = '',
        [Object]$Value = ''
    );

     [string]$command = Get-Icinga-Command('config');
     return &$command -AddKey $Key -AddValue $Value;
}

function Remove-Icinga-Config()
{
    param(
        [string]$Key  = ''
    );

     [string]$command = Get-Icinga-Command('config');
     return &$command -RemoveConfig $Key;
}

function New-Icinga-Config()
{
     [string]$command = Get-Icinga-Command('config');
     return &$command -Reload $TRUE;
}

function Get-Icinga-Lib()
{
    param([string]$Include);

    [string]$IncludeFile = (Join-Path $PSScriptRoot -ChildPath (
        [string]::Format(
            '\core\include\{0}.ps1',
            $Include
    )));

    if (-Not (Test-Path $IncludeFile)) {
        return;
    }

    return (& $IncludeFile);
}

function Get-Icinga-Object()
{
    return $Icinga2;
}

# Initialise base configuration for our module
$Icinga2 = & (Join-Path -Path $PSScriptRoot -ChildPath '\core\init.ps1') `
              -RootDirectory $PSScriptRoot `
              -ModuleName    $MyInvocation.MyCommand.Name;

Export-ModuleMember @Icinga2;