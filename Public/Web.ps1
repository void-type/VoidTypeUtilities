function Test-UrlResponse {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string[]]$Urls,
    [int]$MaxRetries = 3,
    [int]$TimeoutFactorSeconds = 5
  )

  process {
    foreach ($Url in $Urls) {
      $retryCount = 0

      $urlResult = New-Object -TypeName PSObject -Property @{
        Url     = $Url
        Success = $false
        Error   = ''
      }

      do {
        try {
          Invoke-WebRequest -Uri $Url -Method Head -UseBasicParsing -TimeoutSec 10 | Out-Null

          # Success output
          $urlResult.Success = $true
          Write-Output $urlResult
          break
        } catch {
          $urlResult.Error = $_
          Write-Verbose "Error occurred: $_. Retrying..."
        }

        $retryCount++
        $retryTimeout = [Math]::Pow($TimeoutFactorSeconds, $retryCount + 1)
        Start-Sleep -Seconds $retryTimeout
      } while ($retryCount -lt $MaxRetries)

      # Error output
      Write-Output $urlResult
    }
  }
}
