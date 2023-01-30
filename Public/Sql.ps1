. "$PSScriptRoot/../Private/Sql.private.ps1"

function Get-SqlData {
  <#
    .SYNOPSIS
    Invoke a sql command and get data back.

    .EXAMPLE
    Get-SqlData -ConnectionString "Server=Server;Database=database;" -CommandText "Select * From table"
    #>
  [cmdletbinding()]
  Param(
    [Parameter(Mandatory = $true)]
    [string]$ConnectionString,

    [Parameter(Mandatory = $true)]
    [string]$CommandText,

    [Parameter(Mandatory = $false)]
    [string]$CommandTimeout = 60
  )

  $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
  $connection.Open()

  $command = $connection.CreateCommand()
  $command.CommandText = $CommandText
  $command.CommandTimeout = $CommandTimeout

  $adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
  $dataset = New-Object -TypeName System.Data.DataSet
  $adapter.Fill($dataset)
  $connection.Close()

  return $dataset.Tables[0]
}

function Invoke-SqlCommand {
  <#
    .SYNOPSIS
    Run a sql command against a db.

    .EXAMPLE
    Invoke-SqlCommand -ConnectionString "Server=Server;Database=database;" -CommandText "Insert Into..."
    #>
  [cmdletbinding()]
  Param(
    [Parameter(Mandatory = $true)]
    [string]$ConnectionString,

    [Parameter(Mandatory = $true)]
    [string]$CommandText,

    [Parameter(Mandatory = $false)]
    [string]$CommandTimeout = 60
  )

  $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
  $connection.Open()

  $command = $connection.CreateCommand()
  $command.CommandText = $CommandText
  $command.CommandTimeout = $CommandTimeout

  $command.ExecuteNonQuery()

  $connection.Close()
}

function Import-SqlBacpac {
  <#
  .SYNOPSIS
  Import a local bacpac
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]
    $Path,
    [Parameter(Mandatory = $true)]
    [string]
    $TargetDatabase,
    [string]
    $TargetServer = '(LocalDb)\MSSQLLocalDB',
    [string]
    $ConnectionStringOptions = "Integrated Security=True;Persist Security Info=False;Connect Timeout=60",
    [string]
    $SqlPackageDir = "$((Get-Item $profile).Directory)/SqlPackage"
  )

  $sqlPackageExePath = Get-SqlPackage

  if (-not (Test-Path -Path $sqlPackageExePath)) {
    Write-Host "SQLPackage not found. Exiting."
    return;
  }

  $connectionString = "Data Source=$TargetServer;Initial Catalog=$TargetDatabase;$ConnectionStringOptions"

  $sqlPackageExeArgs = @(
    "/Action:Import",
    "/SourceFile:$Path"
    "/TargetConnectionString:$connectionString"
  )

  & $sqlPackageExePath $sqlPackageExeArgs
}

function Export-SqlBacpac {
  <#
  .SYNOPSIS
  Export a bacpac
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]
    $Path,
    [Parameter(Mandatory = $true)]
    [string]
    $SourceDatabase,
    [string]
    $SourceServer = '(LocalDb)\MSSQLLocalDB',
    [string]
    $ConnectionStringOptions = "Integrated Security=True;Persist Security Info=False;Connect Timeout=60",
    [string]
    $SqlPackageDir = "$((Get-Item $profile).Directory)/SqlPackage"
  )

  $sqlPackageExePath = Get-SqlPackage

  if (-not (Test-Path -Path $sqlPackageExePath)) {
    Write-Host "SQLPackage not found. Exiting."
    return;
  }

  $connectionString = "Data Source=$SourceServer;Initial Catalog=$SourceDatabase;$ConnectionStringOptions"

  $sqlPackageExeArgs = @(
    "/Action:Export",
    "/TargetFile:$Path"
    "/SourceConnectionString:$connectionString"
  )

  & $sqlPackageExePath $sqlPackageExeArgs
}

function Convert-SqlTraceToCommands {
  <#
  .SYNOPSIS
  Pulls UPDATE SQL commands from a trace file.
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]
    $Path
  )

(Get-Content $Path).TraceData.Events.Event.Column |
    Where-Object { $_.name -eq 'TextData' -and $_.'#text'.StartsWith('UPDATE') } |
    Select-Object -ExpandProperty '#text' |
    Write-Output
}
