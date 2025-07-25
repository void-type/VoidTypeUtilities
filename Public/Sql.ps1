$global:vtuDefaultSqlServer = '.'
$global:vtuDefaultSqlConnectionStringOptions = 'Integrated Security=True;Persist Security Info=False;Connect Timeout=60;Encrypt=True;TrustServerCertificate=True;'

function Set-SqlDefaultAsLocalDb {
  <#
  .SYNOPSIS
  Call this in your Profile to setup default global vars to use LocalDB rather than a full local SQL Server.
  #>
  $global:vtuDefaultSqlServer = '(LocalDb)\MSSQLLocalDB'
  $global:vtuDefaultSqlConnectionStringOptions = 'Integrated Security=True;Persist Security Info=False;Connect Timeout=60;'
}

function Convert-SqlTraceToCommands {
  <#
  .SYNOPSIS
  Pulls SQL commands from a trace file.
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]
    $Path
  )

  (Get-Content $Path).TraceData.Events.Event.Column |
    Where-Object { $_.name -eq 'TextData' -and $_.'#text' } |
    Select-Object -ExpandProperty '#text' |
    Write-Output
}

function New-SqlConnectionString {
  <#
  .SYNOPSIS
  Build a connection string from options.
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]
    $Database,
    [Parameter()]
    [string]
    $Server = $vtuDefaultSqlServer,
    [Parameter()]
    [string]
    $ConnectionStringOptions = $vtuDefaultSqlConnectionStringOptions
  )

  return "Data Source=$Server;Initial Catalog=$Database;$ConnectionStringOptions"
}

function Get-SqlData {
  <#
    .SYNOPSIS
    Invoke a sql command and get data back.

    .EXAMPLE
    Get-SqlData -ConnectionString "Server=Server;Database=database;" -CommandText "Select * From table"
    #>
  [CmdletBinding()]
  param(
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
  [CmdletBinding()]
  param(
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

    [Parameter(Mandatory = $true, ParameterSetName = 'ConnectionString')]
    [string]
    $ConnectionString,

    [Parameter(Mandatory = $true, ParameterSetName = 'ConnectionParameters')]
    [string]
    $Database,
    [Parameter(ParameterSetName = 'ConnectionParameters')]
    [string]
    $Server = $vtuDefaultSqlServer,
    [Parameter(ParameterSetName = 'ConnectionParameters')]
    [string]
    $ConnectionStringOptions = $vtuDefaultSqlConnectionStringOptions
  )

  $sqlPackageExePath = Get-ToolsSqlPackage

  if ([string]::IsNullOrWhiteSpace($ConnectionString)) {
    $ConnectionString = New-SqlConnectionString -Database $Database -Server $Server -ConnectionStringOptions $ConnectionStringOptions
  }

  $sqlPackageExeArgs = @(
    '/Action:Import',
    "/SourceFile:$Path"
    "/TargetConnectionString:$ConnectionString"
  )

  Write-Verbose $ConnectionString

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

    [Parameter(Mandatory = $true, ParameterSetName = 'ConnectionString')]
    [string]
    $ConnectionString,

    [Parameter(Mandatory = $true, ParameterSetName = 'ConnectionParameters')]
    [string]
    $Database,
    [Parameter(ParameterSetName = 'ConnectionParameters')]
    [string]
    $Server = $vtuDefaultSqlServer,
    [Parameter(ParameterSetName = 'ConnectionParameters')]
    [string]
    $ConnectionStringOptions = $vtuDefaultSqlConnectionStringOptions
  )

  $sqlPackageExePath = Get-ToolsSqlPackage

  if ([string]::IsNullOrWhiteSpace($ConnectionString)) {
    $ConnectionString = New-SqlConnectionString -Database $Database -Server $Server -ConnectionStringOptions $ConnectionStringOptions
  }

  $sqlPackageExeArgs = @(
    '/Action:Export',
    "/TargetFile:$Path"
    "/SourceConnectionString:$ConnectionString"
  )

  Write-Verbose $ConnectionString

  & $sqlPackageExePath $sqlPackageExeArgs
}

function Remove-SqlDatabase {
  <#
  .SYNOPSIS
  Remove a SQL database.
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]
    $Database,

    [Parameter()]
    [string]
    $Server = $vtuDefaultSqlServer,

    [Parameter()]
    [string]
    $ConnectionStringOptions = $vtuDefaultSqlConnectionStringOptions
  )

  # Connect to master database to avoid connection issues
  $masterConnectionString = New-SqlConnectionString -Database 'master' -Server $Server -ConnectionStringOptions $ConnectionStringOptions

  # Set database to single user mode to force disconnect all users
  $singleUserModeCommand = "ALTER DATABASE [$Database] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;"
  Invoke-SqlCommand -ConnectionString $masterConnectionString -CommandText $singleUserModeCommand

  # Drop the database with all physical files
  $dropDatabaseCommand = "DROP DATABASE [$Database];"
  Invoke-SqlCommand -ConnectionString $masterConnectionString -CommandText $dropDatabaseCommand

  Write-Verbose "Database [$Database] has been dropped successfully."
}
