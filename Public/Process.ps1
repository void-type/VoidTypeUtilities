function Get-ProcessFromPort {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [int]$Port
  )


  Get-NetTCPConnection -LocalPort $Port | Select-Object -ExpandProperty OwningProcess | ForEach-Object { Get-Process -Id $_ }
}

function Stop-ProcessFromPort {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [int]$Port
  )

  $process = Get-ProcessFromPort -Port $Port

  if ($null -eq $process) {
    Write-Warning "No process found listening on port $Port."
    return
  }

  Write-Host "Stopping process tree for: $($process.Name) (PID: $($process.Id))"
  Stop-Process -Id $process.Id -Force -Confirm:$false
}
