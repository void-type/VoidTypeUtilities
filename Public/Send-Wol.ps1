function Send-Wol {
  <#
    .SYNOPSIS
    Send a Wake-On-Lan magic packet to a broadcast address
    .PARAMETER Mac
    The MAC address of the device to wake
    .PARAMETER Ip
    The IP address to send the WOL packet to. This has a default of broadcast 255.255.255.255
    .PARAMETER Port
    The UDP port to send the WOL packet to. This has a default of port 9
    .EXAMPLE
    Send-Wol AAAAAAAAAAAA
    Shortest possible command
    .EXAMPLE
    Send-Wol -Mac AA:AA:AA:AA:AA:AA -Ip 192.168.1.5 -Port 7
    Define the specific IP and Port, typically not needed.
    #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
    [ValidatePattern('^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$')]
    [string]$Mac,
    [string]$Ip = "255.255.255.255",
    [int]$Port = 9
  )

  $broadcast = [Net.IPAddress]::Parse($Ip)

  $Mac = $Mac.ToUpper()
  $macOut = $Mac -replace "[:-]"
  $target = 0, 2, 4, 6, 8, 10 | ForEach-Object { [Convert]::ToByte($macOut.Substring($_, 2), 16) }
  $packet = (, [byte]255 * 6) + ($target * 16)

  $UDPclient = New-Object System.Net.Sockets.UdpClient
  $UDPclient.Connect($broadcast, $Port)
  [void]$UDPclient.Send($packet, 102)

  Write-Output "A magic packet was sent to $($Ip):$($Port) to wake device $($Mac)"
}
