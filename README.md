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

## Configuration

Several behaviors can be customized by setting these global variables in your `$Profile` before or after importing the module.

| Variable | Default | Description |
| --- | --- | --- |
| `$vtuDefaultIde` | `'code'` | Command used to open files and folders in an IDE. Used by `Edit-PsProfile`, `Edit-PsModules`, `coded`, `codei`, and related dev commands. |
| `$vtuDefaultDevDir` | `'C:\dev\'` | Root directory where development projects live. Used by `cdd`, `coded`, `cloned`, and project-resolution helpers. |
| `$vtuDefaultSqlServer` | `'.'` | Default SQL Server instance for SQL functions. Set to `'(LocalDb)\MSSQLLocalDB'` via `Set-SqlDefaultAsLocalDb` to use LocalDB instead. |
| `$vtuDefaultSqlConnectionStringOptions` | `'Integrated Security=True;...'` | Default connection string options appended when building connection strings. Also updated by `Set-SqlDefaultAsLocalDb`. |
| `$vtuDefaultToolsDir` | `$profile/../Tools` | Base directory where downloaded tools (SqlPackage, PsTools, NuGet) are stored. |
| `$vtuDefaultSqlPackageDir` | `$vtuDefaultToolsDir/SqlPackage` | Directory for the SqlPackage tool. Overriding `$vtuDefaultToolsDir` moves this automatically unless overridden separately. |
| `$vtuDefaultPsToolsDir` | `$vtuDefaultToolsDir/PsTools` | Directory for the Sysinternals PsTools suite. Overriding `$vtuDefaultToolsDir` moves this automatically unless overridden separately. |

Example `$Profile` customization:

```pwsh
Import-Module VoidTypeUtilities

$global:vtuDefaultIde = 'nvim'
$global:vtuDefaultDevDir = 'D:\projects\'
Set-SqlDefaultAsLocalDb
```

## Update

Run `Update-VoidTypeUtilities` to pull latest from the repo.

### Background auto daily updates

Add this second line to the top of your `$Profile`

```pwsh
Import-Module VoidTypeUtilities
Start-ThreadJob -ScriptBlock { Import-Module VoidTypeUtilities; Update-VoidTypeUtilitiesDaily } | Out-Null
```
