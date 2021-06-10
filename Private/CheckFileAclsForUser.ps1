[CmdletBinding()]
param (
  [Parameter(Mandatory = $true)]
  [string]
  $Path,
  [switch]
  $Recurse,
  [Parameter(Mandatory = $true)]
  [string]
  $UserIdentity
)

Get-ChildItem -Path $Path -Recurse:$Recurse |
  Get-Acl |
  ForEach-Object {
    $acl = $_

    foreach ($access in $acl.Access) {
      [PSCustomObject] @{
        Path              = $acl.Path.Split("::")[1]
        FileSystemRights  = $access.FileSystemRights
        AccessControlType = $access.AccessControlType
        IdentityReference = $access.IdentityReference
      } | Write-Output
    }
  } |
Where-Object { $_.IdentityReference -like "*$UserIdentity*" }
