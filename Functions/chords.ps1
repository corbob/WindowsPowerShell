Set-PSReadLineKeyHandler -Chord "Ctrl+g,Ctrl+g" -ScriptBlock {
[Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
[Microsoft.PowerShell.PSConsoleReadLine]::Insert('git pull')
[Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Chord "Ctrl+g,Ctrl+s" -ScriptBlock {
[Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
[Microsoft.PowerShell.PSConsoleReadLine]::Insert('git status')
[Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Chord "Ctrl+g,Ctrl+p" -ScriptBlock {
[Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
[Microsoft.PowerShell.PSConsoleReadLine]::Insert('git push')
[Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
