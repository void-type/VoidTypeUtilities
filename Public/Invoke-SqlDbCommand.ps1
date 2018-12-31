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
