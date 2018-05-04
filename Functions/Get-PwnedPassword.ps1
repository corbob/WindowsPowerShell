#http://jongurgul.com/blog/get-stringhash-get-filehash/ 
Function Get-StringSHA1Hash([String] $String) { 
    $SHA1 = [System.Security.Cryptography.Sha1]::create()
    $StringBuilder = New-Object System.Text.StringBuilder 
    $SHA1.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))| % { 
        [Void]$StringBuilder.Append($_.ToString("x2")) 
    } 
    $StringBuilder.ToString() 
}

function Get-PwnedPassword {

    <#
    .SYNOPSIS
      Use the pwnedpassword API to check if entered password has been in a public data breach.
    .DESCRIPTION
      Use the pwnedpassword API to check if entered password has been in a public data breach.
    .EXAMPLE
      Get-PwnedPassword Password
    .INPUTS
      [String]$Password
    .OUTPUTS
      [String]
    .NOTES
      General notes
  #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory, 
            ValueFromPipeline,
            ValueFromPipelineByPropertyName, 
            ValueFromRemainingArguments)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $Lookup
    )

    Begin {
        [System.Net.ServicePointManager]::SecurityProtocol = "Tls12"
    }
    Process {
        foreach ($value in $Lookup) {
            $count = 0
            switch ($value.getType().ToString()) {
                'System.Management.Automation.PSCredential' { 
                    $ToCheck = $value.GetNetworkCredential().Password
                    break
                }
                'System.String' {
                    $ToCheck = $value
                    break
                }
                Default {
                    $count = -1
                    return
                }
            }
            $SHA1 = Get-StringSHA1Hash -String $ToCheck
            $Result = Invoke-RestMethod -Uri "https://api.pwnedpasswords.com/range/$($SHA1[0..4] -join '')"
            $There = $Result -split "`r`n" | Where-Object { $PSItem -like "$($SHA1[5..$($SHA1.Length)] -join '')*" }
            if ($null -ne $There) {
                $count = ($There -split ':')[1]
            }
            Write-Output $count
        }
    }
}