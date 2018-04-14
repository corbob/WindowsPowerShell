Function Get-PCInformation {
    Param(
        [String]$ComputerName,
        [pscredential]$Credential
    )
    $cimSession = New-CimSession $ComputerName -SessionOption (New-CimSessionOption -Protocol DCOM) -OperationTimeoutSec 1 -ErrorAction SilentlyContinue -Credential $Credential
    write-host "lkj: $cimsess"
    if (-not $cimSession) {
        Write-warning "$ComputerName is offline."
    }
    else {
        $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem -CimSession $cimSession
        $OperatingSystem = Get-CimInstance -ClassName win32_operatingsystem -CimSession $cimSession
        [UInt32]$HKLM = 2147483650
        $registryKey = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion'
        $registryValue = 'ReleaseID'
        $version = (Invoke-CimMethod -Namespace root\default -ClassName StdRegProv -MethodName GetStringValue -Arguments @{hDefKey = $HKLM; sSubKeyName = $registryKey; sValueName = $registryValue} -CimSession $cimSession).sValue        
        Remove-CimSession $cimSession
        if ($version -eq $null) {
            $version = $OperatingSystem.version
        }

        [int]$memories = $ComputerSystem.TotalPhysicalMemory / 1GB

        $uptime = $OperatingSystem.LocalDateTime - $OperatingSystem.LastBootUpTime
        $model = $ComputerSystem.SystemFamily
        if ($model -eq $null) {
            $model = $ComputerSystem.Model
        }

        $properties = @{
            ComputerName = $ComputerName
            UserName     = $ComputerSystem.username
            Model        = $model
            Manufacturer = $ComputerSystem.manufacturer
            Memories     = "$memories GB"
            UpTime       = "$($uptime.Days) days $($uptime.Hours) hours $($uptime.Minutes) minutes"
            OSCaption    = $OperatingSystem.caption
            OSVersion    = $version
            BootTime     = $OperatingSystem.LastBootUpTime
        }
        $obj = New-Object -TypeName psobject -Property $properties
        Write-Output $obj | Select-Object ComputerName, OSCaption, OSVersion, UserName, Model, Manufacturer, Memories, UpTime, BootTime
    }
}