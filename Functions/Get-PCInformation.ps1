Function Get-PCInformation {
    Param(
        [String]$ComputerName
    )
    $cimSession = New-CimSession $ComputerName -SessionOption (New-CimSessionOption -Protocol DCOM) -OperationTimeoutSec 1 -ErrorAction SilentlyContinue
    if (-not $cimSession) {
        Write-warning "$ComputerName is offline."
    } else {
        $registry = Get-WmiObject -List "stdRegProv" -Namespace root\default -ComputerName $ComputerName
        $ComputerSystem = Get-WmiObject -ComputerName $ComputerName -Class win32_computersystem
        $OperatingSystem = Get-WmiObject win32_operatingsystem -ComputerName $ComputerName

        $registry = Get-WmiObject -List "stdRegProv" -Namespace root\default -ComputerName $ComputerName
        $version = $registry.GetStringValue(2147483650,"SOFTWARE\Microsoft\Windows NT\CurrentVersion","ReleaseID").svalue

        if ($version -eq $null){
            $version = $OperatingSystem.version
        }

        [int]$memories = $ComputerSystem.TotalPhysicalMemory / 1GB

        $uptime = $OperatingSystem.ConvertToDateTime($OperatingSystem.LocalDateTime) - $OperatingSystem.ConvertToDateTime($OperatingSystem.LastBootUpTime)
        $model = $ComputerSystem.SystemFamily
        if ($model -eq $null) {
            $model = $ComputerSystem.Model
        }

        $properties = @{
            ComputerName = $ComputerName
            UserName = $ComputerSystem.username
            Model = $model
            Manufacturer = $ComputerSystem.manufacturer
            Memories = "$memories GB"
            UpTime = "$($uptime.Days) days $($uptime.Hours) hours $($uptime.Minutes) minutes"
            OSCaption = $OperatingSystem.caption
            OSVersion = $version
            BootTime = $OperatingSystem.ConvertToDateTime($OperatingSystem.LastBootUpTime)
        }
        $obj = New-Object -TypeName psobject -Property $properties
        Write-Output $obj | Select-Object ComputerName,OSCaption,OSVersion,UserName,Model,Manufacturer,Memories,UpTime,BootTime
    }
}