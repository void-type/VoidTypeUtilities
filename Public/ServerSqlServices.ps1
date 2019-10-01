# TODO: add the names of all the sql services we care about here
$private:services = "MSSQLSERVER", "SQLSERVERAGENT"

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

  return Invoke-Command -ComputerName $ComputerName -ScriptBlock {
    Get-Service |
      Where-Object { $_.Name -in $services }
  } |
    Sort-Object -Property PSComputerName
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

  return Invoke-Command -ComputerName $ComputerName -ScriptBlock {
    Get-Service |
      Where-Object { $_.Name -in $services } |
      Start-Service
  }
}
