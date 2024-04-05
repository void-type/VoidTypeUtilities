function Test-UrlResponse {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string[]]$Urls,
    [int]$MaxRetries = 3,
    [int]$TimeoutFactorSeconds = 5
  )

  begin {
    $ResultHashTable = @{}
  }

  process {
    foreach ($Url in $Urls) {
      $retryCount = 0
      do {
        try {
          $response = Invoke-WebRequest -Uri $Url -Method Head -UseBasicParsing -TimeoutSec 10

          if ($response.StatusCode -eq 200) {
            $ResultHashTable[$Url] = $true
            break
          } else {
            Write-Host "Unsuccessful response code: $($response.StatusCode). Retrying..."
          }
        } catch {
          Write-Host "Error occurred: $_. Retrying..."
        }

        $retryCount++
        $retryTimeout = [Math]::Pow($TimeoutFactorSeconds, $retryCount + 1) # Calculate retry timeout using exponent of retry count + 1
        Start-Sleep -Seconds $retryTimeout
      } while ($retryCount -lt $MaxRetries)

      if (-not $ResultHashTable.ContainsKey($Url)) {
        $ResultHashTable[$Url] = $false
      }
    }
  }

  end {
    return $ResultHashTable
  }
}
