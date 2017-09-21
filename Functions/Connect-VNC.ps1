Function MY-Connect-VNC {
    Param(
        [String]$ComputerName,
        [pscredential]$Credential,
        [Switch]$Force
    )
    $cimSession = New-CimSession $ComputerName -SessionOption (New-CimSessionOption -Protocol DCOM) -OperationTimeoutSec 1 -ErrorAction SilentlyContinue -Credential $Credential
    if ($cimSession -ne $null){
        $usr = (Get-CimInstance -CimSession $cimSession -Class win32_computersystem).username
        if ( ($usr -eq $null) -or ($Force) ) {
            $vnc = Get-CimInstance win32_process | Where-Object { $_.processname -eq 'tvnviewer.exe' -and $_.CommandLine -like '*-listen*'}
            if( $vnc -eq $null ){
                Start-Process "c:\Program Files\TightVNC\tvnviewer.exe" -ArgumentList "-listen"
            }
            Invoke-CimMethod -Path win32_process -Name create -CimSession $cimSession -ArgumentList "`"C:\Program Files\TightVNC\tvnserver.exe`" -controlservice -connect `"$($env:COMPUTERNAME)::5500`""
        } else {
            Write-Warning "$ComputerName Currently has $usr logged into it. Will now innitiate a VNC connection."
            Start-Process "c:\Program Files\TightVNC\tvnviewer.exe" $ComputerName
        }
    }
}