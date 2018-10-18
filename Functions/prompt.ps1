function prompt {
    $lastCommand = $?
    $command = (history | measure).count
    $lastCommandHistory = Get-History $command
    $lastCommandExecutionTime = "$(($lastCommandHistory.EndExecutionTime - $lastCommandHistory.StartExecutionTime).milliseconds) ms"
    $Administrator = $false
    if (($PSVersionTable.PSVersion.Major -le 5) -or $IsWindows) {
        $currentUser = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
        $Administrator = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    switch ($ExecutionContext.SessionState.Path.CurrentLocation.provider.name) {
        FileSystem { 
            $providerColor = "Blue"
            break;
        }
        Registry {
            $providerColor = "Cyan"
            break;
        }
        Alias {
            $providerColor = "Magenta"
            break;
        }            
        Environment {
            $providerColor = "Yellow"
            break;
        }    
        Function {
            $providerColor = "DarkCyan"
            break;
        }         
        Variable {
            $providerColor = "DarkBlue"
            break;
        }        
        Certificate {
            $providerColor = "DarkGreen"
            break;
        }     
        WSMan {
            $providerColor = "White"
            break;
        }
        Default {
            $providerColor = "Red"
        }
    }
    $fgColor = 'Green'
    $hook = 'Green'
    if ($Administrator) {
        $fgColor = 'Red'
    }
    if (-not $lastCommand) {
        $hook = 'Red'
    }
    write-host -BackgroundColor $fgColor -ForegroundColor Black "<#$command" -NoNewline
    Write-Host " - $lastCommandExecutionTime"
    if ($null -eq $GitPromptScriptBlock) {
        write-host -ForegroundColor $providerColor "$($executionContext.SessionState.Path.CurrentLocation)"
    }
    else {
        & $GitPromptScriptBlock
        Write-Host " "
    }
    Write-Host -ForegroundColor Black -BackgroundColor $hook "#>" -NoNewline
    " "
}