function Get-ServerLastBootTime {
  <#
    .SYNOPSIS
      Get last boot time of a remote machine
    .EXAMPLE
      PS C:\> Get-ServerLastBootTime LON-CL1
      Get the last boot time of the server.
    #>
  [CmdletBinding()]
  param (
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
    foreach ($computer in $ComputerName) {
      $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computer

      $lastBootTime = if ($null -eq $os) {
        "Offline"
      } else {
        $os.LastBootUptime.ToString("yyyy-MM-dd HH:mm:ss")
      }

      $properties = @{
        "ComputerName" = $computer;
        "LastStartup"  = lastBootTime;
      }

      $output = New-Object -TypeName PSObject -Property $properties

      Write-Output -InputObject $output
    }
  }
}

function Start-ServerGetFailedUpdatesJob {
  <#
  .SYNOPSIS
    Runs a job to get a list of updates that failed to install.
  .DESCRIPTION
    Poll the server for any updates that failed to install. Runs as job that can be checked later.
  .EXAMPLE
    PS C:\> $jobId = Start-ServerGetFailedUpdatesJob -ComputerName LON-CL1
    PS C:\> Receive-Job -Keep -Id $jobId
    Runs the job and then shows the output of the job later.
  #>
  [CmdletBinding()]
  param (
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
    Invoke-Command -ComputerName $ComputerName -AsJob -ScriptBlock {
      Get-WmiObject -Class win32_ReliabilityRecords -Filter "SourceName = 'Microsoft-Windows-WindowsUpdateClient'" |
        Where-Object { $_.Message -match 'failure' } |
        Select-Object -Property @{
          Label      = "ComputerName";
          Expression = { $env:COMPUTERNAME }
        }, @{
          Label      = "Date";
          Expression = { $_.ConvertToDateTime($_.TimeGenerated) }
        },
        @{
          Label      = "FailedUpdateName";
          Expression = { $_.ProductName }
        }
    }
  }
}

function Start-ServerGetPendingUpdatesJob {
  <#
  .SYNOPSIS
    Runs a job to get a list of updates that are pending install.
  .DESCRIPTION
    Poll the server for any updates that are pending install. Runs as job that can be checked later.
  .EXAMPLE
    PS C:\> $jobId = Start-ServerGetPendingUpdatesJob -ComputerName LON-CL1
    PS C:\> Receive-Job -Keep -Id $jobId
    Runs the job and then shows the output of the job later.
  #>
  [CmdletBinding()]
  param (
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
    Invoke-Command -ComputerName $ComputerName -AsJob -ScriptBlock {
      $UpdateSearcher = (New-Object -ComObject Microsoft.Update.Session).CreateupdateSearcher()
      $UpdateSearcher.Search("IsHidden=0 and IsInstalled=0").Updates |
        Select-Object -Property @{
          Label      = "ComputerName";
          Expression = { $env:COMPUTERNAME }
        }, @{
          Label      = "Pending Update Name";
          Expression = { $_.Title }
        }
    }
  }
}

