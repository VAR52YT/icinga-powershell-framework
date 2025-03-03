function Restart-IcingaWindowsService()
{
    [string]$JeaPid = Get-IcingaJEAServicePid;

    Stop-IcingaService -Service 'icingapowershell';

    if ((Test-IcingaJEAServiceRunning -JeaPid $JeaPid)) {
        Stop-Process -Id $JeaPid -Force;
    }

    Restart-IcingaService -Service 'icingapowershell';
}
