$servers = Import-Csv -Path (gci '*admin_*').FullName
$pservers = $servers | where haspowershell -eq $true

# $serviceName = "w3svc"
# $serviceName = "MSSQLSERVER"
# $serviceName = "ReportServer"
# $serviceName = "MSDTSServer*"
$serviceName = "MSSQLServerOLAP*"

$pservers | select computername |
foreach-object {
  try {
    $service = get-service -computername $_.ComputerName $serviceName -ErrorAction SilentlyContinue
    if ($service) {
      Write-Output $_
    }
  } catch { }
}
