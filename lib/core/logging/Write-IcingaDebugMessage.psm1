function Write-IcingaDebugMessage()
{
    param (
        [string]$Message,
        [array]$Objects  = @(),
        $ExceptionObject = $null
    );

    if ([string]::IsNullOrEmpty($Message)) {
        return;
    }

    if ($Global:Icinga.Protected.DebugMode -eq $FALSE) {
        return;
    }

    [array]$DebugContent = @($Message);
    $DebugContent += $Objects;

    Write-IcingaEventMessage -EventId 1000 -Namespace 'Debug' -ExceptionObject $ExceptionObject -Objects $DebugContent;
}
