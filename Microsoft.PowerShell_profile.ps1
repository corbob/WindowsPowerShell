. $PSScriptRoot\Private\Variables.ps1
# Modules.csv contains 
$modulesToImport = Import-Csv "$PSScriptRoot\Private\Modules.csv"
ForEach ($module in $modulesToImport) {
    try {
        Import-Module $($module.Name) -ErrorAction Stop
    }
    catch [System.IO.FileNotFoundException] {
        if ($module.InstallSource -eq 'PSGallery') {
            try {
                Install-Module $module.Name -Scope CurrentUser -ErrorAction Stop -AllowClobber
            }
            catch [System.IO.FileNotFoundException] {
                Write-Error "Could not import $($module.name): $($_.Exception.Message)"
            }
            catch {
                Write-Error "Could not install $($module.Name): $($_.Exception.Message)"
            }
        }
        else {
            Write-Error "Could not import module $($module.name): Module not found."
        }
    }
}
$Functions = Get-ChildItem $PSScriptRoot\Functions\*.ps1 -ErrorAction SilentlyContinue
foreach ($import in $Functions) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error "Failed to import function $($import.fullname): $_"
    }
}
Set-PSReadlineKeyHandler Tab -Function MenuComplete
Set-PowerLinePrompt -SetCurrentDirectory -RestoreVirtualTerminal -Newline -Timestamp -Colors "#000000" -PowerLineFont

Set-Alias -Name mc -Value Measure-Command