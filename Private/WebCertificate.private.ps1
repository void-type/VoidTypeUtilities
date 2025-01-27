function Install-WebCertificateInternal {
  <#
  .SYNOPSIS
    Installs a new PFX and sets up all local sites to use it.
  .DESCRIPTION
    Installs a new PFX and sets up all local sites to use it.
  .EXAMPLE
    PS C:\> Install-WebCertificate -PfxPath "C:\path\to\cert.pfx" -Secret "password"
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [String]
    $PfxPath,
    [Parameter(Mandatory = $true)]
    [String]
    $Secret

  )
  # Remove space after # to enforce.
  #requires -module WebAdministration
  #requires -RunAsAdministrator
  $ErrorActionPreference = 'Stop'

  # Import new certs
  $cert = Import-PfxCertificate -FilePath $PfxPath -CertStoreLocation Cert:\LocalMachine\My -Password (ConvertTo-SecureString -String $Secret -AsPlainText -Force)
  [string]$certHash = $cert.GetCertHashString()

  # Pull up old matching certs
  [string[]] $oldHashes = Get-ChildItem Cert:\LocalMachine\My\ |
    Where-Object Subject -EQ $cert.Subject |
    Select-Object -ExpandProperty Thumbprint

  # Swap all old bindings to new bindings
  (Get-ChildItem IIS:Sites).Bindings.Collection |
    Where-Object { $_.CertificateHash -in $oldHashes } |
    ForEach-Object { $_.AddSslCertificate($certHash , "my") }

  # Remove old certs
  Get-ChildItem Cert:\LocalMachine\My\ |
    Where-Object Thumbprint -In $oldHashes |
    Remove-Item
}
