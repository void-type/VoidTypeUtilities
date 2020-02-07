function Get-WebCertificate {
  <#
  .SYNOPSIS
    Get the certificate of a website.
  .DESCRIPTION
    Queries the site URL and gets the HTTPS certificate.
  .EXAMPLE
    PS C:\> Get-WebCertificate -Url "Google.com"
  #>
  [CmdletBinding()]
  param(
    # The URLs to get certificates from.
    [Parameter(
      Position = 1,
      Mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true
    )]
    [string[]]$Url,

    # The port to connect to
    [int]$Port = 443
  )

  begin {
  }

  process {
    foreach ($siteUrl in $Url) {

      try {
        $tcpClient = New-Object -TypeName System.Net.Sockets.TCPClient($siteUrl, $Port)

        try {

          $callback = { param($sender, $cert, $chain, $errors) return $true }

          $sslStream = New-Object -TypeName System.Net.Security.SSLStream -ArgumentList @($tcpClient.GetStream(), $true, $callback)

          $sslStream.AuthenticateAsClient($siteUrl)
          $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($sslStream.RemoteCertificate)

          [DateTime]$expirationDate = [System.DateTime]::Parse($certificate.GetExpirationDateString())
          [int]$certExpiresIn = ($expirationDate - $(Get-Date -Hour 0 -Minute 0 -Second 0)).Days

          $properties = @{
            Url            = $siteUrl;
            Name           = $certificate.GetName();
            Issuer         = $certificate.GetIssuerName();
            ExpirationDate = $expirationDate.ToString("s");
            ExpiresInDays  = $certExpiresIn;
          }

          $certExpiryInfo = New-Object -TypeName PSObject -Property $properties

          return $certExpiryInfo

        } catch {
          throw $_
        } finally {
          $tcpClient.Dispose()
        }
      } catch {
        Write-Error "Could not reach the website $($siteUrl). Exception: $_"
        exit 1
      }
    }
  }

  end {
  }
}
