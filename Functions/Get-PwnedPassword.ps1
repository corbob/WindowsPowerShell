#http://jongurgul.com/blog/get-stringhash-get-filehash/ 
Function Get-StringHash([String] $String,$HashName = "SHA1") 
{ 
$StringBuilder = New-Object System.Text.StringBuilder 
[System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{ 
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
    [String[]]$Password
  .OUTPUTS
    [String]
  .NOTES
    General notes
  #>

    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory, 
            ValueFromPipeline,
            ValueFromPipelineByPropertyName, 
            ValueFromRemainingArguments, 
            Position = 0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Password
    )

    Begin {
        [System.Net.ServicePointManager]::SecurityProtocol = "Tls12"
    }
    Process {
        $count = 0
        $SHA1 = Get-StringHash -String $Password
        $Result = Invoke-RestMethod -Uri "https://api.pwnedpasswords.com/range/$($SHA1[0..4] -join '')"
        $There = $Result -split "`r`n" | Where-Object { $PSItem -like "$($SHA1[5..$($SHA1.Length)] -join '')*" }
        if ($null -ne $There) {
            $count = ($There -split ':')[1]
        }
        Write-Output $count
    }
    End {
    }
}