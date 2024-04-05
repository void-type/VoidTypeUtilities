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
        Url    = $Url
        Result = $null
      }

      do {
        try {
          $response = Invoke-WebRequest -Uri $Url -Method Head -UseBasicParsing -TimeoutSec 10

          if ($response.StatusCode -eq 200) {
            $urlResult.Result = $true
            Write-Output $urlResult
            break
          } else {
            Write-Verbose "Unsuccessful response code: $($response.StatusCode). Retrying..."
          }
        } catch {
          Write-Verbose "Error occurred: $_. Retrying..."
        }

        $retryCount++
        $retryTimeout = [Math]::Pow($TimeoutFactorSeconds, $retryCount + 1)
        Start-Sleep -Seconds $retryTimeout
      } while ($retryCount -lt $MaxRetries)

      if (-not $urlResult.Result) {
        $urlResult.Result = $false
        Write-Output $urlResult
      }
    }
  }
}
