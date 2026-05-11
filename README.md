# VoidTypeUtilities

PowerShell Module of utilities I find useful.

Recommend to use with PowerShell 6+ (pwsh).

## Install

Clone or download this repo to one of the folders in your $env:PSModulePath.

```pwsh
$folder = $env:PSModulePath -split ';' | Select-Object -First 1
New-Item -ItemType Directory -Path $folder -Force
git clone https://github.com/void-type/VoidTypeUtilities $folder\VoidTypeUtilities
```

Then import the module in your `$Profile` or into each session you'd like to use it.

```pwsh
Import-Module VoidTypeUtilities
```

## Update

Run `Update-VoidTypeUtilities` to pull latest from the repo.

### Background auto daily updates

Add this second line to the top of your `$Profile`

```pwsh
Import-Module VoidTypeUtilities
Start-ThreadJob -ScriptBlock { Import-Module VoidTypeUtilities; Update-VoidTypeUtilitiesDaily } | Out-Null
```
