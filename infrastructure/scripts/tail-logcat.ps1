param(
  [string]$AdbPath = 'C:\Android\sdk\platform-tools\adb.exe',
  [string]$PackageName = 'com.safesteps.app',
  [switch]$AllAuthorized,
  [int]$Lines = 300
)

if (-not (Test-Path $AdbPath)) { Write-Error "adb not found at $AdbPath"; exit 1 }

& $AdbPath start-server | Out-Null

function Get-AuthorizedDevices {
  (& $AdbPath devices) -split "`n" |
    Where-Object { $_ -match "`tdevice$" } |
    ForEach-Object { ($_ -split "\s+")[0] }
}

$targets = if ($AllAuthorized) { Get-AuthorizedDevices } else { @(Get-AuthorizedDevices | Select-Object -First 1) }
if (-not $targets -or $targets.Count -eq 0) { Write-Error 'No authorized devices found.'; exit 1 }

Write-Host "Clearing logs..."
foreach ($s in $targets) { & $AdbPath -s $s logcat -c }

Write-Host "Tailing logs for: $($targets -join ', ')" 
Write-Host "Press Ctrl+C to stop."

foreach ($s in $targets) {
  Start-Job -ScriptBlock {
    param($AdbPath, $s, $Lines)
    & $AdbPath -s $s logcat -v time ReactNativeJS:V AndroidRuntime:E com.rnmaps:V GoogleMaps:V *:S | Select-Object -Last $Lines
    & $AdbPath -s $s logcat -v time ReactNativeJS:V AndroidRuntime:E com.rnmaps:V GoogleMaps:V *:S
  } -ArgumentList $AdbPath, $s, $Lines | Out-Null
}

Get-Job | Wait-Job
