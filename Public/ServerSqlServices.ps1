function Get-ServerSqlServices {
  <#
  .SYNOPSIS
  Checks all databases for non-running SQL Services.
  Note that this only shows Windows Server 2012 and newer databases.

  .EXAMPLE
  PS C:\> Get-ServerSqlServices
  #>
  [CmdletBinding()]
  param(
    # Names of computers to invoke against
    [Parameter(
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 1,
      Mandatory = $true
    )]
    [string[]]$ComputerName
  )

  process {
    $ComputerName | ForEach-Object {
      $serverName = $_;
      Write-Verbose "Checking $serverName"
      Invoke-Command -ComputerName $serverName -ScriptBlock {
        Get-Service |
          Where-Object { $_.Name -in "MSSQLSERVER", "SQLSERVERAGENT" }
      } |
        Sort-Object -Property PSComputerName |
        Write-Output
    }
  }
}

function Start-ServerSqlServices {
  <#
  .SYNOPSIS
  Starts all SQL Services on a server.

  .EXAMPLE
  PS C:\> Start-ServerSqlServices -ComputerName AppDb
  #>

  [CmdletBinding()]param(
    # Names of computers to invoke against
    [Parameter(
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 1,
      Mandatory = $true
    )]
    [string[]]$ComputerName
  )

  Invoke-Command -ComputerName $ComputerName -ScriptBlock {
    Get-Service |
      Where-Object { $_.Name -in "MSSQLSERVER", "SQLSERVERAGENT" } |
      Start-Service |
      Write-Output
  }
}
