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
        # Ensure the string has a scheme so [System.Uri] can parse it correctly
        if ($siteUrl -notmatch '^https?://') {
          $targetUrl = "https://$siteUrl"
        } else {
          $targetUrl = $siteUrl
        }

        $uri = [System.Uri]$targetUrl
        $cleanHost = $uri.Host

        # Determine which port to use:
        # If the URI has a specific port assigned (-1 means no port was in the string), use it.
        # Otherwise, fall back to the function's $Port parameter.
        if ($uri.Port -ne -1 -and $siteUrl -match ':\d+') {
          $activePort = $uri.Port
        } else {
          $activePort = $Port
        }

        # Connect using the clean host and determined port
        $tcpClient = New-Object -TypeName System.Net.Sockets.TCPClient($cleanHost, $activePort)

        try {

          $callback = { param($senderVar, $cert, $chain, $errors) return $true }

          $sslStream = New-Object -TypeName System.Net.Security.SSLStream -ArgumentList @($tcpClient.GetStream(), $true, $callback)

          $sslStream.AuthenticateAsClient($cleanHost)
          $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($sslStream.RemoteCertificate)

          [DateTime]$expirationDate = [System.DateTime]::Parse($certificate.GetExpirationDateString())
          [int]$certExpiresIn = ($expirationDate - $(Get-Date -Hour 0 -Minute 0 -Second 0)).Days

          $properties = @{
            Url            = $siteUrl
            PortUsed       = $activePort
            Name           = $certificate.GetName()
            Issuer         = $certificate.GetIssuerName()
            ExpirationDate = $expirationDate.ToString('s')
            ExpiresInDays  = $certExpiresIn
          }

          $certExpiryInfo = New-Object -TypeName PSObject -Property $properties

          return $certExpiryInfo

        } catch {
          throw $_
        } finally {
          $tcpClient.Dispose()
        }
      } catch {
        Write-Error "Could not reach the website $($siteUrl). Exception $_"
      }
    }
  }

  end {
  }
}

function Convert-PfxToKeyAndCrt {
  <#
  .SYNOPSIS
    Converts a PFX file to a key and certificate file.
  .DESCRIPTION
    Converts a PFX file to a key and certificate file.
  .EXAMPLE
    PS C:\> Convert-PfxToKeyAndCrt -Path "C:\path\to\cert.pfx"
  #>
  [CmdletBinding()]
  param (
    # Parameter help description
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  $pfx = Get-ChildItem -Path $Path

  $out = New-Item -Path "./out/$($pfx.BaseName)" -ItemType Directory -ErrorAction SilentlyContinue -Force

  & 'C:\Program Files\Git\usr\bin\openssl.exe' pkcs12 -in "$($pfx.FullName)" -nocerts -out "$($out.FullName)\$($pfx.BaseName).key"

  & 'C:\Program Files\Git\usr\bin\openssl.exe' pkcs12 -in "$($pfx.FullName)" -clcerts -nokeys -out "$($out.FullName)\$($pfx.BaseName).crt"
}

function Install-WebCertificate {
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
  . $PSScriptRoot/../Private/WebCertificate.private.ps1

  Install-WebCertificateInternal -PfxPath $PfxPath -Secret $Secret
}
