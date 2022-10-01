function Get-SqlDbData {
  <#
    .SYNOPSIS
    Invoke a sql command and get data back.

    .EXAMPLE
    Get-SqlDbData -ConnectionString "Server=Server;Database=database;" -CommandText "Select * From table"
    #>
  [cmdletbinding()]
  Param(
    [Parameter(Mandatory = $true)]
    [string]$ConnectionString,

    [Parameter(Mandatory = $true)]
    [string]$CommandText,

    [Parameter(Mandatory = $false)]
    [string]$CommandTimeout = 0
  )

  $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
  $connection.Open()

  $command = $connection.CreateCommand()
  $command.CommandText = $CommandText
  $command.CommandTimeout = $CommandTimeout

  $adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
  $dataset = New-Object -TypeName System.Data.DataSet
  $adapter.Fill($dataset)
  return $dataset.Tables[0]

  $connection.Close()
}

function Invoke-SqlDbCommand {
  <#
    .SYNOPSIS
    Run a sql command against a db.

    .EXAMPLE
    Invoke-SqlDbCommand -ConnectionString "Server=Server;Database=database;" -CommandText "Insert Into..."
    #>
  [cmdletbinding()]
  Param(
    [Parameter(Mandatory = $true)]
    [string]$ConnectionString,

    [Parameter(Mandatory = $true)]
    [string]$CommandText,

    [Parameter(Mandatory = $false)]
    [string]$CommandTimeout = 0
  )

  $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
  $connection.Open()

  $command = $connection.CreateCommand()
  $command.CommandText = $CommandText
  $command.CommandTimeout = $CommandTimeout

  $command.ExecuteNonQuery()

  $connection.Close()
}

function Import-DbBacpac {
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

  function Get-SqlPackage {
    $sqlPackageExePath = "$SqlPackageDir\SqlPackage.exe"

    if (Test-Path -Path $sqlPackageExePath) {
      return $sqlPackageExePath
    }

    Write-Host "Downloading SqlPackage..."

    New-Item -ItemType Directory -Path $SqlPackageDir -Force -ErrorAction Ignore | Out-Null

    $sqlPackageZipPath = "$SqlPackageDir\SqlPackage.zip"

    Invoke-WebRequest -Uri "https://aka.ms/sqlpackage-windows" -OutFile $sqlPackageZipPath

    Expand-Archive -Path $sqlPackageZipPath -DestinationPath $SqlPackageDir

    Remove-Item -Path $sqlPackageZipPath

    return $sqlPackageExePath
  }

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
