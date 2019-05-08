function Show-WebCertificateExpiration {
  <#
    .SYNOPSIS
    Query a site for certificate expiration.
    .PARAMETER Url
    The site URL to get the certificate from.
    .EXAMPLE
    Show-WebCertificateExpiration -Url google.com
    #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
    [string]$Url,
    [int]$Port = 443
  )

  $certificate = Get-WebCertificate -Url $Url -Port $Port

  [DateTime]$expirationDate = [System.DateTime]::Parse($certificate.GetExpirationDateString())
  [int]$certExpiresIn = ($expirationDate - $(Get-Date -Hour 0 -Minute 0 -Second 0)).Days
  $certName = $certificate.GetName()
  $certIssuer = $certificate.GetIssuerName()

  return [PSCustomObject]@{
    Url            = $Url;
    Name           = $certName;
    Issuer         = $certIssuer;
    ExpirationDate = $expirationDate;
    ExpiresInDays  = $certExpiresIn;
  }
}

function Get-WebCertificate {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
    [string]$Url,
    [int]$Port = 443
  )

  $TCPClient = New-Object -TypeName System.Net.Sockets.TCPClient

  try {
    $TcpSocket = New-Object Net.Sockets.TcpClient($Url, $Port)
    $tcpstream = $TcpSocket.GetStream()
    $Callback = { param($sender, $cert, $chain, $errors) return $true }
    $SSLStream = New-Object -TypeName System.Net.Security.SSLStream -ArgumentList @($tcpstream, $True, $Callback)

    try {
      $SSLStream.AuthenticateAsClient($Url)
      $Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($SSLStream.RemoteCertificate)
    } finally {
      $SSLStream.Dispose()
    }

  } finally {
    $TCPClient.Dispose()
  }

  return $Certificate
}
