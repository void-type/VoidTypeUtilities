function Get-WebCertificateExpiration {
  <#
    .SYNOPSIS
    Query a site for certificate expiration.
  .DESCRIPTION
    Queries the site URL and gets the HTTPS certificate, then returns the
    certificate expiration date.
    .EXAMPLE
    PS C:\> Show-WebCertificateExpiration -Url "Google.com"
    #>
  [CmdletBinding()]
  param(
    # The URLs to get certificates from.
    [Parameter(
      Position = 1,
      Mandatory = $True,
      ValueFromPipeline = $True,
      ValueFromPipelineByPropertyName = $True
    )]
    [string[]]$Url,

    [int]$Port = 443
  )

  process {

    $certificates = Get-WebCertificate -Url $Url -Port $Port

    foreach ($certificate in $certificates) {
      [DateTime]$expirationDate = [System.DateTime]::Parse($certificate.GetExpirationDateString())
      [int]$certExpiresIn = ($expirationDate - $(Get-Date -Hour 0 -Minute 0 -Second 0)).Days
      $certName = $certificate.GetName()
      $certIssuer = $certificate.GetIssuerName()

      Write-Output -InputObject [PSCustomObject]@ {
        Url            = $Url;
        Name           = $certName;
        Issuer         = $certIssuer;
        ExpirationDate = $expirationDate;
        ExpiresInDays  = $certExpiresIn;
      }
    }
  }
}

function Get-WebCertificate {
  <#
  .SYNOPSIS
    Get the certificate of a website.
  .DESCRIPTION
    Queries the site URL and gets the HTTPS certificate.
  .EXAMPLE
    PS C:\> Get-Certificate -Url "Google.com"
  #>
  [CmdletBinding()]
  param(
    # The URLs to get certificates from.
    [Parameter(
      Position = 1,
      Mandatory = $True,
      ValueFromPipeline = $True,
      ValueFromPipelineByPropertyName = $True
    )]
    [string[]]$Url,

    [int]$Port = 443
  )

  begin {
    $TCPClient = New-Object -TypeName System.Net.Sockets.TCPClient
  }

  process {
    foreach ($webSite in $Url) {
      $TcpSocket = New-Object Net.Sockets.TcpClient($webSite, $Port)
      $tcpstream = $TcpSocket.GetStream()
      $Callback = { param($sender, $cert, $chain, $errors) return $true }
      $SSLStream = New-Object -TypeName System.Net.Security.SSLStream -ArgumentList @($tcpstream, $True, $Callback)

      try {
        $SSLStream.AuthenticateAsClient($webSite)
        $Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($SSLStream.RemoteCertificate)
      } finally {
        $SSLStream.Dispose()
      }

      Write-Output -InputObject $Certificate
    }
  }

  end {
    $TCPClient.Dispose()
  }

}
