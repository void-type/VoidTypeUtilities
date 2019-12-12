function Convert-PfxToKeyAndCrt {
  [CmdletBinding()]
  param (
    # Parameter help description
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  $pfx = Get-ChildItem -Path $Path

  $out = New-Item -Path "./out/$($pfx.BaseName)" -ItemType Directory -ErrorAction SilentlyContinue -Force

  & "C:\Program Files\Git\usr\bin\openssl.exe" pkcs12 -in "$($pfx.FullName)" -nocerts -out "$($out.FullName)\$($pfx.BaseName).key"

  & "C:\Program Files\Git\usr\bin\openssl.exe" pkcs12 -in "$($pfx.FullName)" -clcerts -nokeys -out "$($out.FullName)\$($pfx.BaseName).crt"
}
