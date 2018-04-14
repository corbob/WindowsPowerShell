$PSDefaultParameterValues = @{
    'Export-Csv:NoTypeInformation' = $true
}
$modulesToImport = @(
    'AzureAD',
    'AzureRM',
    'MSOnline'
)
ForEach ($module in $modulesToImport) {
    $isValid = Get-Module $module -ListAvailable
    if ($null -eq $isValid) {
        Write-Warning "$module is not found in Modules path: $($env:PSModulePath)"
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

Set-Alias -Name mc -Value Measure-Command