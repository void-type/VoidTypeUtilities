function Send-Wol {
  <#
    .SYNOPSIS
    Send a Wake-On-Lan magic packet to a broadcast address
    .PARAMETER MAC
    The MAC address of the device to wake
    .PARAMETER IpAddress
    The IP address to send the WOL packet to. This has a default of broadcast 255.255.255.255
    .PARAMETER Port
    The UDP port to send the WOL packet to. This has a default of port 9
    .EXAMPLE
    Send-Wol AAAAAAAAAAAA
    Shortest possible command. Sends the packet 3 times.
    .EXAMPLE
    Send-Wol -Mac AA:AA:AA:AA:AA:AA -IpAddress 192.168.1.5 -Port 7 -Repeat 7
    Define the specific IP and Port, typically not needed. Will repeat the command 7 times.
    #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
    [ValidatePattern('^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$')]
    [string]$MAC,
    [string]$IpAddress = '255.255.255.255',
    [int]$Port = 9,
    [ValidateRange(1, [int]::MaxValue)]
    [int]$Repeat = 3,
    [ValidateRange(1, [int]::MaxValue)]
    [int]$SleepMilliseconds = 150
  )

  $MACBytes = $MAC.ToUpper() -split '[:-]' | ForEach-Object { [Convert]::ToByte($_, 16) }

  # Magic packet is 6 bytes of 255, then the target's 6 byte MAC repeated 16 times.
  $magicPacket = (, [byte]255 * 6) + ($MACBytes * 16)

  $UDPclient = New-Object System.Net.Sockets.UdpClient
  $UDPclient.Connect([Net.IPAddress]::Parse($IpAddress), $Port)

  for ($i = 0; $i -lt $Repeat; $i++) {
    $UDPclient.Send($magicPacket, $magicPacket.Length) | Out-Null
    Write-Output "A magic packet was sent to $($IpAddress):$($Port) to wake device $($MAC)"
    Start-Sleep -Milliseconds $SleepMilliseconds
  }

  $UDPclient.Dispose()
}
