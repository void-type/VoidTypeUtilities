function Convert-Base64ToString {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]
    $Base64
  )

  $bytes = [Convert]::FromBase64String($Base64)
  [System.Text.Encoding]::UTF8.GetString($bytes)
}

function Convert-StringToBase64 {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]
    $String
  )

  $bytes = [System.Text.Encoding]::UTF8.GetBytes($String)
  [Convert]::ToBase64String($bytes)
}
