. $PSScriptRoot\Private\Variables.ps1
$availableModules = Get-Module -ListAvailable | Select-Object Name
# Modules.csv contains 
$modulesToImport = Import-Csv "$PSScriptRoot\Private\Modules.csv"
ForEach ($module in $modulesToImport){
    if ((-not $availableModules.Name.contains($module.Name)) -and ($module.InstallSource -eq 'PSGallery')) {
        try {
            Install-Module $module -Scope CurrentUser -ErrorAction Stop -AllowClobber
            Import-Module $($module.Name) -ErrorAction Stop
        } catch {
            Write-Error "Could not install $($module.Name)"
        }
    }
    try {
        Import-Module $($module.Name) -ErrorAction Stop
    } catch {
        Write-Error "Could not import $($module.name): $($_.Exception.Message)"
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