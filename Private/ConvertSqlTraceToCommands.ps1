function Convert-SqlTraceToCommands {
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
